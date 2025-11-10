import 'package:equatable/equatable.dart';

class UpdataRequestGeneralModel extends Equatable {
  final int requestId;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int requestTypeId;
  final String strField1;
  final String strNotes;

  const UpdataRequestGeneralModel({
    required this.requestId,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.requestTypeId,
    required this.strField1,
    required this.strNotes,
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
      'StrNotes': strNotes,
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
    strNotes,
  ];
}
