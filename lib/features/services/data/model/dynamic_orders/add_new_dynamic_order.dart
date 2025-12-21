import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class AddNewDynamicOrder extends Equatable {
  final int empCode;
  final String requestDate;
  final String? requestDateH;
  final int requestTypeId;
  final String strField1;
  final String strField2;
  final String strNotes;
  final List<AttachmentModel> attachment;
  const AddNewDynamicOrder({
    required this.empCode,
    required this.requestDate,
    this.requestDateH,
    required this.requestTypeId,
    required this.strField1,
    required this.strField2,
    required this.strNotes,
    required this.attachment,
  });

  factory AddNewDynamicOrder.fromJson(Map<String, dynamic> json) {
    return AddNewDynamicOrder(
      empCode: json['EmpCode'] ?? 0,
      requestDate: json['RequestDate'] ?? '',
      requestDateH: json['RequestDateH'],
      requestTypeId: json['RequestTypeId'] ?? 0,
      strField1: json['StrField1'] ?? '',
      strField2: json['StrField2'] ?? '',
      strNotes: json['StrNotes'] ?? '',
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
      'RequestTypeId': requestTypeId,
      'StrField1': strField1,
      'StrField2': strField2,
      'StrNotes': strNotes,
      'Attachment': attachment.map((e) => e.toJson()).toList(),
    };
  }

  AddNewDynamicOrder copyWith({
    int? empCode,
    String? requestDate,
    String? requestDateH,
    int? requestTypeId,
    String? strField1,
    String? strNotes,
    String? strField2,
    List<AttachmentModel>? attachment,
  }) {
    return AddNewDynamicOrder(
      empCode: empCode ?? this.empCode,
      requestDate: requestDate ?? this.requestDate,
      requestDateH: requestDateH ?? this.requestDateH,
      requestTypeId: requestTypeId ?? this.requestTypeId,
      strField1: strField1 ?? this.strField1,
      strNotes: strNotes ?? this.strNotes,
      strField2: strField2 ?? this.strField2,
      attachment: attachment ?? this.attachment,
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
    attachment,
  ];
}
