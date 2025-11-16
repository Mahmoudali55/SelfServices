import 'dart:convert';

import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final int empCode;
  final String? empName;
  final String? empNameE;
  final int dCode;
  final String? dName;
  final String? dNameE;
  final int makerWork;
  final int jobId;
  final String? jobName;
  final String? jobNameEng;
  final int empBranch;
  final String? bNameAr;
  final String? bNameEn;
  final int naGroup;
  final String? projectName;
  final String? projectNameEn;

  const EmployeeModel({
    required this.empCode,
    this.empName,
    this.empNameE,
    required this.dCode,
    this.dName,
    this.dNameE,
    required this.makerWork,
    required this.jobId,
    this.jobName,
    this.jobNameEng,
    required this.empBranch,
    this.bNameAr,
    this.bNameEn,
    required this.naGroup,
    this.projectName,
    this.projectNameEn,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    dynamic parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      return 0;
    }

    return EmployeeModel(
      empCode: parseInt(json['EMP_CODE']),
      empName: json['EMP_NAME']?.toString(),
      empNameE: json['EMP_NAME_E']?.toString(),
      dCode: parseInt(json['D_CODE']),
      dName: json['D_NAME']?.toString(),
      dNameE: json['D_NAME_E']?.toString(),
      makerWork: parseInt(json['MAKER_WORK']),
      jobId: parseInt(json['JobId']),
      jobName: json['JobName']?.toString(),
      jobNameEng: json['JobNameEng']?.toString(),
      empBranch: parseInt(json['EMP_BRANCH']),
      bNameAr: json['BNAME']?.toString(),
      bNameEn: json['B_NAME']?.toString(),
      naGroup: parseInt(json['NA_GROUP']),
      projectName: json['projectName']?.toString(),
      projectNameEn: json['projectName_EN']?.toString(),
    );
  }

  static List<EmployeeModel> listFromJson(dynamic data) {
    try {
      if (data is String) {
        final List dataList = jsonDecode(data);
        return dataList.map((x) => EmployeeModel.fromJson(x)).toList();
      } else if (data is List) {
        return data.map((x) => EmployeeModel.fromJson(x)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  List<Object?> get props => [
    empCode,
    empName,
    empNameE,
    dCode,
    dName,
    dNameE,
    makerWork,
    jobId,
    jobName,
    jobNameEng,
    empBranch,
    bNameAr,
    bNameEn,
    naGroup,
    projectName,
    projectNameEn,
  ];
}
