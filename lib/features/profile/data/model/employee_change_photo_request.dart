import 'package:equatable/equatable.dart';

class EmployeeChangePhotoRequest extends Equatable {
  final int empId;
  final String empPhotoWeb;

  const EmployeeChangePhotoRequest({required this.empId, required this.empPhotoWeb});

  factory EmployeeChangePhotoRequest.fromJson(Map<String, dynamic> json) {
    return EmployeeChangePhotoRequest(
      empId: json['emp_id'] as int,
      empPhotoWeb: json['EMP_Photo_Web'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'emp_id': empId, 'EMP_Photo_Web': empPhotoWeb};
  }

  @override
  List<Object?> get props => [empId, empPhotoWeb];
}
