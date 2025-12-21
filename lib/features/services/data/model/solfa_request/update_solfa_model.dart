import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class UpdateSolfaModel extends Equatable {
  final int requestId;
  final int empCode;
  final String requestDate;
  final int? requestDateH;
  final double solfaAmount;
  final int dofaaCount;
  final double dofaaAmount;
  final String startDicountDate;
  final int? startDicountDateH;
  final int frstEmpCode;
  final int scndEmpCode;
  final String strNotes;
  final int requestAuditorId;
  final int solfaTypeId;
  final List<AttachmentModel> attachment;

  const UpdateSolfaModel({
    required this.requestId,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.solfaAmount,
    required this.dofaaCount,
    required this.dofaaAmount,
    required this.startDicountDate,
    this.startDicountDateH,
    required this.frstEmpCode,
    required this.scndEmpCode,
    required this.strNotes,
    required this.requestAuditorId,
    required this.solfaTypeId,
    required this.attachment,
  });

  factory UpdateSolfaModel.fromJson(Map<String, dynamic> json) {
    return UpdateSolfaModel(
      requestId: json['Requestid'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      requestDate: json['RequestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      solfaAmount: (json['SolfaAmount'] ?? 0).toDouble(),
      dofaaCount: json['DofaaCount'] ?? 0,
      dofaaAmount: (json['DofaaAmount'] ?? 0).toDouble(),
      startDicountDate: json['StartDicountDate'] ?? '',
      startDicountDateH: json['StartDicountDateH'],
      frstEmpCode: json['FrstEmpCode'] ?? 0,
      scndEmpCode: json['ScndEmpCode'] ?? 0,
      strNotes: json['strNotes'] ?? '',
      requestAuditorId: json['RequestAuditorID'] ?? 0,
      solfaTypeId: json['SolfaTypeid'] ?? 0,
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
      'SolfaAmount': solfaAmount,
      'DofaaCount': dofaaCount,
      'DofaaAmount': dofaaAmount,
      'StartDicountDate': startDicountDate,
      'StartDicountDateH': startDicountDateH,
      'FrstEmpCode': frstEmpCode,
      'ScndEmpCode': scndEmpCode,
      'strNotes': strNotes,
      'RequestAuditorID': requestAuditorId,
      'SolfaTypeid': solfaTypeId,
      'Attachment': attachment.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    requestId,
    empCode,
    requestDate,
    requestDateH,
    solfaAmount,
    dofaaCount,
    dofaaAmount,
    startDicountDate,
    startDicountDateH,
    frstEmpCode,
    scndEmpCode,
    strNotes,
    requestAuditorId,
    solfaTypeId,
    attachment,
  ];
}
