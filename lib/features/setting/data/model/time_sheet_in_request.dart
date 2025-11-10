import 'package:equatable/equatable.dart';

class TimeSheetInRequestmodel extends Equatable {
  final int empId;
  final double longitude;
  final double latitude;
  final String signInDate;
  final String signInTime;
  final String? signOutDate;
  final String? signOutTime;
  final String mobileSerNo;
  final int? projectCode;

  const TimeSheetInRequestmodel({
    required this.empId,
    required this.longitude,
    required this.latitude,
    required this.signInDate,
    required this.signInTime,
    required this.mobileSerNo,
    this.signOutDate,
    this.signOutTime,
    this.projectCode,
  });

  factory TimeSheetInRequestmodel.fromJson(Map<String, dynamic> json) {
    return TimeSheetInRequestmodel(
      empId: json['Emp_id'] as int,
      longitude: (json['Longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      signInDate: json['signindate'] as String,
      signInTime: json['signintime'] as String,
      mobileSerNo: json['Mobile_SerNo'] as String? ?? '',
      signOutDate: json['signoutdate'] as String?,
      signOutTime: json['signouttime'] as String?,
      projectCode: json['projectcode'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Emp_id': empId,
      'Longitude': longitude,
      'latitude': latitude,
      'signindate': signInDate,
      'signintime': signInTime,
      'Mobile_SerNo': mobileSerNo,
      if (signOutDate != null) 'signoutdate': signOutDate,
      if (signOutTime != null) 'signouttime': signOutTime,
      if (projectCode != null) 'projectcode': projectCode,
    };
  }

  @override
  List<Object?> get props => [
    empId,
    longitude,
    latitude,
    signInDate,
    signInTime,
    mobileSerNo,
    signOutDate,
    signOutTime,
    projectCode,
  ];
}
