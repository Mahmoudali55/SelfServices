import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';

class UpdateTransferRequestModel extends Equatable {
  final int requestId;
  final int empCode;
  final String requestDate;
  final int tDep;
  final int tBra;
  final int tProj;
  final String causes;
  final int adminEmp;
  final List<AttachmentModel> attachment;
  const UpdateTransferRequestModel({
    required this.requestId,
    required this.empCode,
    required this.requestDate,
    required this.tDep,
    required this.tBra,
    required this.tProj,
    required this.causes,
    required this.adminEmp,
    required this.attachment,
  });

  factory UpdateTransferRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateTransferRequestModel(
      requestId: json['Requestid'] ?? 0,
      empCode: json['EmpCode'] ?? 0,
      requestDate: json['requsetDate'] ?? '',
      tDep: json['TDEP'] ?? 0,
      tBra: json['TBRA'] ?? 0,
      tProj: json['TPROJ'] ?? 0,
      causes: json['CAUSES'] ?? '',
      adminEmp: json['AdminEmp'] ?? 0,
      attachment: (json['Attachment'] as List<dynamic>)
          .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Requestid': requestId,
      'EmpCode': empCode,
      'requsetDate': requestDate,
      'TDEP': tDep,
      'TBRA': tBra,
      'TPROJ': tProj,
      'CAUSES': causes,
      'AdminEmp': adminEmp,
      'Attachment': attachment.map((e) => e.toJson()).toList(),
    };
  }

  static List<UpdateTransferRequestModel> listFromData(String dataString) {
    final List dataList = jsonDecode(dataString);
    return dataList.map((x) => UpdateTransferRequestModel.fromJson(x)).toList();
  }

  @override
  List<Object?> get props => [
    requestId,
    empCode,
    requestDate,
    tDep,
    tBra,
    tProj,
    causes,
    adminEmp,
    attachment,
  ];
}
