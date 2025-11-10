import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetNewsModel extends Equatable {
  final int ser;
  final String newsTitle;
  final String newsSubject;
  final String newsImageFileName;
  final int active;
  final String miniNewsSubject;

  const GetNewsModel({
    required this.ser,
    required this.newsTitle,
    required this.newsSubject,
    required this.newsImageFileName,
    required this.active,
    required this.miniNewsSubject,
  });

  factory GetNewsModel.fromMap(Map<String, dynamic> map) {
    return GetNewsModel(
      ser: map['Ser'] ?? 0,
      newsTitle: map['NewsTitle'] ?? '',
      newsSubject: map['Newssubject'] ?? '',
      newsImageFileName: map['NewsImagFileName'] ?? '',
      active: map['Active'] ?? 0,
      miniNewsSubject: map['miniNewssubject'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Ser': ser,
      'NewsTitle': newsTitle,
      'Newssubject': newsSubject,
      'NewsImagFileName': newsImageFileName,
      'Active': active,
      'miniNewssubject': miniNewsSubject,
    };
  }

  static List<GetNewsModel> parseNewsList(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('Data')) {
      final dataString = response['Data'];
      final List<dynamic> dataList = jsonDecode(dataString);
      return dataList.map((e) => GetNewsModel.fromMap(e)).toList();
    } else if (response is List) {
      return response.map((e) => GetNewsModel.fromMap(e)).toList();
    } else {
      return [];
    }
  }

  @override
  List<Object?> get props => [
    ser,
    newsTitle,
    newsSubject,
    newsImageFileName,
    active,
    miniNewsSubject,
  ];
}
