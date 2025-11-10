import 'package:equatable/equatable.dart';

class TimeSheetResponse extends Equatable {
  final bool data; // بدل String message

  const TimeSheetResponse({required this.data});

  factory TimeSheetResponse.fromJson(Map<String, dynamic> json) {
    return TimeSheetResponse(data: json['Data'] as bool);
  }

  Map<String, dynamic> toJson() {
    return {'Data': data};
  }

  @override
  List<Object?> get props => [data];
}
