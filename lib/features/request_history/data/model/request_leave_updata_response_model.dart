import 'package:equatable/equatable.dart';

class RequestLeaveUpdataResponseModel extends Equatable {
  final bool success;
  final String reqNo;

  const RequestLeaveUpdataResponseModel({required this.success, required this.reqNo});

  factory RequestLeaveUpdataResponseModel.fromJson(Map<String, dynamic> json) {
    return RequestLeaveUpdataResponseModel(
      success: json['success'] as bool,
      reqNo: json['ReqNo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'ReqNo': reqNo};

  @override
  List<Object?> get props => [success, reqNo];
}
