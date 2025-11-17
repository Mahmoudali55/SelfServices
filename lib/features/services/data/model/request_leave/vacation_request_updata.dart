import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class VacationRequestUpdateModel extends Equatable {
  final int requestId;
  final int empCode;
  final String vacRequestDate;
  final String? vacRequestDateH;
  final int vacTypeId;
  final String vacRequestDateFrom;
  final String? vacRequestDateFromH;
  final String vacRequestDateTo;
  final String? vacRequestDateToH;
  final int vacDayCount;
  final String strNotes;
  final String serviceTypeDesc;
  final int? adminEmpCode;
  final int alternativeEmpCode;
  final List<Map<String, Object>> service;
  final List<AttachmentModel> attachment;

  const VacationRequestUpdateModel({
    required this.requestId,
    required this.empCode,
    required this.vacRequestDate,
    this.vacRequestDateH,
    required this.vacTypeId,
    required this.vacRequestDateFrom,
    this.vacRequestDateFromH,
    required this.vacRequestDateTo,
    this.vacRequestDateToH,
    required this.vacDayCount,
    required this.strNotes,
    required this.serviceTypeDesc,
    this.adminEmpCode,
    required this.alternativeEmpCode,
    required this.service,
    required this.attachment,
  });

  factory VacationRequestUpdateModel.fromJson(Map<String, dynamic> json) {
    return VacationRequestUpdateModel(
      requestId: json['Requestid'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      vacRequestDate: json['VacrequestDate'] ?? '',
      vacRequestDateH: json['VacrequestDateH'],
      vacTypeId: json['VacTypeId'] ?? 0,
      vacRequestDateFrom: json['VacRequestDateFrom'] ?? '',
      vacRequestDateFromH: json['VacRequestDateFromH'],
      vacRequestDateTo: json['VacRequestDateTo'] ?? '',
      vacRequestDateToH: json['VacRequestDateToH'],
      vacDayCount: json['VacDayCount'] ?? 0,
      strNotes: json['strNotes'] ?? '',
      serviceTypeDesc: json['ServiceTypeDesc'] ?? '',
      adminEmpCode: json['AdminEmpCode'],
      alternativeEmpCode: json['AlternativeEmpCode'] ?? 0,
      service: List<Map<String, Object>>.from(json['service'] ?? []),
      attachment: (json['Attachment'] as List<dynamic>)
          .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'Requestid': requestId,
    'EmpCode': empCode,
    'VacrequestDate': vacRequestDate,
    'VacRequestDateH': vacRequestDateH,
    'VacTypeId': vacTypeId,
    'VacRequestDateFrom': vacRequestDateFrom,
    'VacRequestDateFromH': vacRequestDateFromH,
    'VacRequestDateTo': vacRequestDateTo,
    'VacRequestDateToH': vacRequestDateToH,
    'VacDayCount': vacDayCount,
    'strNotes': strNotes,
    'ServiceTypeDesc': serviceTypeDesc,
    if (adminEmpCode != null) 'AdminEmpCode': adminEmpCode,
    'AlternativeEmpCode': alternativeEmpCode,
    'service': service,
    'Attachment': attachment.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    requestId,
    empCode,
    vacRequestDate,
    vacRequestDateH,
    vacTypeId,
    vacRequestDateFrom,
    vacRequestDateFromH,
    vacRequestDateTo,
    vacRequestDateToH,
    vacDayCount,
    strNotes,
    serviceTypeDesc,
    adminEmpCode,
    alternativeEmpCode,
    service,
    attachment,
  ];
}
