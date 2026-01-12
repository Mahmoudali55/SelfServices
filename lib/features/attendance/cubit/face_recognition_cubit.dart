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
  List<StudentFaceModel> _remoteFaces = [];
  Map<String, List<double>> _remoteFeaturesMap = {};

  // Local file based cache: empId -> {hash: String, features: List<double>}
  Map<String, dynamic> _featuresCache = {};
  bool _cacheLoaded = false;

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

  /// Recognize student from captured image
  Future<void> recognizeStudent({required String classId, required double threshold}) async {
    emit(FaceRecognitionProcessing());

    try {
      // Capture image
      final capturedImage = await cameraService.captureImage();

      if (capturedImage == null) {
        emit(const FaceRecognitionError('Failed to capture image'));
        return;
      }

      // Detect faces
      final faces = await faceDetectionService.detectFacesInFile(capturedImage);

      if (faces.isEmpty) {
        emit(FaceRecognitionNoFaceDetected());
        return;
      }

      // Use the largest/main face
      final features = faceDetectionService.extractFaceFeatures(faces.first);

      if (features.isEmpty) {
        // Face found but features (landmarks) not clear enough
        emit(
          FaceRecognitionNoMatch(
            imageFile: capturedImage,
            features: features,
            qualityScore: 0, // Unknown quality if we failed extraction or just pass generic
          ),
        );
        return;
      }

      // Use in-memory faces
      if (_remoteFaces.isEmpty || _remoteFeaturesMap.isEmpty) {
        emit(const FaceRecognitionError('No registered faces found from server'));
        return;
      }

      if (_remoteFeaturesMap.isEmpty) {
        emit(
          const FaceRecognitionError(
            'No valid face data found. Please ensure students are registered.',
          ),
        );
        return;
      }

      // Find best match using cached data
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
          ),
        );
      } else {
        // We have features but no match -> New Person?
        // Pass the data so the UI can offer registration
        emit(
          FaceRecognitionNoMatch(
            imageFile: capturedImage,
            features: features,
            qualityScore:
                100.0, // We don't have explicit score here, assume good enough if extracted
          ),
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

  /// Process remote faces and store in memory (Optimized for speed + Caching)
  Future<void> loadFacesFromRemote(List<EmployeeModel> employees, ServicesRepo servicesRepo) async {
    _remoteFaces.clear();
    _remoteFeaturesMap.clear();
    // Initial loading state
    emit(FaceRecognitionLoading());

    // Load cache from disk if not already loaded
    if (!_cacheLoaded) {
      await _loadCache();
    }

    final tempDir = await getTemporaryDirectory();

    // Process in chunks to balance concurrency and resource usage
    const int chunkSize = 5;

    for (var i = 0; i < employees.length; i += chunkSize) {
      final end = (i + chunkSize < employees.length) ? i + chunkSize : employees.length;
      final chunk = employees.sublist(i, end);

      await Future.wait(chunk.map((emp) => _processEmployeeFace(emp, servicesRepo, tempDir)));

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

  Future<void> _processEmployeeFace(
    EmployeeModel emp,
    ServicesRepo servicesRepo,
    Directory tempDir,
  ) async {
    if (emp.empCode == null) return;
    final empIdStr = emp.empCode.toString();

    try {
      final result = await servicesRepo.getEmployeeFaceImage(emp.empCode);

      await result.fold((failure) async {}, (base64Img) async {
        if (base64Img.isNotEmpty) {
          try {
            // 1. Calculate Signature of the image data (Length + Prefix)
            // This avoids adding the 'crypto' dependency while being safer than just length
            final prefixLen = base64Img.length > 50 ? 50 : base64Img.length;
            final signature = '${base64Img.length}_${base64Img.substring(0, prefixLen)}';

            List<double> features = [];

            // 2. Check Cache
            if (_featuresCache.containsKey(empIdStr)) {
              final cachedData = _featuresCache[empIdStr];
              if (cachedData['hash'] == signature && cachedData['features'] != null) {
                // Cache Hit! Use cached features
                features = List<double>.from(cachedData['features']);

                // We still need the file for display purposes in the list (UI uses FileImage)
                final tempFile = File('${tempDir.path}/remote_${emp.empCode}.jpg');
                if (!await tempFile.exists()) {
                  await tempFile.writeAsBytes(base64Decode(base64Img));
                }

                _addFaceToMemory(emp, tempFile, features);
                return; // Done
              }
            }

            // 3. Cache Miss (or signature mismatch) -> Run ML
            final bytes = base64Decode(base64Img);
            final tempFile = File('${tempDir.path}/remote_${emp.empCode}.jpg');
            await tempFile.writeAsBytes(bytes);

            final faces = await faceDetectionService.detectFacesInFile(tempFile);
            if (faces.isNotEmpty) {
              features = faceDetectionService.extractFaceFeatures(faces.first);
              if (features.isNotEmpty) {
                // 4. Update Cache
                _featuresCache[empIdStr] = {
                  'hash': signature,
                  'features': features,
                  'lastUpdated': DateTime.now().toIso8601String(),
                };

                _addFaceToMemory(emp, tempFile, features);
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
