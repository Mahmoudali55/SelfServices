import 'dart:convert';

import 'package:equatable/equatable.dart';

class DepartmentModel extends Equatable {
  final int dCode;
  final String dName;
  final String? dNameE;

  const DepartmentModel({required this.dCode, required this.dName, this.dNameE});

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      dCode: json['D_CODE'] as int,
      dName: json['D_NAME'] as String,
      dNameE: json['D_NAME_E'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'D_CODE': dCode, 'D_NAME': dName, 'D_NAME_E': dNameE};

  static List<DepartmentModel> listFromMap(Map<String, dynamic> json) {
    final dataString = json['Data'] as String? ?? '[]';
    final List<dynamic> decodedList = jsonDecode(dataString);
    return decodedList.map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  List<Object?> get props => [dCode, dName, dNameE];
}
