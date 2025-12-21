import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class AddNewCarRequestModel extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int carTypeID;
  final String purpose;
  final String strNotes;
  final List<AttachmentModel> attachment;
  const AddNewCarRequestModel({
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.carTypeID,
    required this.purpose,
    required this.strNotes,
    required this.attachment,
  });

  factory AddNewCarRequestModel.fromJson(Map<String, dynamic> json) {
    return AddNewCarRequestModel(
      empCode: json['EmpCode'] as int,
      requestDate: json['RequestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      carTypeID: json['CarTypeID'] as int,
      purpose: json['Purpose'] ?? '',
      strNotes: json['strNotes'] ?? '',
      attachment: (json['Attachment'] as List<dynamic>)
          .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'EmpCode': empCode,
    'RequestDate': requestDate,
    'RequestDateH': requestDateH,
    'CarTypeID': carTypeID,
    'Purpose': purpose,
    'strNotes': strNotes,
    'Attachment': attachment.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    empCode,
    requestDate,
    requestDateH,
    carTypeID,
    purpose,
    strNotes,
    attachment,
  ];
}
