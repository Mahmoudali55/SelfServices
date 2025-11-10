import 'package:equatable/equatable.dart';

class AddNewCarResponseModel extends Equatable {
  final bool success;
  final String reqId;

  const AddNewCarResponseModel({required this.success, required this.reqId});

  factory AddNewCarResponseModel.fromJson(Map<String, dynamic> json) {
    return AddNewCarResponseModel(success: json['success'] as bool, reqId: json['ReqId'] ?? '');
  }

  Map<String, dynamic> toJson() => {'success': success, 'ReqId': reqId};

  @override
  List<Object?> get props => [success, reqId];
}
