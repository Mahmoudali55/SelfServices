import 'dart:convert';

import 'package:equatable/equatable.dart';

class EmployeeVacationModel extends Equatable {
  final double empVacBal;
  final double column1;

  const EmployeeVacationModel({required this.empVacBal, required this.column1});

  factory EmployeeVacationModel.fromJson(Map<String, dynamic> json) {
    return EmployeeVacationModel(
      empVacBal: json['EmpVacBal'] is double
          ? json['EmpVacBal']
          : double.tryParse(json['EmpVacBal'].toString()) ?? 0.0,
      column1: json['Column1'] is double
          ? json['Column1']
          : double.tryParse(json['Column1'].toString()) ?? 0.0,
    );
  }

  static List<EmployeeVacationModel> listFromDataString(String jsonString) {
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    final String dataString = decoded['Data'] ?? '[]';
    final List dataList = jsonDecode(dataString);
    return dataList.map((x) => EmployeeVacationModel.fromJson(x)).toList();
  }

  @override
  List<Object?> get props => [empVacBal, column1];
}
