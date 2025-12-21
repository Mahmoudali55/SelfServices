import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class UpdateResignationModel extends Equatable {
  final int requestId;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final String lastWorkDate;
  final String? lastWorkDateH;
  final String strNotes;
  final List<AttachmentModel> attachment;
  const UpdateResignationModel({
    required this.requestId,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.lastWorkDate,
    this.lastWorkDateH,
    required this.strNotes,
    required this.attachment,
  });

  factory UpdateResignationModel.fromJson(Map<String, dynamic> json) {
    return UpdateResignationModel(
      requestId: json['Requestid'],
      empCode: json['EmpCode'],
      requestDate: json['RequestDate'],
      requestDateH: json['RequestDateH'],
      lastWorkDate: json['LastWorkDate'],
      lastWorkDateH: json['LastWorkDateH'],
      strNotes: json['strNotes'],
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
      'LastWorkDate': lastWorkDate,
      'LastWorkDateH': lastWorkDateH,
      'strNotes': strNotes,
      'Attachment': attachment.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    requestId,
    empCode,
    requestDate,
    requestDateH,
    lastWorkDate,
    lastWorkDateH,
    strNotes,
    attachment,
  ];
}
