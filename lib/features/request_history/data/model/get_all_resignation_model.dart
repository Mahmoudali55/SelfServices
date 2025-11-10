import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetAllResignationModel extends Equatable {
  final int requestID;
  final int empDeptID;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final String lastWorkDate;
  final String? lastWorkDateH;
  final String strNotes;
  final int requestAuditorID;
  final String empName;
  final String empNameE;
  final String dName;
  final String? dNameE;
  final int reqDecideState;
  final String requestDesc;
  final int reqDicidState;
  final int actionMakerEmpID;

  const GetAllResignationModel({
    required this.requestID,
    required this.empDeptID,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.lastWorkDate,
    this.lastWorkDateH,
    required this.strNotes,
    required this.requestAuditorID,
    required this.empName,
    required this.empNameE,
    required this.dName,
    this.dNameE,
    required this.reqDecideState,
    required this.requestDesc,
    required this.reqDicidState,
    required this.actionMakerEmpID,
  });

  factory GetAllResignationModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return GetAllResignationModel(
      requestID: parseInt(json['RequestID']),
      empDeptID: parseInt(json['EmpDeptID']),
      empCode: parseInt(json['EmpCode']),
      requestDate: parseString(json['requestDate']),
      requestDateH: json['RequestDateH']?.toString(),
      lastWorkDate: parseString(json['LastWorkDate']),
      lastWorkDateH: json['LastWorkDateH']?.toString(),
      strNotes: parseString(json['strNotes']),
      requestAuditorID: parseInt(json['RequestAuditorID']),
      empName: parseString(json['EMP_NAME']),
      empNameE: parseString(json['EMP_NAME_E']),
      dName: parseString(json['D_NAME']),
      dNameE: json['D_NAME_E']?.toString(),
      reqDecideState: parseInt(json['ReqDecideState']),
      requestDesc: parseString(json['RequestDesc']),
      reqDicidState: parseInt(json['ReqDicidState']),
      actionMakerEmpID: parseInt(json['ActionMakerEmpID']),
    );
  }

  @override
  List<Object?> get props => [
    requestID,
    empDeptID,
    empCode,
    requestDate,
    requestDateH,
    lastWorkDate,
    lastWorkDateH,
    strNotes,
    requestAuditorID,
    empName,
    empNameE,
    dName,
    dNameE,
    reqDecideState,
    requestDesc,
    reqDicidState,
    actionMakerEmpID,
  ];
}

List<GetAllResignationModel> getAllResignationFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> dataList = jsonData['Data'] ?? [];
  return dataList.map((e) => GetAllResignationModel.fromJson(e)).toList();
}
