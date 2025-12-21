import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class UpdataRequestGeneralModel extends Equatable {
  final int requestId;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int requestTypeId;
  final String strField1;
  final String strField2;
  final String strNotes;
  final List<AttachmentModel> attachment;
  const UpdataRequestGeneralModel({
    required this.requestId,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.requestTypeId,
    required this.strField1,
    required this.strField2,
    required this.strNotes,
    required this.attachment,
  });

  factory UpdataRequestGeneralModel.fromJson(Map<String, dynamic> json) {
    return UpdataRequestGeneralModel(
      requestId: json['Requestid'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      requestDate: json['RequestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      requestTypeId: json['RequestTypeId'] ?? 0,
      strField1: json['StrField1'] ?? '',
      strNotes: json['StrNotes'] ?? '',
      strField2: json['StrField2'] ?? '',
      attachment: (json['Attachment'] as List<dynamic>)
          .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Requestid': requestId,
      'EmpCode': empCode,
      'RequestDate': requestDate,
      'RequestDateH': requestDateH,
      'RequestTypeId': requestTypeId,
      'StrField1': strField1,
      'StrField2': strField2,
      'StrNotes': strNotes,
      'Attachment': attachment.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    requestId,
    empCode,
    requestDate,
    requestDateH,
    requestTypeId,
    strField1,
    strField2,
    strNotes,
    attachment,
  ];
}
