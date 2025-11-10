import 'dart:convert';

import 'package:equatable/equatable.dart';

class EmployeeBalModel extends Equatable {
  final double column1;

  const EmployeeBalModel({required this.column1});

  factory EmployeeBalModel.fromJson(Map<String, dynamic> json) {
    return EmployeeBalModel(
      column1: json['Column1'] is num
          ? (json['Column1'] as num).toDouble()
          : double.tryParse(json['Column1'].toString()) ?? 0.0,
    );
  }

  static List<EmployeeBalModel> listFromResponse(Map<String, dynamic> response) {
    final String dataString = response['Data'] ?? '[]';
    final List dataList = jsonDecode(dataString);
    return dataList.map((x) => EmployeeBalModel.fromJson(x)).toList();
  }

  @override
  List<Object?> get props => [column1];
}
