import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class HousingAllowanceRequestModel extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final double sakanAmount;
  final int amountType;
  final String strNotes;
  final List<AttachmentModel> attachment;
  const HousingAllowanceRequestModel({
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.sakanAmount,
    required this.amountType,
    required this.strNotes,
    required this.attachment,
  });

  factory HousingAllowanceRequestModel.fromJson(Map<String, dynamic> json) {
    return HousingAllowanceRequestModel(
      empCode: json['EmpCode'] as int,
      requestDate: json['RequestDate'] as String,
      requestDateH: json['RequestDateH'] as String?,
      sakanAmount: (json['SakanAmount'] as num).toDouble(),
      amountType: json['AmountType'] as int,
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
      'SakanAmount': sakanAmount,
      'AmountType': amountType,
      'strNotes': strNotes,
      'Attachment': attachment.map((e) => e.toJson()).toList(),
    };
  }

  HousingAllowanceRequestModel copyWith({
    int? empCode,
    String? requestDate,
    String? requestDateH,
    double? sakanAmount,
    int? amountType,
    String? strNotes,
  }) {
    return HousingAllowanceRequestModel(
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
    empCode,
    requestDate,
    requestDateH,
    sakanAmount,
    amountType,
    strNotes,
    attachment,
  ];

  @override
  String toString() {
    return 'HousingAllowanceRequestModel(empCode: $empCode, requestDate: $requestDate, requestDateH: $requestDateH, sakanAmount: $sakanAmount, amountType: $amountType, strNotes: $strNotes)';
  }
}
