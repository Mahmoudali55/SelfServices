import 'dart:convert';

import 'package:equatable/equatable.dart';

class EmployeeRequestsNotify extends Equatable {
  final List<RequestItem> data;

  const EmployeeRequestsNotify({required this.data});

  factory EmployeeRequestsNotify.fromJson(Map<String, dynamic> json) {
    final List<dynamic> parsedData = jsonDecode(json['Data'] as String);
    final List<RequestItem> items = parsedData
        .map((item) => RequestItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return EmployeeRequestsNotify(data: items);
  }

  Map<String, dynamic> toJson() {
    return {'Data': jsonEncode(data.map((item) => item.toJson()).toList())};
  }

  @override
  List<Object?> get props => [data];
}

class RequestItem extends Equatable {
  final int vacRequestId;
  final String? vacRequestDate; // تعديل هنا ليصبح اختياري
  final int empCode;
  final int reqDecideState;
  final String requestDesc;
  final int reqDicidState;
  final int reqtype;

  const RequestItem({
    required this.vacRequestId,
    this.vacRequestDate,
    required this.empCode,
    required this.reqDecideState,
    required this.requestDesc,
    required this.reqDicidState,
    required this.reqtype,
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    return RequestItem(
      vacRequestId: json['VacRequestId'] as int,
      vacRequestDate: json['VacrequestDate'] as String?, // دعم null
      empCode: json['EmpCode'] as int,
      reqDecideState: json['ReqDecideState'] as int,
      requestDesc: json['RequestDesc'] as String,
      reqDicidState: json['ReqDicidState'] as int,
      reqtype: json['Reqtype'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'VacRequestId': vacRequestId,
      'VacrequestDate': vacRequestDate,
      'EmpCode': empCode,
      'ReqDecideState': reqDecideState,
      'RequestDesc': requestDesc,
      'ReqDicidState': reqDicidState,
      'Reqtype': reqtype,
    };
  }

  @override
  List<Object?> get props => [
    vacRequestId,
    vacRequestDate,
    empCode,
    reqDecideState,
    requestDesc,
    reqDicidState,
    reqtype,
  ];
}
