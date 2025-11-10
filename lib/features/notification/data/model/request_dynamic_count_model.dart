import 'package:equatable/equatable.dart';

class RequestDynamicCountModel extends Equatable {
  final int requestCount;

  const RequestDynamicCountModel({required this.requestCount});

  factory RequestDynamicCountModel.fromJson(Map<String, dynamic> json) {
    return RequestDynamicCountModel(requestCount: json['Requestcount'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'Requestcount': requestCount};

  @override
  List<Object?> get props => [requestCount];
}
