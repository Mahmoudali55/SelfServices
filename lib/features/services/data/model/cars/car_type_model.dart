import 'dart:convert';

import 'package:equatable/equatable.dart';

class CarTypeModel extends Equatable {
  final int carTypeID;
  final String carTypeName;
  final String carTypeNameEng;

  const CarTypeModel({
    required this.carTypeID,
    required this.carTypeName,
    required this.carTypeNameEng,
  });

  factory CarTypeModel.fromJson(Map<String, dynamic> json) {
    return CarTypeModel(
      carTypeID: json['CarTypeID'] as int,
      carTypeName: json['CarTypeName'] ?? '',
      carTypeNameEng: json['CarTypeNameEng'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'CarTypeID': carTypeID,
    'CarTypeName': carTypeName,
    'CarTypeNameEng': carTypeNameEng,
  };


  static List<CarTypeModel> listFromMap(Map<String, dynamic> map) {
    final List<dynamic> dataList = json.decode(map['Data']); 
    return dataList.map((e) => CarTypeModel.fromJson(e)).toList();
  }

  @override
  List<Object?> get props => [carTypeID, carTypeName, carTypeNameEng];
}
