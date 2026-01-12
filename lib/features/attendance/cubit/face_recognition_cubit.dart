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

  /// Process remote faces and store in memory
  Future<void> loadFacesFromRemote(List<EmployeeModel> employees, ServicesRepo servicesRepo) async {
    _remoteFaces.clear();
    _remoteFeaturesMap.clear();
    emit(FaceRecognitionLoading());

    final tempDir = await getTemporaryDirectory();

    for (var emp in employees) {
      if (emp.empCode == null) continue;

      try {
        final empCode = emp.empCode;
        final result = await servicesRepo.getEmployeeFaceImage(empCode);

        await result.fold((failure) async {}, (base64Img) async {
          if (base64Img.isNotEmpty) {
            try {
              // Decode and save to temp
              final bytes = base64Decode(base64Img);
              final tempFile = File('${tempDir.path}/remote_${empCode}.jpg');
              await tempFile.writeAsBytes(bytes);

              // Extract features
              final faces = await faceDetectionService.detectFacesInFile(tempFile);
              if (faces.isNotEmpty) {
                final features = faceDetectionService.extractFaceFeatures(faces.first);
                if (features.isNotEmpty) {
                  // Create Transient Model
                  final model = StudentFaceModel(
                    studentId: empCode.toString(),
                    studentName: emp.empName ?? emp.empNameE ?? '',
                    faceImagePath: tempFile.path, // Use temp path for display
                    registrationDate: DateTime.now(),
                    classId: 'employees',
                    faceMetadata: {'features': features},
                  );

                  _remoteFaces.add(model);
                  _remoteFeaturesMap[empCode.toString()] = features;
                }
              }
            } catch (e) {
              print('Error processing remote face for $empCode: $e');
            }
          }
        });
      } catch (e) {
        print('Error fetching remote face for $emp: $e');
      }
    }

    emit(FaceRecognitionRegisteredStudentsLoaded(_remoteFaces));
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
