import 'dart:convert';

import 'package:equatable/equatable.dart';

class DynamicOrderModel extends Equatable {
  final int requestId;
  final int empDeptId;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final String strNotes;
  final int requestAuditorId;
  final String empName;
  final String empNameE;
  final String dName;
  final String? dNameE;
  final int reqDecideState;
  final String requestDesc;
  final int reqDicidState;
  final int actionMakerEmpId;
  final String strField1;
  final String strField2;
  final String strField3;
  final String strField4;
  final String strField5;
  final String strField6;
  final String strField7;
  final String strField8;
  final String strField9;
  final String strField10;
  final String strField11;
  final String strField12;
  final String strField13;
  final String strField14;
  final String strField15;
  final String actionNotes;

  const DynamicOrderModel({
    required this.requestId,
    required this.empDeptId,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.strNotes,
    required this.requestAuditorId,
    required this.empName,
    required this.empNameE,
    required this.dName,
    this.dNameE,
    required this.reqDecideState,
    required this.requestDesc,
    required this.reqDicidState,
    required this.actionMakerEmpId,
    required this.strField1,
    required this.strField2,
    required this.strField3,
    required this.strField4,
    required this.strField5,
    required this.strField6,
    required this.strField7,
    required this.strField8,
    required this.strField9,
    required this.strField10,
    required this.strField11,
    required this.strField12,
    required this.strField13,
    required this.strField14,
    required this.strField15,
    required this.actionNotes,
  });

  factory DynamicOrderModel.fromJson(Map<String, dynamic> json) {
    return DynamicOrderModel(
      requestId: json['RequestID'] ?? 0,
      empDeptId: json['EmpDeptID'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      requestDate: json['requestDate']?.toString() ?? '',
      requestDateH: json['RequestDateH']?.toString(),
      strNotes: json['strNotes']?.toString() ?? '',
      requestAuditorId: json['RequestAuditorID'] ?? 0,
      empName: json['EMP_NAME']?.toString() ?? '',
      empNameE: json['EMP_NAME_E']?.toString() ?? '',
      dName: json['D_NAME']?.toString() ?? '',
      dNameE: json['D_NAME_E']?.toString(),
      reqDecideState: json['ReqDecideState'] ?? 0,
      requestDesc: json['RequestDesc']?.toString() ?? '',
      reqDicidState: json['ReqDicidState'] ?? 0,
      actionMakerEmpId: json['ActionMakerEmpID'] ?? 0,
      strField1: json['StrField1']?.toString() ?? '',
      strField2: json['StrField2']?.toString() ?? '',
      strField3: json['StrField3']?.toString() ?? '',
      strField4: json['StrField4']?.toString() ?? '',
      strField5: json['StrField5']?.toString() ?? '',
      strField6: json['StrField6']?.toString() ?? '',
      strField7: json['StrField7']?.toString() ?? '',
      strField8: json['StrField8']?.toString() ?? '',
      strField9: json['StrField9']?.toString() ?? '',
      strField10: json['StrField10']?.toString() ?? '',
      strField11: json['StrField11']?.toString() ?? '',
      strField12: json['StrField12']?.toString() ?? '',
      strField13: json['StrField13']?.toString() ?? '',
      strField14: json['StrField14']?.toString() ?? '',
      strField15: json['StrField15']?.toString() ?? '',
      actionNotes: json['actionnotes']?.toString() ?? '',
    );
  }

  factory DynamicOrderModel.fromMap(Map<String, dynamic> map) {
    return DynamicOrderModel.fromJson(map);
  }

  static List<DynamicOrderModel> fromJsonList(String jsonString) {
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.map((item) => DynamicOrderModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'RequestID': requestId,
      'EmpDeptID': empDeptId,
      'EmpCode': empCode,
      'requestDate': requestDate,
      'RequestDateH': requestDateH,
      'strNotes': strNotes,
      'RequestAuditorID': requestAuditorId,
      'EMP_NAME': empName,
      'EMP_NAME_E': empNameE,
      'D_NAME': dName,
      'D_NAME_E': dNameE,
      'ReqDecideState': reqDecideState,
      'RequestDesc': requestDesc,
      'ReqDicidState': reqDicidState,
      'ActionMakerEmpID': actionMakerEmpId,
      'StrField1': strField1,
      'StrField2': strField2,
      'StrField3': strField3,
      'StrField4': strField4,
      'StrField5': strField5,
      'StrField6': strField6,
      'StrField7': strField7,
      'StrField8': strField8,
      'StrField9': strField9,
      'StrField10': strField10,
      'StrField11': strField11,
      'StrField12': strField12,
      'StrField13': strField13,
      'StrField14': strField14,
      'StrField15': strField15,
      'actionnotes': actionNotes,
    };
  }

  @override
  List<Object?> get props => [
    requestId,
    empDeptId,
    empCode,
    requestDate,
    requestDateH,
    strNotes,
    requestAuditorId,
    empName,
    empNameE,
    dName,
    dNameE,
    reqDecideState,
    requestDesc,
    reqDicidState,
    actionMakerEmpId,
    strField1,
    strField2,
    strField3,
    strField4,
    strField5,
    strField6,
    strField7,
    strField8,
    strField9,
    strField10,
    strField11,
    strField12,
    strField13,
    strField14,
    strField15,
    actionNotes,
  ];
}
