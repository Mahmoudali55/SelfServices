import 'package:equatable/equatable.dart';

class UpdateSolfaResponseModel extends Equatable {
  final bool success;

  const UpdateSolfaResponseModel({required this.success});

  factory UpdateSolfaResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateSolfaResponseModel(success: json['success'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }

  @override
  List<Object?> get props => [success];
}
