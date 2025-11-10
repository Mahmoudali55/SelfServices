import 'package:equatable/equatable.dart';

class DecidingInResponseModel extends Equatable {
  final bool success;

  const DecidingInResponseModel({required this.success});

  factory DecidingInResponseModel.fromJson(Map<String, dynamic> json) {
    return DecidingInResponseModel(success: json['success'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }

  @override
  List<Object?> get props => [success];
}
