import 'dart:convert';

import 'package:equatable/equatable.dart';

class UpdateCarRequestModel extends Equatable {
  final int requestId;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int carTypeID;
  final String purpose;
  final String strNotes;

  const UpdateCarRequestModel({
    required this.requestId,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.carTypeID,
    required this.purpose,
    required this.strNotes,
  });

  factory UpdateCarRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateCarRequestModel(
      requestId: json['Requestid'] as int,
      empCode: json['EmpCode'] as int,
      requestDate: json['RequestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      carTypeID: json['CarTypeID'] as int,
      purpose: json['Purpose'] ?? '',
      strNotes: json['strNotes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'Requestid': requestId,
    'EmpCode': empCode,
    'RequestDate': requestDate,
    'RequestDateH': requestDateH,
    'CarTypeID': carTypeID,
    'Purpose': purpose,
    'strNotes': strNotes,
  };

  static UpdateCarRequestModel fromRawJson(String rawJson) =>
      UpdateCarRequestModel.fromJson(json.decode(rawJson));

  String toRawJson() => json.encode(toJson());

  @override
  List<Object?> get props => [
    requestId,
    empCode,
    requestDate,
    requestDateH,
    carTypeID,
    purpose,
    strNotes,
  ];
}
