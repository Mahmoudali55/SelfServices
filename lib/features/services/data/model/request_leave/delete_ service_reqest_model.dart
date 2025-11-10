import 'dart:convert';

import 'package:equatable/equatable.dart';

class DeleteserviceRequestModel extends Equatable {
  final int id;

  const DeleteserviceRequestModel({required this.id});

  factory DeleteserviceRequestModel.fromJson(Map<String, dynamic> json) {
    return DeleteserviceRequestModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }

  static DeleteserviceRequestModel fromDataString(String dataString) {
    final Map<String, dynamic> jsonMap = jsonDecode(dataString);
    return DeleteserviceRequestModel.fromJson(jsonMap);
  }

  @override
  List<Object?> get props => [id];
}
