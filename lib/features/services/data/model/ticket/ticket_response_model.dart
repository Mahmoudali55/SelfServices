import 'package:equatable/equatable.dart';

class TicketResponse extends Equatable {
  final bool success;
  final String reqId;

  const TicketResponse({required this.success, required this.reqId});

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(success: json['success'] ?? false, reqId: json['ReqId'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'ReqId': reqId};
  }

  @override
  List<Object?> get props => [success, reqId];
}
