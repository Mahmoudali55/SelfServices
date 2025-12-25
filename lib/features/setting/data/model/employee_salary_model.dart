import 'dart:convert';

import 'package:equatable/equatable.dart';

class EmployeeSalaryModel extends Equatable {
  final List<EmployeeSalaryItem> data;

  const EmployeeSalaryModel({required this.data});

  factory EmployeeSalaryModel.fromJson(Map<String, dynamic> json) {
    final dataStr = json['Data'] as String?;
    if (dataStr == null) return const EmployeeSalaryModel(data: []);

    final List<dynamic> parsedList = jsonDecode(dataStr);
    return EmployeeSalaryModel(
      data: parsedList.map((e) => EmployeeSalaryItem.fromJson(e)).toList(),
    );
  }

  @override
  List<Object?> get props => [data];
}

class EmployeeSalaryItem extends Equatable {
  final int? empCd;
  final String? varType;
  final int? varCd;
  final double? varVal;
  final int? depCd;
  final int? braCd;
  final int? month1;
  final int? year1;
  final double? varVal1;
  final String? stopDis;
  final dynamic salary;
  final int? pSarf;
  final String? deltaConfig;
  final String? paName;
  final String? paNameE;
  final String? pEffect;
  final String? reportEffect;
  final String? discription;
  final String? discriptionE;
  final dynamic itCase;
  final double? balance;
  final double? itVal;
  final dynamic monthNo;
  final dynamic adjValue;
  final String? dName;
  final String? dNameE;
  final String? bName;
  final String? bNameE;
  final String? companyName;
  final String? companyNameE;
  final String? companyAddress;
  final String? companyAddressE;
  final String? empName;
  final String? empNameE;
  final int? jobCase;
  final String? empHireDate;
  final String? currency;
  final String? eCurrency;
  final dynamic currencyFraction;
  final dynamic eCurrencyFraction;
  final int? placeId;
  final String? placeName;
  final String? placeEName;
  final dynamic employeeNo;
  final int? jobCode;
  final String? jobName;
  final String? jobEName;
  final double? workDays;
  final String? accountNo;
  final int? projId;
  final String? projName;
  final String? projEName;
  final int? nationCode;
  final String? nationName;
  final String? nationEName;
  final String? paType;
  final String? notes;
  final String? notes1;
  final int? sarafCode;
  final int? sCode;
  final String? sName;
  final String? sNameE;
  final double? val1;
  final int? empCd1;
  final String? tafkeet;

  const EmployeeSalaryItem({
    this.empCd,
    this.varType,
    this.varCd,
    this.varVal,
    this.depCd,
    this.braCd,
    this.month1,
    this.year1,
    this.varVal1,
    this.stopDis,
    this.salary,
    this.pSarf,
    this.deltaConfig,
    this.paName,
    this.paNameE,
    this.pEffect,
    this.reportEffect,
    this.discription,
    this.discriptionE,
    this.itCase,
    this.balance,
    this.itVal,
    this.monthNo,
    this.adjValue,
    this.dName,
    this.dNameE,
    this.bName,
    this.bNameE,
    this.companyName,
    this.companyNameE,
    this.companyAddress,
    this.companyAddressE,
    this.empName,
    this.empNameE,
    this.jobCase,
    this.empHireDate,
    this.currency,
    this.eCurrency,
    this.currencyFraction,
    this.eCurrencyFraction,
    this.placeId,
    this.placeName,
    this.placeEName,
    this.employeeNo,
    this.jobCode,
    this.jobName,
    this.jobEName,
    this.workDays,
    this.accountNo,
    this.projId,
    this.projName,
    this.projEName,
    this.nationCode,
    this.nationName,
    this.nationEName,
    this.paType,
    this.notes,
    this.notes1,
    this.sarafCode,
    this.sCode,
    this.sName,
    this.sNameE,
    this.val1,
    this.empCd1,
    this.tafkeet,
  });

  factory EmployeeSalaryItem.fromJson(Map<String, dynamic> json) {
    return EmployeeSalaryItem(
      empCd: (json['EMP_CD'] as num?)?.toInt(),
      varType: json['VAR_TYPE'],
      varCd: (json['VAR_CD'] as num?)?.toInt(),
      varVal: (json['VAR_VAL'] as num?)?.toDouble(),
      depCd: (json['DEP_CD'] as num?)?.toInt(),
      braCd: (json['BRA_CD'] as num?)?.toInt(),
      month1: (json['MONTH1'] as num?)?.toInt(),
      year1: (json['YEAR1'] as num?)?.toInt(),
      varVal1: (json['VAR_VAL1'] as num?)?.toDouble(),
      stopDis: json['STOP_DIS'],
      salary: json['SALARY'],
      pSarf: (json['P_SARF'] as num?)?.toInt(),
      deltaConfig: json['DELTACONFIG'],
      paName: json['PA_NAME'],
      paNameE: json['PA_NAME_E'],
      pEffect: json['P_EFFECT'],
      reportEffect: json['REPORT_EFFECT'],
      discription: json['DISCRIPTION'],
      discriptionE: json['DISCRIPTION_E'],
      itCase: json['IT_CASE'],
      balance: (json['BALANCE'] as num?)?.toDouble(),
      itVal: (json['IT_VAL'] as num?)?.toDouble(),
      monthNo: json['MONTH_NO'],
      adjValue: json['ADJ_VLUE'],
      dName: json['D_NAME'],
      dNameE: json['D_NAME_E'],
      bName: json['B_NAME'],
      bNameE: json['B_NAME_E'],
      companyName: json['COMPANY_NAME'],
      companyNameE: json['COMPANY_NAME_E'],
      companyAddress: json['COMPANY_ADDRESS'],
      companyAddressE: json['COMPANY_ADDRESS_E'],
      empName: json['EMP_NAME'],
      empNameE: json['EMP_NAME_E'],
      jobCase: (json['JOB_CASE'] as num?)?.toInt(),
      empHireDate: json['EMP_HIRE_DATE'],
      currency: json['CURRENCY'],
      eCurrency: json['ECURRENCY'],
      currencyFraction: json['CURRENCY_FRACTION'],
      eCurrencyFraction: json['ECURRENCY_FRACTION'],
      placeId: (json['PLACE_ID'] as num?)?.toInt(),
      placeName: json['PLACE_NAME'],
      placeEName: json['PLACE_ENAME'],
      employeeNo: json['EMPLOYEE_NO'],
      jobCode: (json['JOB_CODE'] as num?)?.toInt(),
      jobName: json['JOB_NAME'],
      jobEName: json['JOB_ENAME'],
      workDays: (json['WORK_DAYS'] as num?)?.toDouble(),
      accountNo: json['ACCOUNT_NO'],
      projId: (json['PROJ_ID'] as num?)?.toInt(),
      projName: json['PROJ_NAME'],
      projEName: json['PROJ_ENAME'],
      nationCode: (json['NATION_CODE'] as num?)?.toInt(),
      nationName: json['NATION_NAME'],
      nationEName: json['NATION_ENAME'],
      paType: json['PA_TYPE'],
      notes: json['NOTES'],
      notes1: json['NOTES1'],
      sarafCode: (json['SARAF_CODE'] as num?)?.toInt(),
      sCode: (json['S_CODE'] as num?)?.toInt(),
      sName: json['S_NAME'],
      sNameE: json['S_NAME_E'],
      val1: (json['VAL1'] as num?)?.toDouble(),
      empCd1: (json['EMP_CD1'] as num?)?.toInt(),
      tafkeet: json['Tafkeet'],
    );
  }

  @override
  List<Object?> get props => [
    empCd,
    varType,
    varCd,
    varVal,
    depCd,
    braCd,
    month1,
    year1,
    varVal1,
    stopDis,
    salary,
    pSarf,
    deltaConfig,
    paName,
    paNameE,
    pEffect,
    reportEffect,
    discription,
    discriptionE,
    itCase,
    balance,
    itVal,
    monthNo,
    adjValue,
    dName,
    dNameE,
    bName,
    bNameE,
    companyName,
    companyNameE,
    companyAddress,
    companyAddressE,
    empName,
    empNameE,
    jobCase,
    empHireDate,
    currency,
    eCurrency,
    currencyFraction,
    eCurrencyFraction,
    placeId,
    placeName,
    placeEName,
    employeeNo,
    jobCode,
    jobName,
    jobEName,
    workDays,
    accountNo,
    projId,
    projName,
    projEName,
    nationCode,
    nationName,
    nationEName,
    paType,
    notes,
    notes1,
    sarafCode,
    sCode,
    sName,
    sNameE,
    val1,
    empCd1,
    tafkeet,
  ];
}
