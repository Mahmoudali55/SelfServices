import 'package:equatable/equatable.dart';

class ResignationRequestModel extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final String lastWorkDate;
  final String? lastWorkDateH;
  final String strNotes;

  const ResignationRequestModel({
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.lastWorkDate,
    this.lastWorkDateH,
    required this.strNotes,
  });

  factory ResignationRequestModel.fromJson(Map<String, dynamic> json) {
    return ResignationRequestModel(
      empCode: json['EmpCode'] as int,
      requestDate: json['RequestDate'] as String,
      requestDateH: json['RequestDateH'] as String?,
      lastWorkDate: json['LastWorkDate'] as String,
      lastWorkDateH: json['LastWorkDateH'] as String?,
      strNotes: json['strNotes'] as String,
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
  ];
}
