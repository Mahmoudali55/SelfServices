import 'package:equatable/equatable.dart';

class RequestLeaveResponseModel extends Equatable {
  final bool success;
  final String reqNo;

  const RequestLeaveResponseModel({required this.success, required this.reqNo});

  factory RequestLeaveResponseModel.fromJson(Map<String, dynamic> json) {
    return RequestLeaveResponseModel(
      success: json['success'] as bool,
      reqNo: json['ReqNo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'ReqNo': reqNo};

  @override
  List<Object?> get props => [success, reqNo];
}
