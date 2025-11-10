import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetAllVacationModel extends Equatable {
  final List<VacationRequestItem> data;

  const GetAllVacationModel({required this.data});

  factory GetAllVacationModel.fromJson(Map<String, dynamic> json) {
    final String dataString = json['Data'] as String;
    final List<dynamic> dataList = jsonDecode(dataString);

    return GetAllVacationModel(data: dataList.map((e) => VacationRequestItem.fromJson(e)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'Data': jsonEncode(data.map((e) => e.toJson()).toList())};
  }

  @override
  List<Object> get props => [data];
}

class VacationRequestItem extends Equatable {
  final int vacRequestId;
  final String vacRequestDate;
  final int vacTypeId;
  final String vacTypeName;
  final String vacRequestDateFrom;
  final String vacRequestDateTo;
  final String empDeptArName;
  final String? empDeptEngName;
  final String empName;
  final String empNameE;
  final int reqDecideState;
  final String requestDesc;
  final String strNotes;
  final String actionMakerEmpName;
  final String? branchName;

  const VacationRequestItem({
    required this.vacRequestId,
    required this.vacRequestDate,
    required this.vacTypeId,
    required this.vacTypeName,
    required this.vacRequestDateFrom,
    required this.vacRequestDateTo,
    required this.empDeptArName,
    this.empDeptEngName,
    required this.empName,
    required this.empNameE,
    required this.reqDecideState,
    required this.requestDesc,
    required this.strNotes,
    required this.actionMakerEmpName,
    this.branchName,
  });

  factory VacationRequestItem.fromJson(Map<String, dynamic> json) {
    return VacationRequestItem(
      vacRequestId: json['VacRequestId'] as int,
      vacRequestDate: json['VacrequestDate'] as String,
      vacTypeId: json['VacTypeId'] as int,
      vacTypeName: json['VacTypeName'] as String,
      vacRequestDateFrom: json['VacRequestDateFrom'] as String,
      vacRequestDateTo: json['VacRequestDateTo'] as String,
      empDeptArName: json['D_NAME'] as String,
      empDeptEngName: json['D_NAME_E'] as String?,
      empName: json['EMP_NAME'] as String,
      empNameE: json['EMP_NAME_E'] as String,
      reqDecideState: json['ReqDecideState'] as int,
      requestDesc: json['RequestDesc'] as String,
      strNotes: json['strNotes'] as String,
      actionMakerEmpName: json['AlternativeEMP_NAME'] as String,
      branchName: json['B_NAME'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'VacRequestId': vacRequestId,
      'VacrequestDate': vacRequestDate,
      'VacTypeId': vacTypeId,
      'VacTypeName': vacTypeName,
      'VacRequestDateFrom': vacRequestDateFrom,
      'VacRequestDateTo': vacRequestDateTo,
      'D_NAME': empDeptArName,
      'D_NAME_E': empDeptEngName,
      'EMP_NAME': empName,
      'EMP_NAME_E': empNameE,
      'ReqDecideState': reqDecideState,
      'RequestDesc': requestDesc,
      'strNotes': strNotes,
      'AlternativeEMP_NAME': actionMakerEmpName,
      'B_NAME': branchName,
    };
  }

  @override
  List<Object?> get props => [
    vacRequestId,
    vacRequestDate,
    vacTypeId,
    vacTypeName,
    vacRequestDateFrom,
    vacRequestDateTo,
    empDeptArName,
    empDeptEngName,
    empName,
    empNameE,
    reqDecideState,
    requestDesc,
    strNotes,
    actionMakerEmpName,
    branchName,
  ];
}
