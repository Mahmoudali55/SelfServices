import 'dart:convert';

import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String empName;
  final String empNameE;
  final int dCode;
  final String dName;
  final String dNameE;
  final int empCode;
  final String empPw;
  final String? jobName;
  final String? jobEName;
  final String? emailAddress;
  final int bCode;
  final String bName;
  final String bNameE;
  final int projectId;
  final String projectName;
  final String projectNameEng;
  final String empHireDate;
  final String natName;
  final String natNameEng;
  final String cardNumber;
  final String? accountNo;
  final int sarafCode;
  final String sName;
  final String sNameE;
  final String bankCode;
  final String hiringDate;
  final double holiday;
  final String passNo;
  final String passEndDate;
  final String idEDate;
  final String lastVacationEndDate;
  final String? empPhotoWeb; 

  const ProfileModel({
    required this.empName,
    required this.empNameE,
    required this.dCode,
    required this.dName,
    required this.dNameE,
    required this.empCode,
    required this.empPw,
    this.jobName,
    this.jobEName,
    this.emailAddress,
    required this.bCode,
    required this.bName,
    required this.bNameE,
    required this.projectId,
    required this.projectName,
    required this.projectNameEng,
    required this.empHireDate,
    required this.natName,
    required this.natNameEng,
    required this.cardNumber,
    this.accountNo,
    required this.sarafCode,
    required this.sName,
    required this.sNameE,
    required this.bankCode,
    required this.hiringDate,
    required this.holiday,
    required this.passNo,
    required this.passEndDate,
    required this.idEDate,
    required this.lastVacationEndDate,
    this.empPhotoWeb, 
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      empName: json['EMP_NAME'] ?? '',
      empNameE: json['EMP_NAME_E'] ?? '',
      dCode: json['D_CODE'] ?? 0,
      dName: json['D_NAME'] ?? '',
      dNameE: json['D_NAME_E'] ?? '',
      empCode: json['EMP_CODE'] ?? 0,
      empPw: json['EMP_PW'] ?? '',
      jobName: json['JOB_NAME'],
      jobEName: json['JOB_ENAME'],
      emailAddress: json['EMAIL_ADDRESS'],
      bCode: json['B_Code'] ?? 0,
      bName: json['B_NAME'] ?? '',
      bNameE: json['B_NAME_E'] ?? '',
      projectId: json['ProjectID'] ?? 0,
      projectName: json['ProjectName'] ?? '',
      projectNameEng: json['ProjectNameEng'] ?? '',
      empHireDate: json['EMP_HIRE_DATE'] ?? '',
      natName: json['NatName'] ?? '',
      natNameEng: json['NatNameEng'] ?? '',
      cardNumber: json['CARD_NUMBER'] ?? '',
      accountNo: json['ACCOUNT_NO'],
      sarafCode: json['SARAF_CODE'] ?? 0,
      sName: json['S_NAME'] ?? '',
      sNameE: json['S_NAME_E'] ?? '',
      bankCode: json['BANK_CODE'] ?? '',
      hiringDate: json['HiringDate'] ?? '',
      holiday: (json['Holiday'] as num?)?.toDouble() ?? 0.0,
      passNo: json['Pass_No'] ?? '',
      passEndDate: json['Pass_End_Date'] ?? '',
      idEDate: json['ID_E_DATE'] ?? '',
      lastVacationEndDate: json['LastVacationEndDate'] ?? '',
      empPhotoWeb: json['EMP_Photo_Web'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EMP_NAME': empName,
      'EMP_NAME_E': empNameE,
      'D_CODE': dCode,
      'D_NAME': dName,
      'D_NAME_E': dNameE,
      'EMP_CODE': empCode,
      'EMP_PW': empPw,
      'JOB_NAME': jobName,
      'JOB_ENAME': jobEName,
      'EMAIL_ADDRESS': emailAddress,
      'B_Code': bCode,
      'B_NAME': bName,
      'B_NAME_E': bNameE,
      'ProjectID': projectId,
      'ProjectName': projectName,
      'ProjectNameEng': projectNameEng,
      'EMP_HIRE_DATE': empHireDate,
      'NatName': natName,
      'NatNameEng': natNameEng,
      'CARD_NUMBER': cardNumber,
      'ACCOUNT_NO': accountNo,
      'SARAF_CODE': sarafCode,
      'S_NAME': sName,
      'S_NAME_E': sNameE,
      'BANK_CODE': bankCode,
      'HiringDate': hiringDate,
      'Holiday': holiday,
      'Pass_No': passNo,
      'Pass_End_Date': passEndDate,
      'ID_E_DATE': idEDate,
      'LastVacationEndDate': lastVacationEndDate,
      'EMP_Photo_Web': empPhotoWeb, 
    };
  }

  static List<ProfileModel> listFromResponse(Map<String, dynamic> response) {
    final dataString = response['Data'] ?? '[]';
    final List<dynamic> dataList = jsonDecode(dataString);
    return dataList.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  List<Object?> get props => [
    empName,
    empNameE,
    dCode,
    dName,
    dNameE,
    empCode,
    empPw,
    jobName,
    jobEName,
    emailAddress,
    bCode,
    bName,
    bNameE,
    projectId,
    projectName,
    projectNameEng,
    empHireDate,
    natName,
    natNameEng,
    cardNumber,
    accountNo,
    sarafCode,
    sName,
    sNameE,
    bankCode,
    hiringDate,
    holiday,
    passNo,
    passEndDate,
    idEDate,
    lastVacationEndDate,
    empPhotoWeb, 
  ];
}
