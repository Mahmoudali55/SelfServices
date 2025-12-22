import 'package:equatable/equatable.dart';

class AttachmentModel extends Equatable {
  final String? attachmentName;
  final String? attachmentFileName;

  const AttachmentModel({this.attachmentName, this.attachmentFileName});

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      attachmentName: json['AttatchmentName'] as String?,
      attachmentFileName: json['AttchmentFileName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'AttatchmentName': attachmentName, 'AttchmentFileName': attachmentFileName};
  }

  @override
  List<Object?> get props => [attachmentName, attachmentFileName];
}

class VacationRequestToDecideModel extends Equatable {
  final int? requestId;
  final int? requestType;
  final int? empCode;
  final String? empArName;
  final String? empEngName;
  final int? empDeptID;
  final String? empDeptArName;
  final String? empDeptEngName;
  final String? strRequestType;
  final int? reqDecideState;
  final int? isLastDecidingEmp;
  final String? strNotes;
  final String? insrtDate;
  final int? branchCode;
  final String? branchName;
  final int? nxtEmpCode;
  final int? alarmDayPeriod;
  final String? vacTypeNameAr;
  final String? vacTypeNameEng;
  final int? attachCount;
  final int? isDelayed;
  final String? manipulationNote;
  final String? cAUSES;
  final String? attatchmentName;
  final String? AttchmentFileName;
  final List<AttachmentModel> attachments;

  const VacationRequestToDecideModel({
    this.requestId,
    this.requestType,
    this.empCode,
    this.empArName,
    this.empEngName,
    this.empDeptID,
    this.empDeptArName,
    this.empDeptEngName,
    this.strRequestType,
    this.reqDecideState,
    this.isLastDecidingEmp,
    this.strNotes,
    this.insrtDate,
    this.branchCode,
    this.branchName,
    this.nxtEmpCode,
    this.alarmDayPeriod,
    this.vacTypeNameAr,
    this.vacTypeNameEng,
    this.attachCount,
    this.isDelayed,
    this.manipulationNote,
    this.cAUSES,
    this.attatchmentName,
    this.AttchmentFileName,
    this.attachments = const [],
  });

  factory VacationRequestToDecideModel.fromJson(Map<String, dynamic> json) {
    return VacationRequestToDecideModel(
      requestId: json['RequestId'] as int?,
      requestType: json['RequestType'] as int?,
      empCode: json['EmpCode'] as int?,
      empArName: json['EmpArName'] as String?,
      empEngName: json['EmpEngName'] as String?,
      empDeptID: json['EmpDeptID'] as int?,
      empDeptArName: json['EmpDeptArName'] as String?,
      empDeptEngName: json['EmpDeptEngName'] as String?,
      strRequestType: json['StrRequestType'] as String?,
      reqDecideState: json['ReqDecideState'] as int?,
      isLastDecidingEmp: json['IsLastDecidingEmp'] as int?,
      strNotes: json['strNotes'] as String?,
      insrtDate: json['InsrtDate'] as String?,
      branchCode: json['BranchCode'] as int?,
      branchName: json['BranchName'] as String?,
      nxtEmpCode: json['NxtEmpCode'] as int?,
      alarmDayPeriod: json['AlarmDayPeriod'] as int?,
      vacTypeNameAr: json['VacTypeNameAr'] as String?,
      vacTypeNameEng: json['VacTypeNameEng'] as String?,
      attachCount: json['AttachCount'] as int?,
      isDelayed: json['IsDelayed'] as int?,
      manipulationNote: json['ManipulationNote'] as String?,
      cAUSES: json['CAUSES'] as String?,
      attatchmentName: json['AttatchmentName'] as String?,
      AttchmentFileName: json['AttchmentFileName'] as String?,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
                .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RequestId': requestId,
      'RequestType': requestType,
      'EmpCode': empCode,
      'EmpArName': empArName,
      'EmpEngName': empEngName,
      'EmpDeptID': empDeptID,
      'EmpDeptArName': empDeptArName,
      'EmpDeptEngName': empDeptEngName,
      'StrRequestType': strRequestType,
      'ReqDecideState': reqDecideState,
      'IsLastDecidingEmp': isLastDecidingEmp,
      'strNotes': strNotes,
      'InsrtDate': insrtDate,
      'BranchCode': branchCode,
      'BranchName': branchName,
      'NxtEmpCode': nxtEmpCode,
      'AlarmDayPeriod': alarmDayPeriod,
      'VacTypeNameAr': vacTypeNameAr,
      'VacTypeNameEng': vacTypeNameEng,
      'AttachCount': attachCount,
      'IsDelayed': isDelayed,
      'ManipulationNote': manipulationNote,
      'CAUSES': cAUSES,
      'AttatchmentName': attatchmentName,
      'AttchmentFileName': AttchmentFileName,
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }

  VacationRequestToDecideModel copyWith({List<AttachmentModel>? attachments}) {
    return VacationRequestToDecideModel(
      requestId: requestId,
      requestType: requestType,
      empCode: empCode,
      empArName: empArName,
      empEngName: empEngName,
      empDeptID: empDeptID,
      empDeptArName: empDeptArName,
      empDeptEngName: empDeptEngName,
      strRequestType: strRequestType,
      reqDecideState: reqDecideState,
      isLastDecidingEmp: isLastDecidingEmp,
      strNotes: strNotes,
      insrtDate: insrtDate,
      branchCode: branchCode,
      branchName: branchName,
      nxtEmpCode: nxtEmpCode,
      alarmDayPeriod: alarmDayPeriod,
      vacTypeNameAr: vacTypeNameAr,
      vacTypeNameEng: vacTypeNameEng,
      attachCount: attachCount,
      isDelayed: isDelayed,
      manipulationNote: manipulationNote,
      cAUSES: cAUSES,
      attatchmentName: attatchmentName,
      AttchmentFileName: AttchmentFileName,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object?> get props => [
    requestId,
    requestType,
    empCode,
    empArName,
    empEngName,
    empDeptID,
    empDeptArName,
    empDeptEngName,
    strRequestType,
    reqDecideState,
    isLastDecidingEmp,
    strNotes,
    insrtDate,
    branchCode,
    branchName,
    nxtEmpCode,
    alarmDayPeriod,
    vacTypeNameAr,
    vacTypeNameEng,
    attachCount,
    isDelayed,
    manipulationNote,
    cAUSES,
    attatchmentName,
    AttchmentFileName,
    attachments,
  ];
}
