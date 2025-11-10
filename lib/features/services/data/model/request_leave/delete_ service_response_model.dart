import 'dart:convert';
import 'package:equatable/equatable.dart';

class DeleteServiceResponseModel extends Equatable {
  final bool data;

  const DeleteServiceResponseModel({required this.data});

  factory DeleteServiceResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteServiceResponseModel(
      data: json['Data'] == true,
    );
  }

  static DeleteServiceResponseModel fromDataString(String dataString) {
    final Map<String, dynamic> jsonMap = jsonDecode(dataString);
    return DeleteServiceResponseModel.fromJson(jsonMap);
  }

  @override
  List<Object?> get props => [data];
}
