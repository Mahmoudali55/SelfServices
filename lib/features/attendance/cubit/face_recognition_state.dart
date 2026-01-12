part of 'face_recognition_cubit.dart';

abstract class FaceRecognitionState extends Equatable {
  const FaceRecognitionState();

  @override
  List<Object?> get props => [];
}

class FaceRecognitionInitial extends FaceRecognitionState {}

class FaceRecognitionLoading extends FaceRecognitionState {}

class FaceRecognitionProcessing extends FaceRecognitionState {}

class FaceRecognitionCameraInitializing extends FaceRecognitionState {}

class FaceRecognitionCameraReady extends FaceRecognitionState {}

class FaceRecognitionFacesDetected extends FaceRecognitionState {
  final List<Face> faces;

  const FaceRecognitionFacesDetected(this.faces);

  @override
  List<Object?> get props => [faces];
}

class FaceRecognitionNoFaceDetected extends FaceRecognitionState {}

class FaceRecognitionRegistered extends FaceRecognitionState {
  final StudentFaceModel faceModel;

  const FaceRecognitionRegistered(this.faceModel);

  @override
  List<Object?> get props => [faceModel];
}

class FaceRecognitionStudentRecognized extends FaceRecognitionState {
  final StudentFaceModel student;
  final double confidence;

  const FaceRecognitionStudentRecognized({required this.student, required this.confidence});

  @override
  List<Object?> get props => [student, confidence];
}

class FaceRecognitionNoMatch extends FaceRecognitionState {
  final File? imageFile;
  final List<double>? features;
  final double? qualityScore;

  const FaceRecognitionNoMatch({this.imageFile, this.features, this.qualityScore});

  @override
  List<Object?> get props => [imageFile, features, qualityScore];
}

class FaceRecognitionRegisteredStudentsLoaded extends FaceRecognitionState {
  final List<StudentFaceModel> students;

  const FaceRecognitionRegisteredStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class FaceRecognitionFaceDeleted extends FaceRecognitionState {}

class FaceRecognitionCaptured extends FaceRecognitionState {
  final File imageFile;
  final List<double> features;
  final double qualityScore;

  const FaceRecognitionCaptured({
    required this.imageFile,
    required this.features,
    required this.qualityScore,
  });

  @override
  List<Object?> get props => [imageFile, features, qualityScore];
}

class FaceRecognitionError extends FaceRecognitionState {
  final String message;

  const FaceRecognitionError(this.message);

  @override
  List<Object?> get props => [message];
}

class FaceRecognitionSyncing extends FaceRecognitionState {
  final int total;
  final int processed;
  final String currentEmployee;

  const FaceRecognitionSyncing({
    required this.total,
    required this.processed,
    required this.currentEmployee,
  });

  @override
  List<Object?> get props => [total, processed, currentEmployee];
}

class FaceRecognitionSyncCompleted extends FaceRecognitionState {
  final int successCount;
  final int failCount;

  const FaceRecognitionSyncCompleted({required this.successCount, required this.failCount});

  @override
  List<Object?> get props => [successCount, failCount];
}
