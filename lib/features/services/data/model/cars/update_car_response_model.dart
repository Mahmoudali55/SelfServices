import 'dart:convert';

import 'package:equatable/equatable.dart';

class UpdateCarResponseModel extends Equatable {
  final bool success;

  const UpdateCarResponseModel({required this.success});

  factory UpdateCarResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateCarResponseModel(success: json['success'] as bool);
  }

  Map<String, dynamic> toJson() => {'success': success};

  static UpdateCarResponseModel fromRawJson(String rawJson) =>
      UpdateCarResponseModel.fromJson(json.decode(rawJson));

  String toRawJson() => json.encode(toJson());

  @override
  List<Object?> get props => [success];
}
