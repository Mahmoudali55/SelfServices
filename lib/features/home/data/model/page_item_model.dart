import 'dart:convert';

import 'package:equatable/equatable.dart';

class PageItemModel extends Equatable {
  final int ser;
  final int userID;
  final String? userName;
  final int pageID;
  final int pagePrivID;
  final int appID;

  const PageItemModel({
    required this.ser,
    required this.userID,
    this.userName,
    required this.pageID,
    required this.pagePrivID,
    required this.appID,
  });

  factory PageItemModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String && value.isNotEmpty) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    return PageItemModel(
      ser: parseInt(json['Ser']),
      userID: parseInt(json['UserID']),
      userName: (json['UserName'] != null && json['UserName'].toString().isNotEmpty)
          ? json['UserName'].toString()
          : null,
      pageID: parseInt(json['PageID']),
      pagePrivID: parseInt(json['PagePrivID']),
      appID: parseInt(json['AppID']),
    );
  }

  static List<PageItemModel> fromJsonList(dynamic jsonList) {
    if (jsonList is String) {
      jsonList = jsonDecode(jsonList);
    }
    if (jsonList is List) {
      return jsonList.map((e) => PageItemModel.fromJson(e)).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() => {
    'Ser': ser,
    'UserID': userID,
    'UserName': userName,
    'PageID': pageID,
    'PagePrivID': pagePrivID,
    'AppID': appID,
  };

  @override
  List<Object?> get props => [ser, userID, userName, pageID, pagePrivID, appID];
}
