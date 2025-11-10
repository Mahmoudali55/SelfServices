import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetAllCarsModel extends Equatable {
  final int requestID;
  final int empDeptID;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final String? strNotes;
  final String? purpose;
  final int requestAuditorID;
  final String empName;
  final String? empNameE;
  final String dName;
  final String? dNameE;
  final int reqDecideState;
  final String requestDesc;
  final int reqDicidState;
  final int actionMakerEmpID;
  final String? bName;
  final String? bNameE;
  final String? projectName;
  final String? projectNameEng;
  final int makerWork;
  final String? locationName;
  final int carTypeID;
  final String carTypeName;
  final String carTypeNameEng;

  const GetAllCarsModel({
    required this.requestID,
    required this.empDeptID,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    this.strNotes,
    this.purpose,
    required this.requestAuditorID,
    required this.empName,
    this.empNameE,
    required this.dName,
    this.dNameE,
    required this.reqDecideState,
    required this.requestDesc,
    required this.reqDicidState,
    required this.actionMakerEmpID,
    this.bName,
    this.bNameE,
    this.projectName,
    this.projectNameEng,
    required this.makerWork,
    this.locationName,
    required this.carTypeID,
    required this.carTypeName,
    required this.carTypeNameEng,
  });

  factory GetAllCarsModel.fromJson(Map<String, dynamic> json) {
    return GetAllCarsModel(
      requestID: json['RequestID'] as int,
      empDeptID: json['EmpDeptID'] as int,
      empCode: json['EmpCode'] as int,
      requestDate: json['requestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      strNotes: json['strNotes'],
      purpose: json['Purpose'],
      requestAuditorID: json['RequestAuditorID'] as int,
      empName: json['EMP_NAME'] ?? '',
      empNameE: json['EMP_NAME_E'],
      dName: json['D_NAME'] ?? '',
      dNameE: json['D_NAME_E'],
      reqDecideState: json['ReqDecideState'] as int,
      requestDesc: json['RequestDesc'] ?? '',
      reqDicidState: json['ReqDicidState'] as int,
      actionMakerEmpID: json['ActionMakerEmpID'] as int,
      bName: json['B_NAME'],
      bNameE: json['B_NAME_E'],
      projectName: json['ProjectName'],
      projectNameEng: json['ProjectNameEng'],
      makerWork: json['MAKER_WORK'] as int,
      locationName: json['locationname'],
      carTypeID: json['CarTypeID'] as int,
      carTypeName: json['CarTypeName'] ?? '',
      carTypeNameEng: json['CarTypeNameEng'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'RequestID': requestID,
    'EmpDeptID': empDeptID,
    'EmpCode': empCode,
    'requestDate': requestDate,
    'RequestDateH': requestDateH,
    'strNotes': strNotes,
    'Purpose': purpose,
    'RequestAuditorID': requestAuditorID,
    'EMP_NAME': empName,
    'EMP_NAME_E': empNameE,
    'D_NAME': dName,
    'D_NAME_E': dNameE,
    'ReqDecideState': reqDecideState,
    'RequestDesc': requestDesc,
    'ReqDicidState': reqDicidState,
    'ActionMakerEmpID': actionMakerEmpID,
    'B_NAME': bName,
    'B_NAME_E': bNameE,
    'ProjectName': projectName,
    'ProjectNameEng': projectNameEng,
    'MAKER_WORK': makerWork,
    'locationname': locationName,
    'CarTypeID': carTypeID,
    'CarTypeName': carTypeName,
    'CarTypeNameEng': carTypeNameEng,
  };

  static List<GetAllCarsModel> listFromMap(Map<String, dynamic> map) {
    final List<dynamic> dataList = json.decode(map['Data']);
    return dataList.map((e) => GetAllCarsModel.fromJson(e)).toList();
  }

  @override
  List<Object?> get props => [
    requestID,
    empDeptID,
    empCode,
    requestDate,
    requestDateH,
    strNotes,
    purpose,
    requestAuditorID,
    empName,
    empNameE,
    dName,
    dNameE,
    reqDecideState,
    requestDesc,
    reqDicidState,
    actionMakerEmpID,
    bName,
    bNameE,
    projectName,
    projectNameEng,
    makerWork,
    locationName,
    carTypeID,
    carTypeName,
    carTypeNameEng,
  ];
}
