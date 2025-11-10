import 'dart:convert';

import 'package:equatable/equatable.dart';

class VacationRequestsRequestmodel extends Equatable {
  final List<VacationRequestOrdersModel> data;

  const VacationRequestsRequestmodel({required this.data});

  factory VacationRequestsRequestmodel.fromJson(Map<String, dynamic> json) {
    final String dataString = json['Data'] ?? '[]';
    final List decodedList = jsonDecode(dataString);
    return VacationRequestsRequestmodel(
      data: decodedList.map((x) => VacationRequestOrdersModel.fromJson(x)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {'Data': jsonEncode(data.map((x) => x.toJson()).toList())};

  @override
  List<Object?> get props => [data];
}

class VacationRequestOrdersModel extends Equatable {
  final int vacRequestId;
  final int empDeptId;
  final int empCode;
  final String vacRequestDate;
  final String strVacRequestDate;
  final int vacTypeId;
  final String vacRequestDateFrom;
  final String vacRequestDateTo;
  final String strVacRequestDateFrom;
  final String strVacRequestDateTo;
  final int vacDayCount;
  final String strNotes;
  final String empName;
  final String? empNameE;
  final String dName;
  final String? dNameE;
  final int reqDecideState;
  final String requestDesc;
  final int reqDicidState;
  final int actionMakerEmpId;
  final String attachFileName;
  final String serviceTypeDesc;
  final String? bName;
  final String vacTypeName;
  final int adminEmpCode;
  final int alternativeEmpCode;
  final String alternativeEmpName;
  final String? alternativeEmpNameE;

  const VacationRequestOrdersModel({
    required this.vacRequestId,
    required this.empDeptId,
    required this.empCode,
    required this.vacRequestDate,
    required this.strVacRequestDate,
    required this.vacTypeId,
    required this.vacRequestDateFrom,
    required this.vacRequestDateTo,
    required this.strVacRequestDateFrom,
    required this.strVacRequestDateTo,
    required this.vacDayCount,
    required this.strNotes,
    required this.empName,
    this.empNameE,
    required this.dName,
    this.dNameE,
    required this.reqDecideState,
    required this.requestDesc,
    required this.reqDicidState,
    required this.actionMakerEmpId,
    required this.attachFileName,
    required this.serviceTypeDesc,
    this.bName,
    required this.vacTypeName,
    required this.adminEmpCode,
    required this.alternativeEmpCode,
    required this.alternativeEmpName,
    this.alternativeEmpNameE,
  });

  factory VacationRequestOrdersModel.fromJson(Map<String, dynamic> json) {
    return VacationRequestOrdersModel(
      vacRequestId: json['VacRequestId'] ?? 0,
      empDeptId: json['EmpDeptID'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      vacRequestDate: json['VacrequestDate'] ?? '',
      strVacRequestDate: json['strVacrequestDate'] ?? '',
      vacTypeId: json['VacTypeId'] ?? 0,
      vacRequestDateFrom: json['VacRequestDateFrom'] ?? '',
      vacRequestDateTo: json['VacRequestDateTo'] ?? '',
      strVacRequestDateFrom: json['strVacRequestDateFrom'] ?? '',
      strVacRequestDateTo: json['strVacRequestDateTo'] ?? '',
      vacDayCount: json['VacDayCount'] ?? 0,
      strNotes: json['strNotes'] ?? '',
      empName: json['EMP_NAME'] ?? '',
      empNameE: json['EMP_NAME_E'],
      dName: json['D_NAME'] ?? '',
      dNameE: json['D_NAME_E'],
      reqDecideState: json['ReqDecideState'] ?? 0,
      requestDesc: json['RequestDesc'] ?? '',
      reqDicidState: json['ReqDicidState'] ?? 0,
      actionMakerEmpId: json['ActionMakerEmpID'] ?? 0,
      attachFileName: json['AttachFileName'] ?? '',
      serviceTypeDesc: json['ServiveTypeDesc'] ?? '',
      bName: json['B_NAME'],
      vacTypeName: json['VacTypeName'] ?? '',
      adminEmpCode: json['AdminEmpCode'] ?? 0,
      alternativeEmpCode: json['AlternativeEmpCode'] ?? 0,
      alternativeEmpName: json['AlternativeEMP_NAME'] ?? '',
      alternativeEmpNameE: json['AlternativeEMP_NAME_E'],
    );
  }

  Map<String, dynamic> toJson() => {
    'VacRequestId': vacRequestId,
    'EmpDeptID': empDeptId,
    'EmpCode': empCode,
    'VacrequestDate': vacRequestDate,
    'strVacrequestDate': strVacRequestDate,
    'VacTypeId': vacTypeId,
    'VacRequestDateFrom': vacRequestDateFrom,
    'VacRequestDateTo': vacRequestDateTo,
    'strVacRequestDateFrom': strVacRequestDateFrom,
    'strVacRequestDateTo': strVacRequestDateTo,
    'VacDayCount': vacDayCount,
    'strNotes': strNotes,
    'EMP_NAME': empName,
    'EMP_NAME_E': empNameE,
    'D_NAME': dName,
    'D_NAME_E': dNameE,
    'ReqDecideState': reqDecideState,
    'RequestDesc': requestDesc,
    'ReqDicidState': reqDicidState,
    'ActionMakerEmpID': actionMakerEmpId,
    'AttachFileName': attachFileName,
    'ServiveTypeDesc': serviceTypeDesc,
    'B_NAME': bName,
    'VacTypeName': vacTypeName,
    'AdminEmpCode': adminEmpCode,
    'AlternativeEmpCode': alternativeEmpCode,
    'AlternativeEMP_NAME': alternativeEmpName,
    'AlternativeEMP_NAME_E': alternativeEmpNameE,
  };

  @override
  List<Object?> get props => [
    vacRequestId,
    empDeptId,
    empCode,
    vacRequestDate,
    strVacRequestDate,
    vacTypeId,
    vacRequestDateFrom,
    vacRequestDateTo,
    strVacRequestDateFrom,
    strVacRequestDateTo,
    vacDayCount,
    strNotes,
    empName,
    empNameE,
    dName,
    dNameE,
    reqDecideState,
    requestDesc,
    reqDicidState,
    actionMakerEmpId,
    attachFileName,
    serviceTypeDesc,
    bName,
    vacTypeName,
    adminEmpCode,
    alternativeEmpCode,
    alternativeEmpName,
    alternativeEmpNameE,
  ];
}
