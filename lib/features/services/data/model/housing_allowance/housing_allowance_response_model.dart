import 'package:equatable/equatable.dart';

class HousingAllowanceResponse extends Equatable {
  final bool success;
  final String reqId;

  const HousingAllowanceResponse({required this.success, required this.reqId});

  factory HousingAllowanceResponse.fromJson(Map<String, dynamic> json) {
    return HousingAllowanceResponse(
      success: json['success'] as bool,
      reqId: json['ReqId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'ReqId': reqId};
  }

  HousingAllowanceResponse copyWith({bool? success, String? reqId}) {
    return HousingAllowanceResponse(success: success ?? this.success, reqId: reqId ?? this.reqId);
  }

  @override
  List<Object?> get props => [success, reqId];

  @override
  String toString() => 'HousingAllowanceResponse(success: $success, reqId: $reqId)';
}
