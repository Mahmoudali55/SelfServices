import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetSolfaModel extends Equatable {
  final List<SolfaItem> data;

  const GetSolfaModel({required this.data});

  factory GetSolfaModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['Data'] ?? '[]';
    final List<dynamic> list = jsonDecode(rawData);
    final solfaList = list.map((e) => SolfaItem.fromJson(e)).toList();
    return GetSolfaModel(data: solfaList);
  }
  Map<String, dynamic> toJson() => {'Data': jsonEncode(data.map((e) => e.toJson()).toList())};
  @override
  List<Object?> get props => [data];
}

class SolfaItem extends Equatable {
  final int requestId;
  final int empDeptId;
  final int empCode;
  final String requestDate;
  final int? requestDateH;
  final double solfaAmount;
  final int dofaaCount;
  final double dofaaAmount;
  final String? startDicountDate;
  final int? startDicountDateH;
  final int frstEmpCode;
  final int scndEmpCode;
  final String strNotes;
  final int requestAuditorId;
  final String empName;
  final String? empNameE;
  final String dName;
  final String? dNameE;
  final int reqDecideState;
  final String requestDesc;
  final int reqDicidState;
  final int actionMakerEmpId;
  final int solfaTypeId;
  final String? frstEmpName;
  final String? scndEmpName;
  final String? frstEmpNameE;
  final String? scndEmpNameE;
  final String solfaTypeName;
  final String? solfaTypeNameE;
  final String? actionNotes;
  const SolfaItem({
    required this.requestId,
    required this.empDeptId,
    required this.empCode,
    required this.requestDate,
    required this.requestDateH,
    required this.solfaAmount,
    required this.dofaaCount,
    required this.dofaaAmount,
    required this.startDicountDate,
    required this.startDicountDateH,
    required this.frstEmpCode,
    required this.scndEmpCode,
    required this.strNotes,
    required this.requestAuditorId,
    required this.empName,
    required this.empNameE,
    required this.dName,
    required this.dNameE,
    required this.reqDecideState,
    required this.requestDesc,
    required this.reqDicidState,
    required this.actionMakerEmpId,
    required this.solfaTypeId,
    required this.frstEmpName,
    required this.scndEmpName,
    required this.frstEmpNameE,
    required this.scndEmpNameE,
    required this.solfaTypeName,
    required this.solfaTypeNameE,
    required this.actionNotes,
  });
  factory SolfaItem.fromJson(Map<String, dynamic> json) {
    return SolfaItem(
      requestId: json['RequestID'] ?? 0,
      empDeptId: json['EmpDeptID'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      requestDate: json['requestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      solfaAmount: (json['SolfaAmount'] ?? 0).toDouble(),
      dofaaCount: json['DofaaCount'] ?? 0,
      dofaaAmount: (json['DofaaAmount'] ?? 0).toDouble(),
      startDicountDate: json['StartDicountDate'],
      startDicountDateH: json['StartDicountDateH'],
      frstEmpCode: json['FrstEmpCode'] ?? 0,
      scndEmpCode: json['ScndEmpCode'] ?? 0,
      strNotes: json['strNotes'] ?? '',
      requestAuditorId: json['RequestAuditorID'] ?? 0,
      empName: json['EMP_NAME'] ?? '',
      empNameE: json['EMP_NAME_E'],
      dName: json['D_NAME'] ?? '',
      dNameE: json['D_NAME_E'],
      reqDecideState: json['ReqDecideState'] ?? 0,
      requestDesc: json['RequestDesc'] ?? '',
      reqDicidState: json['ReqDicidState'] ?? 0,
      actionMakerEmpId: json['ActionMakerEmpID'] ?? 0,
      solfaTypeId: json['SolfaTypeid'] ?? 0,
      frstEmpName: json['FrstEmpName'],
      scndEmpName: json['ScndEmpName'],
      frstEmpNameE: json['FrstEmpName_E'],
      scndEmpNameE: json['ScndEmpName_E'],
      solfaTypeName: json['SolfaTypeName'] ?? '',
      solfaTypeNameE: json['SolfaTypeName_E'],
      actionNotes: json['actionnotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RequestID': requestId,
      'EmpDeptID': empDeptId,
      'EmpCode': empCode,
      'requestDate': requestDate,
      'RequestDateH': requestDateH,
      'SolfaAmount': solfaAmount,
      'DofaaCount': dofaaCount,
      'DofaaAmount': dofaaAmount,
      'StartDicountDate': startDicountDate,
      'StartDicountDateH': startDicountDateH,
      'FrstEmpCode': frstEmpCode,
      'ScndEmpCode': scndEmpCode,
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
      'SolfaTypeid': solfaTypeId,
      'FrstEmpName': frstEmpName,
      'ScndEmpName': scndEmpName,
      'FrstEmpName_E': frstEmpNameE,
      'ScndEmpName_E': scndEmpNameE,
      'SolfaTypeName': solfaTypeName,
      'SolfaTypeName_E': solfaTypeNameE,
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
    solfaAmount,
    dofaaCount,
    dofaaAmount,
    startDicountDate,
    startDicountDateH,
    frstEmpCode,
    scndEmpCode,
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
    solfaTypeId,
    frstEmpName,
    scndEmpName,
    frstEmpNameE,
    scndEmpNameE,
    solfaTypeName,
    solfaTypeNameE,
    actionNotes,
  ];
}
