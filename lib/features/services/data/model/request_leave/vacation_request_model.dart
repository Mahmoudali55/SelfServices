import 'package:equatable/equatable.dart';

class AttachmentModel extends Equatable {
  final String attachmentName;
  final String attachmentFileName;

  const AttachmentModel({required this.attachmentName, required this.attachmentFileName});

  factory AttachmentModel.fromJson(Map<String, dynamic> json) => AttachmentModel(
    attachmentName: json['AttatchmentName'] as String,
    attachmentFileName: json['AttchmentFileName'] as String,
  );

  Map<String, dynamic> toJson() => {
    'AttatchmentName': attachmentName,
    'AttchmentFileName': attachmentFileName,
  };

  @override
  List<Object?> get props => [attachmentName, attachmentFileName];
}

class VacationRequestModel extends Equatable {
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
  final int adminEmpCode;
  final int alternativeEmpCode;
  final List<Map<String, Object>> service;
  final List<AttachmentModel> attachment;

  const VacationRequestModel({
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
    required this.adminEmpCode,
    required this.alternativeEmpCode,
    required this.service,
    required this.attachment,
  });

  factory VacationRequestModel.fromJson(Map<String, dynamic> json) {
    return VacationRequestModel(
      empCode: json['EmpCode'] as int,
      vacRequestDate: json['VacrequestDate'] as String,
      vacRequestDateH: json['VacrequestDateH'] as String?,
      vacTypeId: json['VacTypeId'] as int,
      vacRequestDateFrom: json['VacRequestDateFrom'] as String,
      vacRequestDateFromH: json['VacRequestDateFromH'] as String?,
      vacRequestDateTo: json['VacRequestDateTo'] as String,
      vacRequestDateToH: json['VacRequestDateToH'] as String?,
      vacDayCount: json['VacDayCount'] as int,
      strNotes: json['strNotes'] as String,
      serviceTypeDesc: json['ServiceTypeDesc'] as String,
      adminEmpCode: json['AdminEmpCode'] as int,
      alternativeEmpCode: json['AlternativeEmpCode'] as int,
      service: List<Map<String, Object>>.from(json['service']),
      attachment: (json['Attachment'] as List<dynamic>)
          .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'EmpCode': empCode,
    'VacrequestDate': vacRequestDate,
    'VacrequestDateH': vacRequestDateH,
    'VacTypeId': vacTypeId,
    'VacRequestDateFrom': vacRequestDateFrom,
    'VacRequestDateFromH': vacRequestDateFromH,
    'VacRequestDateTo': vacRequestDateTo,
    'VacRequestDateToH': vacRequestDateToH,
    'VacDayCount': vacDayCount,
    'strNotes': strNotes,
    'ServiceTypeDesc': serviceTypeDesc,
    'AdminEmpCode': adminEmpCode,
    'AlternativeEmpCode': alternativeEmpCode,
    'service': service,
    'Attachment': attachment.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
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
