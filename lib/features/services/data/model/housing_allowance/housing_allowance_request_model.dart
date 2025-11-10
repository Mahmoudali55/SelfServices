import 'package:equatable/equatable.dart';

class HousingAllowanceRequestModel extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final double sakanAmount;
  final int amountType;
  final String strNotes;

  const HousingAllowanceRequestModel({
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.sakanAmount,
    required this.amountType,
    required this.strNotes,
  });

  factory HousingAllowanceRequestModel.fromJson(Map<String, dynamic> json) {
    return HousingAllowanceRequestModel(
      empCode: json['EmpCode'] as int,
      requestDate: json['RequestDate'] as String,
      requestDateH: json['RequestDateH'] as String?,
      sakanAmount: (json['SakanAmount'] as num).toDouble(),
      amountType: json['AmountType'] as int,
      strNotes: json['strNotes'] as String,
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
  ];

  @override
  String toString() {
    return 'HousingAllowanceRequestModel(empCode: $empCode, requestDate: $requestDate, requestDateH: $requestDateH, sakanAmount: $sakanAmount, amountType: $amountType, strNotes: $strNotes)';
  }
}
