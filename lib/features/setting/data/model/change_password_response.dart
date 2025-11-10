import 'package:equatable/equatable.dart';

class ChangePasswordResponse extends Equatable {
  final bool success;

  const ChangePasswordResponse({required this.success});

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(success: json['success'] as bool);
  }

  Map<String, dynamic> toJson() => {'success': success};

  @override
  List<Object> get props => [success];
}
