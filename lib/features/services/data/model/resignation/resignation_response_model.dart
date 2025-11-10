import 'package:equatable/equatable.dart';

class ResignationResponseModel extends Equatable {
  final bool success;
  final String reqId;

  const ResignationResponseModel({required this.success, required this.reqId});

  factory ResignationResponseModel.fromJson(Map<String, dynamic> json) {
    return ResignationResponseModel(
      success: json['success'] as bool,
      reqId: json['ReqId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'ReqId': reqId};
  }

  @override
  List<Object> get props => [success, reqId];
}
