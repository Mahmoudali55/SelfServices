import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class UpdateHousingAllowanceRequestModel extends Equatable {
  final int requestId;
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final double sakanAmount;
  final int amountType;
  final String strNotes;
  final List<AttachmentModel> attachment;
  const UpdateHousingAllowanceRequestModel({
    required this.requestId,
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.sakanAmount,
    required this.amountType,
    required this.strNotes,
    required this.attachment,
  });

  factory UpdateHousingAllowanceRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateHousingAllowanceRequestModel(
      requestId: json['Requestid'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      requestDate: json['RequestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      sakanAmount: (json['SakanAmount'] ?? 0).toDouble(),
      amountType: json['AmountType'] ?? 0,
      strNotes: json['strNotes'] ?? '',
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
      'SakanAmount': sakanAmount,
      'AmountType': amountType,
      'strNotes': strNotes,
      'Attachment': attachment.map((e) => e.toJson()).toList(),
    };
  }

  UpdateHousingAllowanceRequestModel copyWith({
    int? requestId,
    int? empCode,
    String? requestDate,
    String? requestDateH,
    double? sakanAmount,
    int? amountType,
    String? strNotes,
  }) {
    return UpdateHousingAllowanceRequestModel(
      requestId: requestId ?? this.requestId,
      empCode: empCode ?? this.empCode,
      requestDate: requestDate ?? this.requestDate,
      requestDateH: requestDateH ?? this.requestDateH,
      sakanAmount: sakanAmount ?? this.sakanAmount,
      amountType: amountType ?? this.amountType,
      strNotes: strNotes ?? this.strNotes,
      attachment: attachment,
    );
  }

  @override
  List<Object?> get props => [
    requestId,
    empCode,
    requestDate,
    requestDateH,
    sakanAmount,
    amountType,
    strNotes,
    attachment,
  ];
}
