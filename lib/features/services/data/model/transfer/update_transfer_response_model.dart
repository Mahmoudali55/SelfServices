import 'package:equatable/equatable.dart';

class UpdateTransferResponseModel extends Equatable {
  final bool success;

  const UpdateTransferResponseModel({required this.success});

  factory UpdateTransferResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateTransferResponseModel(success: json['success'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }

  @override
  List<Object?> get props => [success];
}
