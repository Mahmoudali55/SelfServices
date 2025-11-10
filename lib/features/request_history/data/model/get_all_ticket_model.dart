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
  });

  factory AllTicketModel.fromJson(Map<String, dynamic> json) {
    return AllTicketModel(
      requestID: json['RequestID'],
      empDeptID: json['EmpDeptID'],
      empCode: json['EmpCode'],
      requestDate: json['requestDate'],
      requestDateH: json['RequestDateH'],
      ticketcount: json['Ticketcount'],
      travelDate: json['TravelDate'],
      travelDateH: json['TravelDateH'],
      ticketPath: json['TicketPath'],
      goback: json['Goback'],
      strGoback: json['strGoback'],
      strNotes: json['strNotes'],
      requestAuditorID: json['RequestAuditorID'],
      empName: json['EMP_NAME'],
      empNameE: json['EMP_NAME_E'],
      dName: json['D_NAME'],
      dNameE: json['D_NAME_E'],
      reqDecideState: json['ReqDecideState'],
      requestDesc: json['RequestDesc'],
      reqDicidState: json['ReqDicidState'],
      actionMakerEmpID: json['ActionMakerEmpID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RequestID': requestID,
      'EmpDeptID': empDeptID,
      'EmpCode': empCode,
      'requestDate': requestDate,
      'RequestDateH': requestDateH,
      'Ticketcount': ticketcount,
      'TravelDate': travelDate,
      'TravelDateH': travelDateH,
      'TicketPath': ticketPath,
      'Goback': goback,
      'strGoback': strGoback,
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
      ];
}


List<AllTicketModel> parseTicketRequests(String jsonString) {
  final Map<String, dynamic> decoded = json.decode(jsonString);
  final List<dynamic> dataList = json.decode(decoded['Data']);
  return dataList.map((e) => AllTicketModel.fromJson(e)).toList();
}
