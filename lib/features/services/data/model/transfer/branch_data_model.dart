import 'dart:convert';

import 'package:equatable/equatable.dart';

class BranchDataModel extends Equatable {
  final int bCode;
  final String bName;
  final String? bNameE;
  final int dCode;
  final String dName;

  const BranchDataModel({
    required this.bCode,
    required this.bName,
    this.bNameE,
    required this.dCode,
    required this.dName,
  });

  factory BranchDataModel.fromJson(Map<String, dynamic> json) {
    return BranchDataModel(
      bCode: json['B_CODE'] as int,
      bName: json['B_NAME'] as String,
      bNameE: json['B_NAME_E'] as String?,
      dCode: json['D_CODE'] as int,
      dName: json['D_NAME'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'B_CODE': bCode,
    'B_NAME': bName,
    'B_NAME_E': bNameE,
    'D_CODE': dCode,
    'D_NAME': dName,
  };

  static List<BranchDataModel> listFromMap(Map<String, dynamic> json) {
    final dataString = json['Data'] as String? ?? '[]';
    final List<dynamic> decoded = jsonDecode(dataString);
    return decoded.map((e) => BranchDataModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  List<Object?> get props => [bCode, bName, bNameE, dCode, dName];
}
