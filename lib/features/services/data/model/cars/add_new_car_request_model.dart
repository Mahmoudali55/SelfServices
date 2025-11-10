import 'package:equatable/equatable.dart';

class AddNewCarRequestModel extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int carTypeID;
  final String purpose;
  final String strNotes;

  const AddNewCarRequestModel({
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.carTypeID,
    required this.purpose,
    required this.strNotes,
  });

  factory AddNewCarRequestModel.fromJson(Map<String, dynamic> json) {
    return AddNewCarRequestModel(
      empCode: json['EmpCode'] as int,
      requestDate: json['RequestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      carTypeID: json['CarTypeID'] as int,
      purpose: json['Purpose'] ?? '',
      strNotes: json['strNotes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'EmpCode': empCode,
    'RequestDate': requestDate,
    'RequestDateH': requestDateH,
    'CarTypeID': carTypeID,
    'Purpose': purpose,
    'strNotes': strNotes,
  };

  @override
  List<Object?> get props => [empCode, requestDate, requestDateH, carTypeID, purpose, strNotes];
}
