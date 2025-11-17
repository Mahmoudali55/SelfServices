import 'package:equatable/equatable.dart';

class AddNewDynamicOrderResponse extends Equatable {
  final bool success;
  final String reqId;

  const AddNewDynamicOrderResponse({required this.success, required this.reqId});

  factory AddNewDynamicOrderResponse.fromJson(Map<String, dynamic> json) {
    return AddNewDynamicOrderResponse(
      success: json['success'] ?? false,
      reqId: json['ReqId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'ReqId': reqId};
  }

  @override
  List<Object?> get props => [success, reqId];
}
