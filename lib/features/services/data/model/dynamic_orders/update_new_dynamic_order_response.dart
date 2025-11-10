import 'package:equatable/equatable.dart';

class UpdataNewDynamicOrderResponse extends Equatable {
  final bool success;

  const UpdataNewDynamicOrderResponse({required this.success});

  factory UpdataNewDynamicOrderResponse.fromJson(Map<String, dynamic> json) {
    return UpdataNewDynamicOrderResponse(success: json['success'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }

  @override
  List<Object?> get props => [success];
}
