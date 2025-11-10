import 'dart:convert';

import 'package:equatable/equatable.dart';

class SolfaTypeModel extends Equatable {
  final int paCode;
  final String paName;
  final String? paNameE;

  const SolfaTypeModel({required this.paCode, required this.paName, this.paNameE});

  factory SolfaTypeModel.fromJson(Map<String, dynamic> json) {
    return SolfaTypeModel(
      paCode: json['PA_CODE'] ?? 0,
      paName: json['PA_NAME'] ?? '',
      paNameE: json['PA_NAME_E'],
    );
  }

  /// تحويل الـ API response لقائمة من SolfaTypeModel
  static List<SolfaTypeModel> listFromResponse(dynamic response) {
    // إذا response جاي String → نعمل decode
    final Map<String, dynamic> map = response is String ? json.decode(response) : response;

    // Data ممكن يكون String JSON أو List<dynamic>
    final dynamic data = map['Data'];
    final List<dynamic> list = data is String ? json.decode(data) : data;

    return list.map((e) => SolfaTypeModel.fromJson(e)).toList();
  }

  /// ترجع الاسم حسب اللغة
  String getName(String langCode) {
    if (langCode == 'en' && paNameE != null && paNameE!.isNotEmpty) {
      return paNameE!;
    }
    return paName;
  }

  @override
  List<Object?> get props => [paCode, paName, paNameE];
}
