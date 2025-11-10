import 'package:equatable/equatable.dart';

class AddNewSolfaResponseModel extends Equatable {
  final bool success;
  final String reqId;

  const AddNewSolfaResponseModel({required this.success, required this.reqId});

  factory AddNewSolfaResponseModel.fromJson(Map<String, dynamic> json) {
    return AddNewSolfaResponseModel(success: json['success'] ?? false, reqId: json['ReqId'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'ReqId': reqId};
  }

  @override
  List<Object?> get props => [success, reqId];
}
