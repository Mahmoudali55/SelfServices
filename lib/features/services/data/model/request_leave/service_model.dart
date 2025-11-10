import 'dart:convert';

import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final int id;
  final int requestId;
  final String? serviceDesc;
  final String? serviceDescEn;

  const ServiceModel({
    required this.id,
    required this.requestId,
    this.serviceDesc,
    this.serviceDescEn,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['Id'] is int ? json['Id'] : int.tryParse(json['Id'].toString()) ?? 0,
      requestId: json['RequestID'] is int
          ? json['RequestID']
          : int.tryParse(json['RequestID'].toString()) ?? 0,
      serviceDesc: json['ServiceDesc']?.toString(),
      serviceDescEn: json['ServiceDesc_EN']?.toString(),
    );
  }

  static List<ServiceModel> listFromData(String dataString) {
    final List dataList = jsonDecode(dataString);

    final decoded = dataList.isNotEmpty && dataList[0] is String
        ? jsonDecode(dataList[0])
        : dataList;

    return decoded.map<ServiceModel>((x) => ServiceModel.fromJson(x)).toList();
  }

  @override
  List<Object?> get props => [id, requestId, serviceDesc, serviceDescEn];
}
