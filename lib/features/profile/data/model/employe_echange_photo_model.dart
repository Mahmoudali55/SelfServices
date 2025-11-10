import 'package:equatable/equatable.dart';

class EmployeechangephotoResponse extends Equatable {
  final bool data;

  const EmployeechangephotoResponse({required this.data});

  factory EmployeechangephotoResponse.fromJson(Map<String, dynamic> json) {
    return EmployeechangephotoResponse(data: json['Data'] as bool);
  }

  Map<String, dynamic> toJson() {
    return {'Data': data};
  }

  @override
  List<Object?> get props => [data];
}
