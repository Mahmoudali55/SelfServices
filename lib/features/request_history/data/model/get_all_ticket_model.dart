import 'dart:convert';

import 'package:equatable/equatable.dart';

class AllTicketModel extends Equatable {
  final int requestID;
  final int empDeptID;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int ticketcount;
  final String travelDate;
  final String? travelDateH;
  final String ticketPath;
  final int goback;
  final String strGoback;
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
  final String actionNotes;

  const AllTicketModel({
    required this.requestID,
    required this.empDeptID,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.ticketcount,
    required this.travelDate,
    this.travelDateH,
    required this.ticketPath,
    required this.goback,
    required this.strGoback,
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
    required this.actionNotes,
  });
  factory AllTicketModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      return int.tryParse(value.toString()) ?? 0;
    }

    return AllTicketModel(
      requestID: parseInt(json['RequestID']),
      empDeptID: parseInt(json['EmpDeptID']),
      empCode: parseInt(json['EmpCode']),
      requestDate: json['requestDate']?.toString() ?? '',
      requestDateH: json['RequestDateH']?.toString(),
      ticketcount: parseInt(json['Ticketcount']),
      travelDate: json['TravelDate']?.toString() ?? '',
      travelDateH: json['TravelDateH']?.toString(),
      ticketPath: json['TicketPath']?.toString() ?? '',
      goback: parseInt(json['Goback']),
      strGoback: json['strGoback']?.toString() ?? '',
      strNotes: json['strNotes']?.toString() ?? '',
      requestAuditorID: parseInt(json['RequestAuditorID']),
      empName: json['EMP_NAME']?.toString() ?? '',
      empNameE: json['EMP_NAME_E']?.toString() ?? '',
      dName: json['D_NAME']?.toString() ?? '',
      dNameE: json['D_NAME_E']?.toString(),
      reqDecideState: parseInt(json['ReqDecideState']),
      requestDesc: json['RequestDesc']?.toString() ?? '',
      reqDicidState: parseInt(json['ReqDicidState']),
      actionMakerEmpID: parseInt(json['ActionMakerEmpID']),
      actionNotes: json['ActionNotes']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
    requestID,
    empDeptID,
    empCode,
    requestDate,
    requestDateH,
    ticketcount,
    travelDate,
    travelDateH,
    ticketPath,
    goback,
    strGoback,
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
    actionNotes,
  ];
}

List<AllTicketModel> parseTicketRequests(String jsonString) {
  final Map<String, dynamic> decoded = json.decode(jsonString);
  final List<dynamic> dataList = json.decode(decoded['Data']);
  return dataList.map((e) => AllTicketModel.fromJson(e)).toList();
}
