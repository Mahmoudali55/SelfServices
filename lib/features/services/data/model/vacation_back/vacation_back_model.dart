import 'dart:convert';

import 'package:equatable/equatable.dart';

class VacationBackRequestModel extends Equatable {
  final int vacRequestId;
  final int empDeptID;
  final int requestId;
  final int empCode;
  final int empId;
  final String vacRequestDate;
  final String? vacRequestDateH;
  final int vacTypeId;
  final String vacRequestDateFrom;
  final String? vacRequestDateFromH;
  final String vacRequestDateTo;
  final String? vacRequestDateToH;
  final int vacDayCount;
  final String strNotes;
  final String empName;
  final String empNameE;
  final String dName;
  final String? dNameE;
  final int reqDecideState;
  final String attachFileName;
  final String serviveTypeDesc;
  final String strDateFrom;
  final String strDateTo;
  final String insrtDate;
  final String vacTypeName;
  final int branchCode;
  final String branchName;
  final int empGroupId;
  final int empDeptID2;
  final int projId;
  final String projName;
  final String projEName;
  final int adminEmpCode;
  final int alternativeEmpCode;
  final String alternativeEmpName;
  final String alternativeEmpNameE;

  const VacationBackRequestModel({
    required this.vacRequestId,
    required this.empDeptID,
    required this.requestId,
    required this.empCode,
    required this.empId,
    required this.vacRequestDate,
    this.vacRequestDateH,
    required this.vacTypeId,
    required this.vacRequestDateFrom,
    this.vacRequestDateFromH,
    required this.vacRequestDateTo,
    this.vacRequestDateToH,
    required this.vacDayCount,
    required this.strNotes,
    required this.empName,
    required this.empNameE,
    required this.dName,
    this.dNameE,
    required this.reqDecideState,
    required this.attachFileName,
    required this.serviveTypeDesc,
    required this.strDateFrom,
    required this.strDateTo,
    required this.insrtDate,
    required this.vacTypeName,
    required this.branchCode,
    required this.branchName,
    required this.empGroupId,
    required this.empDeptID2,
    required this.projId,
    required this.projName,
    required this.projEName,
    required this.adminEmpCode,
    required this.alternativeEmpCode,
    required this.alternativeEmpName,
    required this.alternativeEmpNameE,
  });

  factory VacationBackRequestModel.fromJson(Map<String, dynamic> json) {
    return VacationBackRequestModel(
      vacRequestId: json['VacRequestId'] ?? 0,
      empDeptID: json['EmpDeptID'] ?? 0,
      requestId: json['RequestId'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      empId: json['EmpId'] ?? 0,
      vacRequestDate: json['VacrequestDate'] ?? '',
      vacRequestDateH: json['VacrequestDateH'],
      vacTypeId: json['VacTypeId'] ?? 0,
      vacRequestDateFrom: json['VacRequestDateFrom'] ?? '',
      vacRequestDateFromH: json['VacRequestDateFromH'],
      vacRequestDateTo: json['VacRequestDateTo'] ?? '',
      vacRequestDateToH: json['VacRequestDateToH'],
      vacDayCount: json['VacDayCount'] ?? 0,
      strNotes: json['strNotes'] ?? '',
      empName: json['EMP_NAME'] ?? '',
      empNameE: json['EMP_NAME_E'] ?? '',
      dName: json['D_NAME'] ?? '',
      dNameE: json['D_NAME_E'],
      reqDecideState: json['ReqDecideState'] ?? 0,
      attachFileName: json['AttachFileName'] ?? '',
      serviveTypeDesc: json['ServiveTypeDesc'] ?? '',
      strDateFrom: json['strDateFrom'] ?? '',
      strDateTo: json['strDateTo'] ?? '',
      insrtDate: json['InsrtDate'] ?? '',
      vacTypeName: json['VacTypeName'] ?? '',
      branchCode: json['BranchCode'] ?? 0,
      branchName: json['BranchName'] ?? '',
      empGroupId: json['EmpGroupId'] ?? 0,
      empDeptID2: json['EmpDeptID2'] ?? 0,
      projId: json['PROJ_ID'] ?? 0,
      projName: json['PROJ_NAME'] ?? '',
      projEName: json['PROJ_ENAME'] ?? '',
      adminEmpCode: json['AdminEmpCode'] ?? 0,
      alternativeEmpCode: json['AlternativeEmpCode'] ?? 0,
      alternativeEmpName: json['AlternativeEMP_NAME'] ?? '',
      alternativeEmpNameE: json['AlternativeEMP_NAME_E'] ?? '',
    );
  }

  static List<VacationBackRequestModel> listFromResponse(String jsonStr) {
    final Map<String, dynamic> map = json.decode(jsonStr);
    final List<dynamic> data = json.decode(map['Data']);
    return data.map((e) => VacationBackRequestModel.fromJson(e)).toList();
  }

  @override
  List<Object?> get props => [
    vacRequestId,
    empDeptID,
    requestId,
    empCode,
    empId,
    vacRequestDate,
    vacRequestDateH,
    vacTypeId,
    vacRequestDateFrom,
    vacRequestDateFromH,
    vacRequestDateTo,
    vacRequestDateToH,
    vacDayCount,
    strNotes,
    empName,
    empNameE,
    dName,
    dNameE,
    reqDecideState,
    attachFileName,
    serviveTypeDesc,
    strDateFrom,
    strDateTo,
    insrtDate,
    vacTypeName,
    branchCode,
    branchName,
    empGroupId,
    empDeptID2,
    projId,
    projName,
    projEName,
    adminEmpCode,
    alternativeEmpCode,
    alternativeEmpName,
    alternativeEmpNameE,
  ];
}
