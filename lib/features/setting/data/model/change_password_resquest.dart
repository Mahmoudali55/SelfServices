import 'package:equatable/equatable.dart';

class ChangePasswordRequest extends Equatable {
  final int empId;
  final String userPassword;

  const ChangePasswordRequest({required this.empId, required this.userPassword});

  Map<String, dynamic> toJson() => {'EmpId': empId, 'UserPswrd': userPassword};

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      empId: json['EmpId'] as int,
      userPassword: json['UserPswrd'] as String,
    );
  }

  @override
  List<Object> get props => [empId, userPassword];
}
