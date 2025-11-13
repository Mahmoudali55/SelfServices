import 'package:equatable/equatable.dart';

class AddNewDynamicOrder extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int requestTypeId;
  final String strField1;
  final String strField2;
  final String strNotes;

  const AddNewDynamicOrder({
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.requestTypeId,
    required this.strField1,
    required this.strField2,
    required this.strNotes,
  });

  /// 🟢 إنشاء الكائن من JSON
  factory AddNewDynamicOrder.fromJson(Map<String, dynamic> json) {
    return AddNewDynamicOrder(
      empCode: json['EmpCode'] ?? 0,
      requestDate: json['RequestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      requestTypeId: json['RequestTypeId'] ?? 0,
      strField1: json['StrField1'] ?? '',
      strField2: json['StrField2'] ?? '',
      strNotes: json['StrNotes'] ?? '',
    );
  }

  /// 🟢 تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'EmpCode': empCode,
      'RequestDate': requestDate,
      'RequestDateH': requestDateH,
      'RequestTypeId': requestTypeId,
      'StrField1': strField1,
      'StrField2': strField2,
      'StrNotes': strNotes,
    };
  }

  /// 🟢 نسخ مع تعديل بعض القيم
  AddNewDynamicOrder copyWith({
    int? empCode,
    String? requestDate,
    String? requestDateH,
    int? requestTypeId,
    String? strField1,
    String? strNotes,
    String? strField2,
  }) {
    return AddNewDynamicOrder(
      empCode: empCode ?? this.empCode,
      requestDate: requestDate ?? this.requestDate,
      requestDateH: requestDateH ?? this.requestDateH,
      requestTypeId: requestTypeId ?? this.requestTypeId,
      strField1: strField1 ?? this.strField1,
      strNotes: strNotes ?? this.strNotes,
      strField2: strField2 ?? this.strField2,
    );
  }

  @override
  List<Object?> get props => [
    empCode,
    requestDate,
    requestDateH,
    requestTypeId,
    strField1,
    strNotes,
    strField2,
  ];
}
