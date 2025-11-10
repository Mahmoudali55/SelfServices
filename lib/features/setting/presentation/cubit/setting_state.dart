import 'package:equatable/equatable.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/features/setting/data/model/change_password_response.dart';
import 'package:my_template/features/setting/data/model/employee_salary_model.dart';
import 'package:my_template/features/setting/data/model/mobile_response_model.dart';
import 'package:my_template/features/setting/data/model/time_sheet_model.dart';
import 'package:my_template/features/setting/data/model/time_sheet_response.dart';

class SettingState extends Equatable {
  final StatusState<ChangePasswordResponse> changePasswordStatus;
  final StatusState<TimeSheetResponse> timeSheetStatus;
  final StatusState<TimeSheetResponse> timeSheetOutStatus;
  final StatusState<List<TimeSheetModel>> timeSheetListStatus;
  final StatusState<EmployeeSalaryModel> employeeSalaryStatus;
  final StatusState<MobileResponse> mobileSerialnoStatus;

  const SettingState({
    this.changePasswordStatus = const StatusState.initial(),
    this.timeSheetStatus = const StatusState.initial(),
    this.timeSheetOutStatus = const StatusState.initial(),
    this.timeSheetListStatus = const StatusState.initial(),
    this.employeeSalaryStatus = const StatusState.initial(),
    this.mobileSerialnoStatus = const StatusState.initial(),
  });

  SettingState copyWith({
    StatusState<ChangePasswordResponse>? changePasswordStatus,
    StatusState<TimeSheetResponse>? timeSheetStatus,
    StatusState<TimeSheetResponse>? timeSheetOutStatus,
    StatusState<List<TimeSheetModel>>? timeSheetListStatus,
    StatusState<EmployeeSalaryModel>? employeeSalaryStatus,
    StatusState<MobileResponse>? mobileSerialnoStatus,
  }) {
    return SettingState(
      changePasswordStatus: changePasswordStatus ?? this.changePasswordStatus,
      timeSheetStatus: timeSheetStatus ?? this.timeSheetStatus,
      timeSheetOutStatus: timeSheetOutStatus ?? this.timeSheetOutStatus,
      timeSheetListStatus: timeSheetListStatus ?? this.timeSheetListStatus,
      employeeSalaryStatus: employeeSalaryStatus ?? this.employeeSalaryStatus,
      mobileSerialnoStatus: mobileSerialnoStatus ?? this.mobileSerialnoStatus,
    );
  }

  @override
  List<Object?> get props => [
    changePasswordStatus,
    timeSheetStatus,
    timeSheetOutStatus,
    timeSheetListStatus,
    employeeSalaryStatus,
    mobileSerialnoStatus,
  ];
}
