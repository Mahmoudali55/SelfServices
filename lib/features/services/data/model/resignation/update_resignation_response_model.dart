import 'package:equatable/equatable.dart';

class UpdateResignationResponse extends Equatable {
  final bool success;
  const UpdateResignationResponse({required this.success});
  factory UpdateResignationResponse.fromJson(Map<String, dynamic> json) {
    return UpdateResignationResponse(success: json['success'] ?? false);
  }
  Map<String, dynamic> toJson() {
    return {'success': success};
  }
  @override
  List<Object?> get props => [success];
}
