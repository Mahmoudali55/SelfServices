import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class ResignationRequestModel extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final String lastWorkDate;
  final String? lastWorkDateH;
  final String strNotes;
  final List<AttachmentModel> attachment;

  const ResignationRequestModel({
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.lastWorkDate,
    this.lastWorkDateH,
    required this.strNotes,
    required this.attachment,
  });

  factory ResignationRequestModel.fromJson(Map<String, dynamic> json) {
    return ResignationRequestModel(
      empCode: json['EmpCode'] as int,
      requestDate: json['RequestDate'] as String,
      requestDateH: json['RequestDateH'] as String?,
      lastWorkDate: json['LastWorkDate'] as String,
      lastWorkDateH: json['LastWorkDateH'] as String?,
      strNotes: json['strNotes'] as String,
      attachment: (json['Attachment'] as List<dynamic>)
          .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EmpCode': empCode,
      'RequestDate': requestDate,
      'RequestDateH': requestDateH,
      'LastWorkDate': lastWorkDate,
      'LastWorkDateH': lastWorkDateH,
      'strNotes': strNotes,
      'Attachment': attachment.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    empCode,
    requestDate,
    requestDateH,
    lastWorkDate,
    lastWorkDateH,
    strNotes,
    attachment,
  ];
}
