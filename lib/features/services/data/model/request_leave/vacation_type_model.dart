import 'package:equatable/equatable.dart';

class VacationTypeModel extends Equatable {
  final int? codeGpf;
  final String? nameGpf;
  final String? nameGpfE;
  final int minimumVacDayCount;
  final int periodToMakeVac;
  final int allowSalaryDisc;
  final int allowBalancDisc;
  final String? codeGpf2;
  final String? vacJobcase;

  const VacationTypeModel({
    this.codeGpf,
    this.nameGpf,
    this.nameGpfE,
    this.minimumVacDayCount = 0,
    this.periodToMakeVac = 0,
    this.allowSalaryDisc = 0,
    this.allowBalancDisc = 0,
    this.codeGpf2,
    this.vacJobcase,
  });

  /// تحويل JSON إلى موديل
  factory VacationTypeModel.fromJson(Map<String, dynamic> json) {
    return VacationTypeModel(
      codeGpf: json['CODE_GPF'] is int
          ? json['CODE_GPF']
          : int.tryParse(json['CODE_GPF'].toString()) ?? 0,
      nameGpf: json['NAME_GPF']?.toString(),
      nameGpfE: json['NAME_GPF_E']?.toString(),
      minimumVacDayCount: json['MinimumVacDayCount'] ?? 0,
      periodToMakeVac: json['PeriodToMakeVac'] ?? 0,
      allowSalaryDisc: json['AllowSalaryDisc'] ?? 0,
      allowBalancDisc: json['AllowBalancDisc'] ?? 0,
      codeGpf2: json['CODE_GPF2']?.toString(),
      vacJobcase: json['Vac_jobcase']?.toString(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'CODE_GPF': codeGpf,
      'NAME_GPF': nameGpf,
      'NAME_GPF_E': nameGpfE,
      'MinimumVacDayCount': minimumVacDayCount,
      'PeriodToMakeVac': periodToMakeVac,
      'AllowSalaryDisc': allowSalaryDisc,
      'AllowBalancDisc': allowBalancDisc,
      'CODE_GPF2': codeGpf2,
      'Vac_jobcase': vacJobcase,
    };
  }

  @override
  List<Object?> get props => [
    codeGpf,
    nameGpf,
    nameGpfE,
    minimumVacDayCount,
    periodToMakeVac,
    allowSalaryDisc,
    allowBalancDisc,
    codeGpf2,
    vacJobcase,
  ];
}
