import 'package:equatable/equatable.dart';

class UpdateTicketsResponseModel extends Equatable {
  final bool success;

  const UpdateTicketsResponseModel({required this.success});

  factory UpdateTicketsResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateTicketsResponseModel(success: json['success'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }

  @override
  List<Object?> get props => [success];
}
