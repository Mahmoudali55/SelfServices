import 'package:equatable/equatable.dart';

class DeleteRequestModel extends Equatable {
  final int data;

  const DeleteRequestModel({required this.data});

  factory DeleteRequestModel.fromJson(Map<String, dynamic>? json) {
    return DeleteRequestModel(data: json?['Data'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'Data': data};

  @override
  List<Object?> get props => [data];
}
