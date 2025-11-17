import 'package:equatable/equatable.dart';

class DecidingInRequestModel extends Equatable {
  final int requestType;
  final int requestId;
  final int actionType;
  final int actionMakerEmpID;
  final String strNotes;
  final int isLastDecidingEmp;
  final int haveSpecialDecide;
  final int? specialDecideEmpId;

  const DecidingInRequestModel({
    required this.requestType,
    required this.requestId,
    required this.actionType,
    required this.actionMakerEmpID,
    this.strNotes = '',
    required this.isLastDecidingEmp,
    this.haveSpecialDecide = 0,
    this.specialDecideEmpId,
  });

  Map<String, dynamic> toJson() {
    return {
      'RequestType': requestType,
      'RequestId': requestId,
      'ActionType': actionType,
      'ActionMakerEmpID': actionMakerEmpID,
      'strNotes': strNotes,
      'IsLastDecidingEmp': isLastDecidingEmp,
      'HaveSpecialDecide': haveSpecialDecide,
      'SpecialDecideEmpId': specialDecideEmpId,
    };
  }

  @override
  List<Object?> get props => [
    requestType,
    requestId,
    actionType,
    actionMakerEmpID,
    strNotes,
    isLastDecidingEmp,
    haveSpecialDecide,
    specialDecideEmpId,
  ];
}
