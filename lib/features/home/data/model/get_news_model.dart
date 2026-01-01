import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetNewsModel extends Equatable {
  final int ser;
  final String newsTitleAr;
  final String newsTitleEn;
  final String newsSubjectAr;
  final String newsSubjectEn;
  final String miniNewsSubject;
  final String newsImageFileName;
  final int active;

  const GetNewsModel({
    required this.ser,
    required this.newsTitleAr,
    required this.newsTitleEn,
    required this.newsSubjectAr,
    required this.newsSubjectEn,
    required this.miniNewsSubject,
    required this.newsImageFileName,
    required this.active,
  });

  factory GetNewsModel.fromMap(Map<String, dynamic> map) {
    return GetNewsModel(
      ser: _toInt(map['Ser']),
      newsTitleAr: map['NewsTitle']?.toString() ?? '',
      newsTitleEn: map['NewsTitle_EN']?.toString() ?? '',
      newsSubjectAr: map['Newssubject']?.toString() ?? '',
      newsSubjectEn: map['Newssubject_EN']?.toString() ?? '',
      miniNewsSubject: map['miniNewssubject']?.toString() ?? '',
      newsImageFileName: map['NewsImagFileName']?.toString().trim() ?? '',
      active: _toInt(map['Active']),
    );
  }

  /// 🔹 عنوان حسب اللغة
  String title(String langCode) =>
      langCode == 'en' && newsTitleEn.isNotEmpty ? newsTitleEn : newsTitleAr;

  /// 🔹 وصف حسب اللغة
  String subject(String langCode) =>
      langCode == 'en' && newsSubjectEn.isNotEmpty ? newsSubjectEn : newsSubjectAr;

  static List<GetNewsModel> parseList(dynamic response) {
    try {
      if (response is Map<String, dynamic> && response['Data'] != null) {
        final decoded = jsonDecode(response['Data']);
        return List<GetNewsModel>.from(decoded.map((e) => GetNewsModel.fromMap(e)));
      }
    } catch (_) {}
    return [];
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [
    ser,
    newsTitleAr,
    newsTitleEn,
    newsSubjectAr,
    newsSubjectEn,
    miniNewsSubject,
    newsImageFileName,
    active,
  ];
}
