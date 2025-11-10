import 'package:equatable/equatable.dart';

class UpdateVacationResponseBackModel extends Equatable {
  final bool success;

  const UpdateVacationResponseBackModel({required this.success});

  factory UpdateVacationResponseBackModel.fromJson(Map<String, dynamic> json) {
    return UpdateVacationResponseBackModel(success: json['success'] ?? false);
  }

  Map<String, dynamic> toJson() => {'success': success};

  @override
  List<Object?> get props => [success];
}
