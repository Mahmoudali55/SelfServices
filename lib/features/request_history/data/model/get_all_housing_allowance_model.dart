import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetAllHousingAllowanceModel extends Equatable {
  final int requestID;
  final int empDeptID;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final double sakanAmount;
  final int amountType;
  final String strAmountType;
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

  const GetAllHousingAllowanceModel({
    required this.requestID,
    required this.empDeptID,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.sakanAmount,
    required this.amountType,
    required this.strAmountType,
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

  factory GetAllHousingAllowanceModel.fromJson(Map<String, dynamic> json) {
    return GetAllHousingAllowanceModel(
      requestID: json['RequestID'] ?? 0,
      empDeptID: json['EmpDeptID'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      requestDate: json['requestDate'] ?? '',
      requestDateH: json['RequestDateH']?.toString(),
      sakanAmount: (json['SakanAmount'] ?? 0).toDouble(),
      amountType: json['AmountType'] ?? 0,
      strAmountType: json['strAmountType'] ?? '',
      strNotes: json['strNotes'] ?? '',
      requestAuditorID: json['RequestAuditorID'] ?? 0,
      empName: json['EMP_NAME'] ?? '',
      empNameE: json['EMP_NAME_E'] ?? '',
      dName: json['D_NAME'] ?? '',
      dNameE: json['D_NAME_E']?.toString(),
      reqDecideState: json['ReqDecideState'] ?? 0,
      requestDesc: json['RequestDesc'] ?? '',
      reqDicidState: json['ReqDicidState'] ?? 0,
      actionMakerEmpID: json['ActionMakerEmpID'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RequestID': requestID,
      'EmpDeptID': empDeptID,
      'EmpCode': empCode,
      'requestDate': requestDate,
      'RequestDateH': requestDateH,
      'SakanAmount': sakanAmount,
      'AmountType': amountType,
      'strAmountType': strAmountType,
      'strNotes': strNotes,
      'RequestAuditorID': requestAuditorID,
      'EMP_NAME': empName,
      'EMP_NAME_E': empNameE,
      'D_NAME': dName,
      'D_NAME_E': dNameE,
      'ReqDecideState': reqDecideState,
      'RequestDesc': requestDesc,
      'ReqDicidState': reqDicidState,
      'ActionMakerEmpID': actionMakerEmpID,
    };
  }

  @override
  List<Object?> get props => [
    requestID,
    empDeptID,
    empCode,
    requestDate,
    requestDateH,
    sakanAmount,
    amountType,
    strAmountType,
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

/// الدالة لتحويل JSON إلى List<GetAllHousingAllowanceModel>
List<GetAllHousingAllowanceModel> getAllHousingAllowanceFromJson(String str) {
  final jsonData = json.decode(str);
  final dataString = jsonData['Data'];

  // تحويل String إلى List<dynamic>
  final List<dynamic> list = dataString is String ? jsonDecode(dataString) : dataString;

  return list.map((e) => GetAllHousingAllowanceModel.fromJson(e)).toList();
}
