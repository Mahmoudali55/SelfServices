import 'dart:convert';

import 'package:equatable/equatable.dart';

class TimeSheetModel extends Equatable {
  final String projectSignInTime;
  final String projectSignOutTime;
  final String signInDate;
  final String signInTime;
  final String? signOutDate;
  final String? signOutTime;
  final int projectCode;
  final String nameGpf;

  const TimeSheetModel({
    required this.projectSignInTime,
    required this.projectSignOutTime,
    required this.signInDate,
    required this.signInTime,
    this.signOutDate,
    this.signOutTime,
    required this.projectCode,
    required this.nameGpf,
  });

  factory TimeSheetModel.fromJson(Map<String, dynamic> json) {
    return TimeSheetModel(
      projectSignInTime: json['project_signintime'] as String,
      projectSignOutTime: json['project_signouttime'] as String,
      signInDate: json['signindate'] as String,
      signInTime: json['signintime'] as String,
      signOutDate: json['signoutdate'] as String?,
      signOutTime: json['signouttime'] as String?,
      projectCode: json['projectcode'] as int,
      nameGpf: json['NAME_GPF'] as String,
    );
  }

  static List<TimeSheetModel> getAllTimesheet(String dataString) {
    final List<dynamic> decodedList = json.decode(dataString);
    return decodedList.map((item) => TimeSheetModel.fromJson(item)).toList();
  }

  @override
  List<Object?> get props => [
    projectSignInTime,
    projectSignOutTime,
    signInDate,
    signInTime,
    signOutDate,
    signOutTime,
    projectCode,
    nameGpf,
  ];
}
