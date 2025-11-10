import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetRequestVacationBackModel extends Equatable {
  final int vacRequestId;
  final int? empDeptID;
  final int? empCode;
  final String? vacRequestDate;
  final String? strVacrequestDate;
  final int? vacTypeId;
  final String? vacRequestDateFrom;
  final String? vacRequestDateTo;
  final String? strVacRequestDateFrom;
  final String? strVacRequestDateTo;
  final int? vacDayCount;
  final String? strNotes;
  final int? lateDays;
  final String? actualHolEndDate;
  final String? strActualHolEndDate;
  final String? empName;
  final String? empNameE;
  final String? dName;
  final String? dNameE;
  final int? reqDecideState;
  final String? requestDesc;
  final int? reqDicidState;
  final int? actionMakerEmpID;
  final String? attachFileName;
  final String? serviceTypeDesc;
  final String? bName;
  final int? adminEmpCode;
  final int? alternativeEmpCode;
  final String? alternativeEmpName;
  final String? alternativeEmpNameE;

  const GetRequestVacationBackModel({
    required this.vacRequestId,
    this.empDeptID,
    this.empCode,
    this.vacRequestDate,
    this.strVacrequestDate,
    this.vacTypeId,
    this.vacRequestDateFrom,
    this.vacRequestDateTo,
    this.strVacRequestDateFrom,
    this.strVacRequestDateTo,
    this.vacDayCount,
    this.strNotes,
    this.lateDays,
    this.actualHolEndDate,
    this.strActualHolEndDate,
    this.empName,
    this.empNameE,
    this.dName,
    this.dNameE,
    this.reqDecideState,
    this.requestDesc,
    this.reqDicidState,
    this.actionMakerEmpID,
    this.attachFileName,
    this.serviceTypeDesc,
    this.bName,
    this.adminEmpCode,
    this.alternativeEmpCode,
    this.alternativeEmpName,
    this.alternativeEmpNameE,
  });

  factory GetRequestVacationBackModel.fromJson(Map<String, dynamic> json) {
    return GetRequestVacationBackModel(
      vacRequestId: json['VacRequestId'] ?? 0,
      empDeptID: json['EmpDeptID'],
      empCode: json['EmpCode'],
      vacRequestDate: json['VacrequestDate'],
      strVacrequestDate: json['strVacrequestDate'],
      vacTypeId: json['VacTypeId'],
      vacRequestDateFrom: json['VacRequestDateFrom'],
      vacRequestDateTo: json['VacRequestDateTo'],
      strVacRequestDateFrom: json['strVacRequestDateFrom'],
      strVacRequestDateTo: json['strVacRequestDateTo'],
      vacDayCount: json['VacDayCount'],
      strNotes: json['strNotes'],
      lateDays: json['LateDays'],
      actualHolEndDate: json['ActualHolEndDate'],
      strActualHolEndDate: json['strActualHolEndDate'],
      empName: json['EMP_NAME'],
      empNameE: json['EMP_NAME_E'],
      dName: json['D_NAME'],
      dNameE: json['D_NAME_E'],
      reqDecideState: json['ReqDecideState'],
      requestDesc: json['RequestDesc'],
      reqDicidState: json['ReqDicidState'],
      actionMakerEmpID: json['ActionMakerEmpID'],
      attachFileName: json['AttachFileName'],
      serviceTypeDesc: json['ServiveTypeDesc'],
      bName: json['B_NAME'],
      adminEmpCode: json['AdminEmpCode'],
      alternativeEmpCode: json['AlternativeEmpCode'],
      alternativeEmpName: json['AlternativeEMP_NAME'],
      alternativeEmpNameE: json['AlternativeEMP_NAME_E'],
    );
  }

  static List<GetRequestVacationBackModel> listFromResponse(Map<String, dynamic> response) {
    final dataString = response['Data'] ?? '[]';
    final List<dynamic> dataList = jsonDecode(dataString);
    return dataList
        .map((e) => GetRequestVacationBackModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<Object?> get props => [
    vacRequestId,
    empDeptID,
    empCode,
    vacRequestDate,
    strVacrequestDate,
    vacTypeId,
    vacRequestDateFrom,
    vacRequestDateTo,
    strVacRequestDateFrom,
    strVacRequestDateTo,
    vacDayCount,
    strNotes,
    lateDays,
    actualHolEndDate,
    strActualHolEndDate,
    empName,
    empNameE,
    dName,
    dNameE,
    reqDecideState,
    requestDesc,
    reqDicidState,
    actionMakerEmpID,
    attachFileName,
    serviceTypeDesc,
    bName,
    adminEmpCode,
    alternativeEmpCode,
    alternativeEmpName,
    alternativeEmpNameE,
  ];

  Map<String, dynamic> toJson() {
    return {
      'VacRequestId': vacRequestId,
      'EmpDeptID': empDeptID,
      'EmpCode': empCode,
      'VacrequestDate': vacRequestDate,
      'strVacrequestDate': strVacrequestDate,
      'VacTypeId': vacTypeId,
      'VacRequestDateFrom': vacRequestDateFrom,
      'VacRequestDateTo': vacRequestDateTo,
      'strVacRequestDateFrom': strVacRequestDateFrom,
      'strVacRequestDateTo': strVacRequestDateTo,
      'VacDayCount': vacDayCount,
      'strNotes': strNotes,
      'LateDays': lateDays,
      'ActualHolEndDate': actualHolEndDate,
      'strActualHolEndDate': strActualHolEndDate,
      'EMP_NAME': empName,
      'EMP_NAME_E': empNameE,
      'D_NAME': dName,
      'D_NAME_E': dNameE,
      'ReqDecideState': reqDecideState,
      'RequestDesc': requestDesc,
      'ReqDicidState': reqDicidState,
      'ActionMakerEmpID': actionMakerEmpID,
      'AttachFileName': attachFileName,
      'ServiveTypeDesc': serviceTypeDesc,
      'B_NAME': bName,
      'AdminEmpCode': adminEmpCode,
      'AlternativeEmpCode': alternativeEmpCode,
      'AlternativeEMP_NAME': alternativeEmpName,
      'AlternativeEMP_NAME_E': alternativeEmpNameE,
    };
  }
}
