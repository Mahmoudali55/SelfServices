import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/services/camera_service.dart';
import '../../../core/services/face_detection_service.dart';
import '../../services/data/model/request_leave/employee_model.dart';
import '../../services/data/repo/services_repo.dart';
import '../data/models/student_face_model.dart';

part 'face_recognition_state.dart';

class FaceRecognitionCubit extends Cubit<FaceRecognitionState> {
  final CameraService cameraService;
  final FaceDetectionService faceDetectionService;

  // Cache for registered face features to speed up recognition
  final List<StudentFaceModel> _remoteFaces = [];
  final Map<String, List<double>> _remoteFeaturesMap = {};

  // Local file based cache: empId -> {hash: String, features: List<double>}
  Map<String, dynamic> _featuresCache = {};
  bool _cacheLoaded = false;
  String? _persistentCachePath;

  FaceRecognitionCubit({required this.cameraService, required this.faceDetectionService})
    : super(FaceRecognitionInitial());

  /// Initialize camera for face detection
  Future<void> initializeCamera({CameraLensDirection direction = CameraLensDirection.front}) async {
    emit(FaceRecognitionCameraInitializing());

    try {
      await faceDetectionService.initialize();
      final success = await cameraService.initializeCamera(direction: direction);

      if (success) {
        emit(FaceRecognitionCameraReady());
      } else {
        emit(const FaceRecognitionError('Failed to initialize camera'));
      }
    } catch (e) {
      emit(FaceRecognitionError('Camera initialization error: ${e.toString()}'));
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    emit(FaceRecognitionCameraInitializing());

    try {
      final success = await cameraService.switchCamera();

      if (success) {
        emit(FaceRecognitionCameraReady());
      } else {
        emit(const FaceRecognitionError('Failed to switch camera'));
      }
    } catch (e) {
      emit(FaceRecognitionError('Camera switch error: ${e.toString()}'));
    }
  }

  /// Capture and extract face features without full registration
  Future<void> captureAndExtractFeatures() async {
    emit(FaceRecognitionProcessing());

    try {
      final imageFile = await cameraService.captureImage();

      if (imageFile == null) {
        emit(const FaceRecognitionError('Failed to capture image'));
        return;
      }

      final hasValidFace = await faceDetectionService.hasValidFace(imageFile);
      if (!hasValidFace) {
        emit(const FaceRecognitionError('No clear face detected. Please try again.'));
        return;
      }

      final qualityScore = await faceDetectionService.getFaceQualityScore(imageFile);
      if (qualityScore < 50) {
        emit(
          const FaceRecognitionError(
            'Face quality is too low. Please ensure good lighting and face the camera directly.',
          ),
        );
        return;
      }

      final faces = await faceDetectionService.detectFacesInFile(imageFile);
      if (faces.isEmpty) {
        emit(const FaceRecognitionError('No face detected during processing.'));
        return;
      }

      final features = faceDetectionService.extractFaceFeatures(faces.first);
      if (features.isEmpty) {
        emit(
          const FaceRecognitionError(
            'Could not extract face features. Please ensure face is clearly visible.',
          ),
        );
        return;
      }

      emit(
        FaceRecognitionCaptured(
          imageFile: imageFile,
          features: features,
          qualityScore: qualityScore,
        ),
      );
    } catch (e) {
      emit(FaceRecognitionError('Capture error: ${e.toString()}'));
    }
  }

  /// Detect faces in current camera frame
  Future<void> detectFacesInFrame() async {
    try {
      final imageFile = await cameraService.captureImage();

      if (imageFile == null) {
        return;
      }

      final faces = await faceDetectionService.detectFacesInFile(imageFile);

      if (faces.isNotEmpty) {
        emit(FaceRecognitionFacesDetected(faces));
      } else {
        emit(FaceRecognitionNoFaceDetected());
      }
    } catch (e) {
      // Silent error for continuous detection
    }
  }

  bool _isProcessingStream = false;
  DateTime? _lastProcessingTime;

  /// Recognize student from CameraImage stream (Instant recognition)
  Future<void> recognizeFromStream({required CameraImage image, required double threshold}) async {
    // Throttle: Only process if at least 500ms passed since last frame
    final now = DateTime.now();
    if (_lastProcessingTime != null && now.difference(_lastProcessingTime!).inMilliseconds < 500) {
      return;
    }

    if (_isProcessingStream) return;
    _isProcessingStream = true;
    _lastProcessingTime = now;

    try {
      final sensorOrientation = cameraService.controller?.description.sensorOrientation ?? 90;
      final faces = await faceDetectionService.detectFacesFromStream(image, sensorOrientation);

      if (faces.isEmpty) {
        emit(FaceRecognitionNoFaceDetected());
        _isProcessingStream = false;
        return;
      }

      final features = faceDetectionService.extractFaceFeatures(faces.first);
      if (features.isEmpty) {
        _isProcessingStream = false;
        return;
      }

      // If no faces are registered yet, it's definitely a No Match
      if (_remoteFaces.isEmpty) {
        emit(FaceRecognitionNoMatch(imageFile: null, features: features, qualityScore: 100.0));
        _isProcessingStream = false;
        return;
      }

      final match = await faceDetectionService.findBestMatch(
        capturedFeatures: features,
        registeredFeatures: _remoteFeaturesMap,
        threshold: threshold,
      );

      if (match != null) {
        // Capture a high-quality photo once recognized for record-keeping
        final capturedImage = await cameraService.captureImage();

        final matchedStudent = _remoteFaces.firstWhere(
          (face) => face.studentId == match['studentId'],
        );

        emit(
          FaceRecognitionStudentRecognized(
            student: matchedStudent,
            confidence: match['confidence'],
            imageFile: capturedImage,
          ),
        );
      } else {
        // No match found in the stream
        emit(
          FaceRecognitionNoMatch(
            imageFile: null, // No image file for stream failures to save memory
            features: features,
            qualityScore: 100.0,
          ),
        );
      }
    } catch (e) {
      // Silent error for stream stability
    } finally {
      _isProcessingStream = false;
    }
  }

  /// Recognize student from captured image (Old method, kept for reference/manual capture)
  Future<void> recognizeStudent({required String classId, required double threshold}) async {
    emit(FaceRecognitionProcessing());

    try {
      // Capture image
      final capturedImage = await cameraService.captureImage();

      if (capturedImage == null) {
        emit(const FaceRecognitionError('Failed to capture image'));
        return;
      }

      final faces = await faceDetectionService.detectFacesInFile(capturedImage);

      if (faces.isEmpty) {
        emit(FaceRecognitionNoFaceDetected());
        return;
      }

      final features = faceDetectionService.extractFaceFeatures(faces.first);

      if (features.isEmpty) {
        emit(FaceRecognitionNoMatch(imageFile: capturedImage, features: features, qualityScore: 0));
        return;
      }

      if (_remoteFaces.isEmpty || _remoteFeaturesMap.isEmpty) {
        emit(const FaceRecognitionError('No registered faces found from server'));
        return;
      }

      final match = await faceDetectionService.findBestMatch(
        capturedFeatures: features,
        registeredFeatures: _remoteFeaturesMap,
        threshold: threshold,
      );

      if (match != null) {
        final matchedStudent = _remoteFaces.firstWhere(
          (face) => face.studentId == match['studentId'],
        );

        emit(
          FaceRecognitionStudentRecognized(
            student: matchedStudent,
            confidence: match['confidence'],
            imageFile: capturedImage,
          ),
        );
      } else {
        emit(
          FaceRecognitionNoMatch(imageFile: capturedImage, features: features, qualityScore: 100.0),
        );
      }
    } catch (e) {
      emit(FaceRecognitionError('Recognition error: ${e.toString()}'));
    }
  }

  /// Complete registration in memory (for current session only)
  Future<void> completeRegistration({
    required String studentId,
    required String studentName,
    required String classId,
    required File imageFile,
    required List<double> features,
    required double qualityScore,
    String? serverPath,
  }) async {
    emit(FaceRecognitionProcessing());

    try {
      final model = StudentFaceModel(
        studentId: studentId,
        studentName: studentName,
        faceImagePath: imageFile.path,
        registrationDate: DateTime.now(),
        classId: classId,
        faceMetadata: {'features': features, 'qualityScore': qualityScore},
      );

      _remoteFaces.add(model);
      _remoteFeaturesMap[studentId] = features;

      emit(FaceRecognitionRegistered(model));
    } catch (e) {
      emit(FaceRecognitionError('Registration error: ${e.toString()}'));
    }
  }

  /// Delete student face from memory
  Future<void> deleteStudentFace(String studentId) async {
    emit(FaceRecognitionProcessing());

    try {
      _remoteFaces.removeWhere((face) => face.studentId == studentId);
      _remoteFeaturesMap.remove(studentId);

      emit(FaceRecognitionFaceDeleted());
      // Re-emit loaded state to update UI list
      emit(FaceRecognitionRegisteredStudentsLoaded(List.from(_remoteFaces)));
    } catch (e) {
      emit(FaceRecognitionError('Failed to delete face: ${e.toString()}'));
    }
  }

  /// Populate memory from local cache for instant UI response
  Future<void> populateFromCache(List<EmployeeModel> employees) async {
    if (!_cacheLoaded) {
      await _loadCache();
    }

    if (_persistentCachePath == null) {
      final docDir = await getApplicationDocumentsDirectory();
      _persistentCachePath = '${docDir.path}/face_cache';
      final dir = Directory(_persistentCachePath!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }

    final List<StudentFaceModel> cachedList = [];
    final Set<String> currentEmpIds = employees.map((e) => e.empCode.toString()).toSet();

    for (var empId in _featuresCache.keys) {
      if (!currentEmpIds.contains(empId)) continue;

      final cachedData = _featuresCache[empId];
      final imageFile = File('$_persistentCachePath/remote_$empId.jpg');

      if (await imageFile.exists() && cachedData['features'] != null) {
        final emp = employees.firstWhere((e) => e.empCode.toString() == empId);
        final model = StudentFaceModel(
          studentId: empId,
          studentName: emp.empName ?? emp.empNameE ?? '',
          faceImagePath: imageFile.path,
          registrationDate: DateTime.now(),
          classId: 'employees',
          faceMetadata: {'features': List<double>.from(cachedData['features'])},
        );
        cachedList.add(model);
        _remoteFeaturesMap[empId] = List<double>.from(cachedData['features']);
      }
    }

    if (cachedList.isNotEmpty) {
      _remoteFaces.clear();
      _remoteFaces.addAll(cachedList);
      emit(FaceRecognitionRegisteredStudentsLoaded(List.from(_remoteFaces)));
    }
  }

  /// Process remote faces and store in memory (Optimized for speed + Caching)
  Future<void> loadFacesFromRemote(List<EmployeeModel> employees, ServicesRepo servicesRepo) async {
    // 1. First, populate from cache for instant response
    await populateFromCache(employees);

    // Initial loading state if empty, otherwise we just update in background
    if (_remoteFaces.isEmpty) {
      emit(FaceRecognitionLoading());
    }

    // 2. Determine persistent path
    if (_persistentCachePath == null) {
      final docDir = await getApplicationDocumentsDirectory();
      _persistentCachePath = '${docDir.path}/face_cache';
      final dir = Directory(_persistentCachePath!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }

    // Process in chunks to balance concurrency and resource usage
    const int chunkSize = 5;

    for (var i = 0; i < employees.length; i += chunkSize) {
      final end = (i + chunkSize < employees.length) ? i + chunkSize : employees.length;
      final chunk = employees.sublist(i, end);

      await Future.wait(chunk.map((emp) => _processEmployeeFace(emp, servicesRepo)));

      // Emit incremental update
      if (!isClosed) {
        emit(FaceRecognitionRegisteredStudentsLoaded(List.from(_remoteFaces)));
      }
    }

    // Save cache to disk after all processing is done
    await _saveCache();

    // Final emit
    if (!isClosed) {
      emit(FaceRecognitionRegisteredStudentsLoaded(List.from(_remoteFaces)));
    }
  }

  Future<void> _processEmployeeFace(EmployeeModel emp, ServicesRepo servicesRepo) async {
    final empIdStr = emp.empCode.toString();

    try {
      final result = await servicesRepo.getEmployeeFaceImage(emp.empCode);

      await result.fold((failure) async {}, (base64Img) async {
        if (base64Img.isNotEmpty) {
          try {
            // 1. Calculate Signature of the image data
            final prefixLen = base64Img.length > 50 ? 50 : base64Img.length;
            final signature = '${base64Img.length}_${base64Img.substring(0, prefixLen)}';

            List<double> features = [];

            // 2. Check Cache
            if (_featuresCache.containsKey(empIdStr)) {
              final cachedData = _featuresCache[empIdStr];
              if (cachedData['hash'] == signature && cachedData['features'] != null) {
                // Cache Hit! Check if file exists in persistent storage
                final cacheFile = File('$_persistentCachePath/remote_$empIdStr.jpg');
                if (await cacheFile.exists()) {
                  features = List<double>.from(cachedData['features']);

                  // Ensure it's in memory for recognition if not already there
                  if (!_remoteFeaturesMap.containsKey(empIdStr)) {
                    _addFaceToMemory(emp, cacheFile, features);
                  }
                  return; // Done, no update needed
                }
              }
            }

            // 3. Cache Miss (or signature mismatch) -> Run ML
            final bytes = base64Decode(base64Img);
            final cacheFile = File('$_persistentCachePath/remote_$empIdStr.jpg');
            await cacheFile.writeAsBytes(bytes);

            final faces = await faceDetectionService.detectFacesInFile(cacheFile);
            if (faces.isNotEmpty) {
              features = faceDetectionService.extractFaceFeatures(faces.first);
              if (features.isNotEmpty) {
                // 4. Update Cache
                _featuresCache[empIdStr] = {
                  'hash': signature,
                  'features': features,
                  'lastUpdated': DateTime.now().toIso8601String(),
                };

                // Update or add to memory
                _addOrUpdateFaceInMemory(emp, cacheFile, features);
              }
            }
          } catch (e) {
            print('Error processing remote face for ${emp.empCode}: $e');
          }
        }
      });
    } catch (e) {
      print('Error fetching remote face for $emp: $e');
    }
  }

  void _addOrUpdateFaceInMemory(EmployeeModel emp, File imageFile, List<double> features) {
    final empId = emp.empCode.toString();
    final model = StudentFaceModel(
      studentId: empId,
      studentName: emp.empName ?? emp.empNameE ?? '',
      faceImagePath: imageFile.path,
      registrationDate: DateTime.now(),
      classId: 'employees',
      faceMetadata: {'features': features},
    );

    // Update if exists, else add
    final index = _remoteFaces.indexWhere((f) => f.studentId == empId);
    if (index != -1) {
      _remoteFaces[index] = model;
    } else {
      _remoteFaces.add(model);
    }
    _remoteFeaturesMap[empId] = features;
  }

  void _addFaceToMemory(EmployeeModel emp, File imageFile, List<double> features) {
    final model = StudentFaceModel(
      studentId: emp.empCode.toString(),
      studentName: emp.empName ?? emp.empNameE ?? '',
      faceImagePath: imageFile.path,
      registrationDate: DateTime.now(),
      classId: 'employees',
      faceMetadata: {'features': features},
    );

    _remoteFaces.add(model);
    _remoteFeaturesMap[emp.empCode.toString()] = features;
  }

  Future<void> _loadCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/face_features_cache.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonMap = jsonDecode(content) as Map<String, dynamic>;
        _featuresCache = jsonMap;
      }
      _cacheLoaded = true;
    } catch (e) {
      print('Error loading face cache: $e');
      _featuresCache = {};
    }
  }

  Future<void> _saveCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/face_features_cache.json');
      await file.writeAsString(jsonEncode(_featuresCache));
    } catch (e) {
      print('Error saving face cache: $e');
    }
  }

  /// Dispose resources
  Future<void> disposeResources() async {
    await cameraService.disposeCamera();
    await faceDetectionService.dispose();
  }

  @override
  Future<void> close() {
    disposeResources();
    return super.close();
  }
}
