import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetEmployeeModel extends Equatable {
  final int empCode;
  final String empArName;
  final String empEngName;
  final String empName;
  final String empNameE;

  const GetEmployeeModel({
    required this.empCode,
    required this.empArName,
    required this.empEngName,
    required this.empName,
    required this.empNameE,
  });

  factory GetEmployeeModel.fromJson(Map<String, dynamic> json) {
    return GetEmployeeModel(
      empCode: json['EmpCode'] ?? 0,
      empArName: json['EmpArName'] ?? '',
      empEngName: json['EmpEngName'] ?? '',
      empName: json['EMP_NAME'] ?? '',
      empNameE: json['EMP_NAME_E'] ?? '',
    );
  }

  static List<GetEmployeeModel> listFromResponse(dynamic response) {
    final String dataStr = response['Data'] ?? '[]';
    final List<dynamic> data = List<Map<String, dynamic>>.from(json.decode(dataStr));
    return data.map((e) => GetEmployeeModel.fromJson(e)).toList();
  }

  String getName(String langCode) {
    if (langCode == 'en' && empNameE.isNotEmpty) {
      return empNameE;
    }
    return empName;
  }

  @override
  List<Object?> get props => [empCode, empArName, empEngName, empName, empNameE];
}
