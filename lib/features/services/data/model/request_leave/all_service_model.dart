import 'dart:convert';

import 'package:equatable/equatable.dart';

class ALLServiceModel extends Equatable {
  final int id;
  final int requestId;
  final String? serviceDesc;
  final String? serviceDescEn;

  const ALLServiceModel({
    required this.id,
    required this.requestId,
    this.serviceDesc,
    this.serviceDescEn,
  });

  factory ALLServiceModel.fromJson(Map<String, dynamic> json) {
    return ALLServiceModel(
      id: json['Id'] ?? 0,
      requestId: json['RequestID'] ?? 0,
      serviceDesc: json['ServiceDesc']?.toString(),
      serviceDescEn: json['ServiceDesc_EN']?.toString(),
    );
  }

  // هنا نتعامل مع Data اللي هي String
  static List<ALLServiceModel> listFromResponse(Map<String, dynamic> responseJson) {
    if (responseJson['Data'] == null) return [];

    final String dataString = responseJson['Data'];

    final List<dynamic> dataList = jsonDecode(dataString);

    return dataList.map((e) => ALLServiceModel.fromJson(e)).toList();
  }

  @override
  List<Object?> get props => [id, requestId, serviceDesc, serviceDescEn];
}
