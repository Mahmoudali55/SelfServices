import 'package:equatable/equatable.dart';

class AddNewVacationBackResponseModel extends Equatable {
  final bool success;

  const AddNewVacationBackResponseModel({required this.success});

  factory AddNewVacationBackResponseModel.fromJson(Map<String, dynamic> json) {
    return AddNewVacationBackResponseModel(success: json['success'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }

  @override
  List<Object?> get props => [success];
}
