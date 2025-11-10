import 'package:equatable/equatable.dart';

class UpdateHousingAllowanceResponse extends Equatable {
  final bool success;

  const UpdateHousingAllowanceResponse({required this.success});

  factory UpdateHousingAllowanceResponse.fromJson(Map<String, dynamic> json) {
    return UpdateHousingAllowanceResponse(success: json['success'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }

  @override
  List<Object?> get props => [success];
}
