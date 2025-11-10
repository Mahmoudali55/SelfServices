import 'package:equatable/equatable.dart';

class TimeSheetOutRequestModel extends Equatable {
  final int empId;
  final double longitude;
  final double latitude;
  final String signOutDate;
  final String signOutTime;
  final String mobileSerNo; // حقل جديد

  const TimeSheetOutRequestModel({
    required this.empId,
    required this.longitude,
    required this.latitude,
    required this.signOutDate,
    required this.signOutTime,
    required this.mobileSerNo, // مضاف هنا
  });

  factory TimeSheetOutRequestModel.fromJson(Map<String, dynamic> json) {
    return TimeSheetOutRequestModel(
      empId: json['Emp_id'] as int,
      longitude: (json['Longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      signOutDate: json['signoutdate'] as String,
      signOutTime: json['signouttime'] as String,
      mobileSerNo: json['Mobile_SerNo'] as String? ?? '', // التعامل مع null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Emp_id': empId,
      'Longitude': longitude,
      'latitude': latitude,
      'signoutdate': signOutDate,
      'signouttime': signOutTime,
      'Mobile_SerNo': mobileSerNo, // مضاف هنا
    };
  }

  @override
  List<Object?> get props => [empId, longitude, latitude, signOutDate, signOutTime, mobileSerNo];
}
