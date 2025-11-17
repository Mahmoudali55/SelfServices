import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class ReqCountResponse extends Equatable {
  final List<ReqCountItem> data;
  const ReqCountResponse({required this.data});
  factory ReqCountResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['Data'] as String? ?? '[]';
    List<dynamic> decodedList = [];
    try {
      decodedList = jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      decodedList = [];
    }
    final data = decodedList
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final map = entry.value as Map<String, dynamic>? ?? {};
          return ReqCountItem.fromJson(map, type: RequestTypeHelper.fromIndex(index));
        })
        .where((item) => _allowedTypes.contains(item.type))
        .toList();
    return ReqCountResponse(data: data);
  }
  @override
  List<Object?> get props => [data];
}

const List<RequestType> _allowedTypes = [
  RequestType.vacation,
  RequestType.loan,
  RequestType.resignation,
  RequestType.travelTicket,
  RequestType.housingAllowance,
  RequestType.carRequest,
  RequestType.returnFromLeave,
  RequestType.transferRequest,
  RequestType.dynamicRequest,
];

class ReqCountItem extends Equatable {
  final int reqCount;
  final RequestType type;
  const ReqCountItem({required this.reqCount, required this.type});
  factory ReqCountItem.fromJson(Map<String, dynamic> json, {required RequestType type}) {
    return ReqCountItem(reqCount: (json['ReqCount'] ?? 0) as int, type: type);
  }
  @override
  List<Object?> get props => [reqCount, type];
}

enum RequestType {
  vacation,
  loan,
  resignation,
  travelPermit,
  travelTicket,
  housingAllowance,
  introLetter,
  trainingCourse,
  carRequest,
  hiringRequest,
  performanceEval,
  warningRequest,
  returnFromLeave,
  transferRequest,
  dynamicRequest,
  changeIdPhoneRequest,
}

class RequestTypeHelper {
  static const List<RequestType> _types = [
    RequestType.vacation,
    RequestType.loan,
    RequestType.resignation,
    RequestType.travelPermit,
    RequestType.travelTicket,
    RequestType.housingAllowance,
    RequestType.introLetter,
    RequestType.trainingCourse,
    RequestType.carRequest,
    RequestType.hiringRequest,
    RequestType.performanceEval,
    RequestType.warningRequest,
    RequestType.returnFromLeave,
    RequestType.transferRequest,
    RequestType.dynamicRequest,
    RequestType.changeIdPhoneRequest,
  ];
  static RequestType fromIndex(int index) {
    if (index < 0 || index >= _types.length) return RequestType.vacation;
    return _types[index];
  }

  static String name(RequestType type) {
    switch (type) {
      case RequestType.vacation:
        return AppLocalKay.vacations.tr();
      case RequestType.loan:
        return AppLocalKay.loan.tr();
      case RequestType.resignation:
        return AppLocalKay.resignations.tr();
      case RequestType.travelTicket:
        return AppLocalKay.travelTicket.tr();
      case RequestType.housingAllowance:
        return AppLocalKay.housingAllowance.tr();
      case RequestType.carRequest:
        return AppLocalKay.carRequest.tr();
      case RequestType.returnFromLeave:
        return AppLocalKay.returnFromLeave.tr();
      case RequestType.transferRequest:
        return AppLocalKay.transferRequest.tr();
      case RequestType.dynamicRequest:
        return AppLocalKay.requestgeneral.tr();
      case RequestType.changeIdPhoneRequest:
        return AppLocalKay.requestchangePhone.tr();
      default:
        return '';
    }
  }
}
