import 'package:equatable/equatable.dart';

class EmpLoginModel extends Equatable {
  final bool success;

  const EmpLoginModel({required this.success});

  factory EmpLoginModel.fromJson(Map<String, dynamic> json) {
    return EmpLoginModel(success: json['success'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }

  @override
  List<Object?> get props => [success];
}
