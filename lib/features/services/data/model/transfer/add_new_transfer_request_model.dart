import 'dart:convert';

import 'package:equatable/equatable.dart';

class AddNewTransferRequestModel extends Equatable {
  final int empCode;
  final String requsetDate;
  final int tDep;
  final int tBra;
  final int tProj;
  final String causes;
  final int adminEmp;

  const AddNewTransferRequestModel({
    required this.empCode,
    required this.requsetDate,
    required this.tDep,
    required this.tBra,
    required this.tProj,
    required this.causes,
    required this.adminEmp,
  });

  factory AddNewTransferRequestModel.fromJson(Map<String, dynamic> json) {
    return AddNewTransferRequestModel(
      empCode: json['EmpCode'] ?? 0,
      requsetDate: json['requsetDate'] ?? '',
      tDep: json['TDEP'] ?? 0,
      tBra: json['TBRA'] ?? 0,
      tProj: json['TPROJ'] ?? 0,
      causes: json['CAUSES'] ?? '',
      adminEmp: json['AdminEmp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EmpCode': empCode,
      'requsetDate': requsetDate,
      'TDEP': tDep,
      'TBRA': tBra,
      'TPROJ': tProj,
      'CAUSES': causes,
      'AdminEmp': adminEmp,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [empCode, requsetDate, tDep, tBra, tProj, causes, adminEmp];
}
