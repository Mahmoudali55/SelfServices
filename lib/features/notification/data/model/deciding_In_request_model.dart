import 'package:equatable/equatable.dart';

class DecidingInRequestModel extends Equatable {
  final int requestType; // نوع الطلب
  final int requestId; // رقم الطلب
  final int actionType; // الاجراء المتخذ 1 موافق 2 غير موافق 3 اجراء
  final int actionMakerEmpID; // اليوزر الى موجود فى الtoken
  final String strNotes; // الشرح
  final int isLastDecidingEmp; // 1 اخر شخص، 0 لا
  final int haveSpecialDecide; // 0 حالياً
  final int? specialDecideEmpId; // فاضية حاليا

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
