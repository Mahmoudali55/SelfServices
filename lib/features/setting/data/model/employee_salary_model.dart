import 'dart:convert';

import 'package:equatable/equatable.dart';

class EmployeeSalaryModel extends Equatable {
  final List<EmployeeSalaryItem> data;

  const EmployeeSalaryModel({required this.data});

  factory EmployeeSalaryModel.fromJson(Map<String, dynamic> json) {
    final dataStr = json['Data'] as String?;
    if (dataStr == null) return const EmployeeSalaryModel(data: []);
    final List<dynamic> parsedList = jsonDecode(dataStr);
    final items = parsedList.map((e) => EmployeeSalaryItem.fromJson(e)).toList();
    return EmployeeSalaryModel(data: items);
  }

  Map<String, dynamic> toJson() {
    return {'Data': jsonEncode(data.map((e) => e.toJson()).toList())};
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
  final dynamic balance;
  final dynamic itVal;
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
  final int? workDays;
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
      empCd: json['EMP_CD'],
      varType: json['VAR_TYPE'],
      varCd: json['VAR_CD'],
      varVal: (json['VAR_VAL'] as num?)?.toDouble(),
      depCd: json['DEP_CD'],
      braCd: json['BRA_CD'],
      month1: json['MONTH1'],
      year1: json['YEAR1'],
      varVal1: (json['VAR_VAL1'] as num?)?.toDouble(),
      stopDis: json['STOP_DIS'],
      salary: json['SALARY'],
      pSarf: json['P_SARF'],
      deltaConfig: json['DELTACONFIG'],
      paName: json['PA_NAME'],
      paNameE: json['PA_NAME_E'],
      pEffect: json['P_EFFECT'],
      reportEffect: json['REPORT_EFFECT'],
      discription: json['DISCRIPTION'],
      discriptionE: json['DISCRIPTION_E'],
      itCase: json['IT_CASE'],
      balance: json['BALANCE'],
      itVal: json['IT_VAL'],
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
      jobCase: json['JOB_CASE'],
      empHireDate: json['EMP_HIRE_DATE'],
      currency: json['CURRENCY'],
      eCurrency: json['ECURRENCY'],
      currencyFraction: json['CURRENCY_FRACTION'],
      eCurrencyFraction: json['ECURRENCY_FRACTION'],
      placeId: json['PLACE_ID'],
      placeName: json['PLACE_NAME'],
      placeEName: json['PLACE_ENAME'],
      employeeNo: json['EMPLOYEE_NO'],
      jobCode: json['JOB_CODE'],
      jobName: json['JOB_NAME'],
      jobEName: json['JOB_ENAME'],
      workDays: json['WORK_DAYS'],
      accountNo: json['ACCOUNT_NO'],
      projId: json['PROJ_ID'],
      projName: json['PROJ_NAME'],
      projEName: json['PROJ_ENAME'],
      nationCode: json['NATION_CODE'],
      nationName: json['NATION_NAME'],
      nationEName: json['NATION_ENAME'],
      paType: json['PA_TYPE'],
      notes: json['NOTES'],
      notes1: json['NOTES1'],
      sarafCode: json['SARAF_CODE'],
      sCode: json['S_CODE'],
      sName: json['S_NAME'],
      sNameE: json['S_NAME_E'],
      val1: (json['VAL1'] as num?)?.toDouble(),
      empCd1: json['EMP_CD1'],
      tafkeet: json['Tafkeet'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EMP_CD': empCd,
      'VAR_TYPE': varType,
      'VAR_CD': varCd,
      'VAR_VAL': varVal,
      'DEP_CD': depCd,
      'BRA_CD': braCd,
      'MONTH1': month1,
      'YEAR1': year1,
      'VAR_VAL1': varVal1,
      'STOP_DIS': stopDis,
      'SALARY': salary,
      'P_SARF': pSarf,
      'DELTACONFIG': deltaConfig,
      'PA_NAME': paName,
      'PA_NAME_E': paNameE,
      'P_EFFECT': pEffect,
      'REPORT_EFFECT': reportEffect,
      'DISCRIPTION': discription,
      'DISCRIPTION_E': discriptionE,
      'IT_CASE': itCase,
      'BALANCE': balance,
      'IT_VAL': itVal,
      'MONTH_NO': monthNo,
      'ADJ_VLUE': adjValue,
      'D_NAME': dName,
      'D_NAME_E': dNameE,
      'B_NAME': bName,
      'B_NAME_E': bNameE,
      'COMPANY_NAME': companyName,
      'COMPANY_NAME_E': companyNameE,
      'COMPANY_ADDRESS': companyAddress,
      'COMPANY_ADDRESS_E': companyAddressE,
      'EMP_NAME': empName,
      'EMP_NAME_E': empNameE,
      'JOB_CASE': jobCase,
      'EMP_HIRE_DATE': empHireDate,
      'CURRENCY': currency,
      'ECURRENCY': eCurrency,
      'CURRENCY_FRACTION': currencyFraction,
      'ECURRENCY_FRACTION': eCurrencyFraction,
      'PLACE_ID': placeId,
      'PLACE_NAME': placeName,
      'PLACE_ENAME': placeEName,
      'EMPLOYEE_NO': employeeNo,
      'JOB_CODE': jobCode,
      'JOB_NAME': jobName,
      'JOB_ENAME': jobEName,
      'WORK_DAYS': workDays,
      'ACCOUNT_NO': accountNo,
      'PROJ_ID': projId,
      'PROJ_NAME': projName,
      'PROJ_ENAME': projEName,
      'NATION_CODE': nationCode,
      'NATION_NAME': nationName,
      'NATION_ENAME': nationEName,
      'PA_TYPE': paType,
      'NOTES': notes,
      'NOTES1': notes1,
      'SARAF_CODE': sarafCode,
      'S_CODE': sCode,
      'S_NAME': sName,
      'S_NAME_E': sNameE,
      'VAL1': val1,
      'EMP_CD1': empCd1,
      'Tafkeet': tafkeet,
    };
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
