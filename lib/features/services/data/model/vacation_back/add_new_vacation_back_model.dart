import 'dart:convert';

import 'package:equatable/equatable.dart';

class AddNewVacationBackRequestModel extends Equatable {
  final int requestId;
  final int empCode;
  final String vacRequestDate;
  final String? vacRequestDateH;
  final String vacRequestDateFrom;
  final String? vacRequestDateFromH;
  final String vacRequestDateTo;
  final String? vacRequestDateToH;
  final int vacDayCount;
  final String actualHolEndDate;
  final int lateDays;
  final String strNotes;
  final int adminEmpCode;
  final int alternativeEmpCode;

  const AddNewVacationBackRequestModel({
    required this.requestId,
    required this.empCode,
    required this.vacRequestDate,
    this.vacRequestDateH,
    required this.vacRequestDateFrom,
    this.vacRequestDateFromH,
    required this.vacRequestDateTo,
    this.vacRequestDateToH,
    required this.vacDayCount,
    required this.actualHolEndDate,
    required this.lateDays,
    required this.strNotes,
    required this.adminEmpCode,
    required this.alternativeEmpCode,
  });

  factory AddNewVacationBackRequestModel.fromJson(Map<String, dynamic> json) {
    return AddNewVacationBackRequestModel(
      requestId: json['Requestid'],
      empCode: json['EmpCode'],
      vacRequestDate: json['VacrequestDate'],
      vacRequestDateH: json['VacrequestDateH'],
      vacRequestDateFrom: json['VacRequestDateFrom'],
      vacRequestDateFromH: json['VacRequestDateFromH'],
      vacRequestDateTo: json['VacRequestDateTo'],
      vacRequestDateToH: json['VacRequestDateToH'],
      vacDayCount: json['VacDayCount'],
      actualHolEndDate: json['ActualHolEndDate'],
      lateDays: json['LateDays'],
      strNotes: json['strNotes'],
      adminEmpCode: json['AdminEmpCode'],
      alternativeEmpCode: json['AlternativeEmpCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Requestid': requestId,
      'EmpCode': empCode,
      'VacrequestDate': vacRequestDate,
      'VacrequestDateH': vacRequestDateH,
      'VacRequestDateFrom': vacRequestDateFrom,
      'VacRequestDateFromH': vacRequestDateFromH,
      'VacRequestDateTo': vacRequestDateTo,
      'VacRequestDateToH': vacRequestDateToH,
      'VacDayCount': vacDayCount,
      'ActualHolEndDate': actualHolEndDate,
      'LateDays': lateDays,
      'strNotes': strNotes,
      'AdminEmpCode': adminEmpCode,
      'AlternativeEmpCode': alternativeEmpCode,
    };
  }

  static List<AddNewVacationBackRequestModel> listFromJson(String jsonStr) {
    final List<dynamic> data = json.decode(jsonStr);
    return data.map((e) => AddNewVacationBackRequestModel.fromJson(e)).toList();
  }

  static String listToJson(List<AddNewVacationBackRequestModel> list) {
    final data = list.map((e) => e.toJson()).toList();
    return json.encode(data);
  }

  @override
  List<Object?> get props => [
    requestId,
    empCode,
    vacRequestDate,
    vacRequestDateH,
    vacRequestDateFrom,
    vacRequestDateFromH,
    vacRequestDateTo,
    vacRequestDateToH,
    vacDayCount,
    actualHolEndDate,
    lateDays,
    strNotes,
    adminEmpCode,
    alternativeEmpCode,
  ];
}
