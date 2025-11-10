import 'dart:convert';

import 'package:equatable/equatable.dart';

class MobileResponse extends Equatable {
  final List<MobileData> data;

  const MobileResponse({required this.data});

  factory MobileResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['Data'];

    final List<dynamic> decoded = rawData is String ? jsonDecode(rawData) : (rawData ?? []);

    return MobileResponse(data: decoded.map((e) => MobileData.fromJson(e)).toList());
  }

  Map<String, dynamic> toJson() => {'Data': data.map((e) => e.toJson()).toList()};

  @override
  List<Object?> get props => [data];
}

class MobileData extends Equatable {
  final String? mobileSerno;

  const MobileData({this.mobileSerno});

  factory MobileData.fromJson(Map<String, dynamic> json) {
    return MobileData(mobileSerno: json['Mobile_serno']?.toString());
  }

  Map<String, dynamic> toJson() => {'Mobile_serno': mobileSerno};

  @override
  List<Object?> get props => [mobileSerno];
}
