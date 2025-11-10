import 'package:equatable/equatable.dart';

class UpdateVacationRequestBackModel extends Equatable {
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

  const UpdateVacationRequestBackModel({
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

  factory UpdateVacationRequestBackModel.fromJson(Map<String, dynamic> json) {
    return UpdateVacationRequestBackModel(
      requestId: json['Requestid'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      vacRequestDate: json['VacrequestDate'] ?? '',
      vacRequestDateH: json['VacrequestDateH'],
      vacRequestDateFrom: json['VacRequestDateFrom'] ?? '',
      vacRequestDateFromH: json['VacRequestDateFromH'],
      vacRequestDateTo: json['VacRequestDateTo'] ?? '',
      vacRequestDateToH: json['VacRequestDateToH'],
      vacDayCount: json['VacDayCount'] ?? 0,
      actualHolEndDate: json['ActualHolEndDate'] ?? '',
      lateDays: json['LateDays'] ?? 0,
      strNotes: json['strNotes'] ?? '',
      adminEmpCode: json['AdminEmpCode'] ?? 0,
      alternativeEmpCode: json['AlternativeEmpCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
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
