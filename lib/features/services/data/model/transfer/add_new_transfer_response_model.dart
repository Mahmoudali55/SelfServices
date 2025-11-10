import 'dart:convert';

import 'package:equatable/equatable.dart';

class AddNewTransferResponseModel extends Equatable {
  final bool success;
  final String reqId;

  const AddNewTransferResponseModel({required this.success, required this.reqId});

  factory AddNewTransferResponseModel.fromJson(Map<String, dynamic> json) {
    return AddNewTransferResponseModel(
      success: json['success'] ?? false,
      reqId: json['ReqId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'ReqId': reqId};
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [success, reqId];
}
