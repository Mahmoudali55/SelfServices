import 'dart:convert';

import 'package:equatable/equatable.dart';

class GetVacationAttachmentModel extends Equatable {
  final List<VacationAttachmentItem> data;

  const GetVacationAttachmentModel({required this.data});

  factory GetVacationAttachmentModel.fromJson(Map<String, dynamic> json) {
    final String dataString = json['Data'] as String;
    final List<dynamic> dataList = jsonDecode(dataString);

    return GetVacationAttachmentModel(
      data: dataList.map((e) => VacationAttachmentItem.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'Data': jsonEncode(data.map((e) => e.toJson()).toList())};
  }

  @override
  List<Object> get props => [data];
}

class VacationAttachmentItem extends Equatable {
  final int ser;
  final int attachmentTypeId;
  final int transId;
  final String attatchmentName;
  final String attchmentFileName;
  final String localFilePath;

  const VacationAttachmentItem({
    required this.ser,
    required this.attachmentTypeId,
    required this.transId,
    required this.attatchmentName,
    required this.attchmentFileName,
    required this.localFilePath,
  });

  factory VacationAttachmentItem.fromJson(Map<String, dynamic> json) {
    return VacationAttachmentItem(
      ser: json['Ser'] as int,
      attachmentTypeId: json['AttachmentTypeId'] as int,
      transId: json['TransId'] as int,
      attatchmentName: json['AttatchmentName'] as String,
      attchmentFileName: json['AttchmentFileName'] as String,
      localFilePath: json['LocalfilPath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Ser': ser,
      'AttachmentTypeId': attachmentTypeId,
      'TransId': transId,
      'AttatchmentName': attatchmentName,
      'AttchmentFileName': attchmentFileName,
      'LocalfilPath': localFilePath,
    };
  }

  @override
  List<Object> get props => [
    ser,
    attachmentTypeId,
    transId,
    attatchmentName,
    attchmentFileName,
    localFilePath,
  ];
}
