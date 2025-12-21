import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class AddNewSolfaRquestModel extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final double solfaAmount;
  final int dofaaCount;
  final double dofaaAmount;
  final String startDicountDate;
  final String? startDicountDateH;
  final int frstEmpCode;
  final int scndEmpCode;
  final String strNotes;
  final int requestAuditorID;
  final int solfaTypeid;
  final List<AttachmentModel> attachment;

  const AddNewSolfaRquestModel({
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
    required this.requestAuditorID,
    required this.solfaTypeid,
    required this.attachment,
  });

  factory AddNewSolfaRquestModel.fromJson(Map<String, dynamic> json) {
    return AddNewSolfaRquestModel(
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
      requestAuditorID: json['RequestAuditorID'] ?? 0,
      solfaTypeid: json['SolfaTypeid'] ?? 0,
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
      'SolfaAmount': solfaAmount,
      'DofaaCount': dofaaCount,
      'DofaaAmount': dofaaAmount,
      'StartDicountDate': startDicountDate,
      'StartDicountDateH': startDicountDateH,
      'FrstEmpCode': frstEmpCode,
      'ScndEmpCode': scndEmpCode,
      'strNotes': strNotes,
      'RequestAuditorID': requestAuditorID,
      'SolfaTypeid': solfaTypeid,
      'Attachment': attachment.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
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
    requestAuditorID,
    solfaTypeid,
    attachment,
  ];
}
