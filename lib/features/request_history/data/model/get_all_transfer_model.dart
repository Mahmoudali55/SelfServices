import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetAllTransferModel extends Equatable {
  final int requestId;
  final int fDep;
  final int branchCode;
  final int projId;
  final int empCode;
  final String requestDate;
  final String causes;
  final String dName;
  final String dNameE;
  final String bName;
  final String bNameE;
  final String projName;
  final String projEName;
  final int tDep;
  final int tBra;
  final int tProj;
  final String toDName;
  final String toDNameE;
  final String toBName;
  final String toBNameE;
  final String toProjName;
  final String toProjNameE;
  final int adminEmpCode;
  final String empName;
  final String empNameE;
  final int reqDecideState;
  final String causes1;
  final String requestDesc;
  final int reqDicidState;
  final int actionMakerEmpID;

  const GetAllTransferModel({
    required this.requestId,
    required this.fDep,
    required this.branchCode,
    required this.projId,
    required this.empCode,
    required this.requestDate,
    required this.causes,
    required this.dName,
    required this.dNameE,
    required this.bName,
    required this.bNameE,
    required this.projName,
    required this.projEName,
    required this.tDep,
    required this.tBra,
    required this.tProj,
    required this.toDName,
    required this.toDNameE,
    required this.toBName,
    required this.toBNameE,
    required this.toProjName,
    required this.toProjNameE,
    required this.adminEmpCode,
    required this.empName,
    required this.empNameE,
    required this.reqDecideState,
    required this.causes1,
    required this.requestDesc,
    required this.reqDicidState,
    required this.actionMakerEmpID,
  });

  factory GetAllTransferModel.fromJson(Map<String, dynamic> json) {
    return GetAllTransferModel(
      requestId: json['RequestID'] ?? 0,
      fDep: json['F_DEP'] ?? 0,
      branchCode: json['BranchCode'] ?? 0,
      projId: json['PROJ_ID'] ?? 0,
      empCode: json['EMP_CD'] ?? 0,
      requestDate: json['requestDate']?.toString() ?? '',
      causes: json['CAUSES']?.toString() ?? '',
      dName: json['D_NAME']?.toString() ?? '',
      dNameE: json['D_NAME_E']?.toString() ?? '',
      bName: json['B_NAME']?.toString() ?? '',
      bNameE: json['B_NAME_E']?.toString() ?? '',
      projName: json['PROJ_NAME']?.toString() ?? '',
      projEName: json['PROJ_ENAME']?.toString() ?? '',
      tDep: json['T_DEP'] ?? 0,
      tBra: json['T_BRA'] ?? 0,
      tProj: json['T_PROJ'] ?? 0,
      toDName: json['ToD_NAME']?.toString() ?? '',
      toDNameE: json['ToD_NAME_E']?.toString() ?? '',
      toBName: json['ToB_NAME']?.toString() ?? '',
      toBNameE: json['ToB_NAME_E']?.toString() ?? '',
      toProjName: json['ToPROJ_NAME']?.toString() ?? '',
      toProjNameE: json['ToPROJ_NAME_E']?.toString() ?? '',
      adminEmpCode: json['AdminEmpCode'] ?? 0,
      empName: json['EMP_NAME']?.toString() ?? '',
      empNameE: json['EMP_NAME_E']?.toString() ?? '',
      reqDecideState: json['ReqDecideState'] ?? 0,
      causes1: json['CAUSES1']?.toString() ?? '',
      requestDesc: json['RequestDesc']?.toString() ?? '',
      reqDicidState: json['ReqDicidState'] ?? 0,
      actionMakerEmpID: json['ActionMakerEmpID'] ?? 0,
    );
  }

  static List<GetAllTransferModel> listFromResponse(String responseBody) {
    final decoded = jsonDecode(responseBody);
    final dataString = decoded['Data'];
    final List<dynamic> dataList = jsonDecode(dataString);
    return dataList.map((x) => GetAllTransferModel.fromJson(x)).toList();
  }

  @override
  List<Object?> get props => [
    requestId,
    fDep,
    branchCode,
    projId,
    empCode,
    requestDate,
    causes,
    dName,
    dNameE,
    bName,
    bNameE,
    projName,
    projEName,
    tDep,
    tBra,
    tProj,
    toDName,
    toDNameE,
    toBName,
    toBNameE,
    toProjName,
    toProjNameE,
    adminEmpCode,
    empName,
    empNameE,
    reqDecideState,
    causes1,
    requestDesc,
    reqDicidState,
    actionMakerEmpID,
  ];
}
