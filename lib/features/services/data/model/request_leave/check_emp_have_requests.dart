import 'dart:convert';

import 'package:equatable/equatable.dart';

class CheckEmpHaveRequestsModel extends Equatable {
  final double column1;

  const CheckEmpHaveRequestsModel({required this.column1});

  factory CheckEmpHaveRequestsModel.fromJson(Map<String, dynamic> json) {
    return CheckEmpHaveRequestsModel(
      column1: json['Column1'] is num
          ? (json['Column1'] as num).toDouble()
          : double.tryParse(json['Column1'].toString()) ?? 0.0,
    );
  }

  static List<CheckEmpHaveRequestsModel> listFromResponse(Map<String, dynamic> response) {
    final String dataString = response['Data'] ?? '[]';
    final List dataList = jsonDecode(dataString);
    return dataList.map((x) => CheckEmpHaveRequestsModel.fromJson(x)).toList();
  }

  @override
  List<Object?> get props => [column1];
}
