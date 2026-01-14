import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/features/setting/data/model/change_password_resquest.dart';
import 'package:my_template/features/setting/data/model/time_sheet_in_request.dart';
import 'package:my_template/features/setting/data/model/time_sheet_out_request.dart';
import 'package:my_template/features/setting/data/repo/setting_repo.dart';
import 'package:my_template/features/setting/presentation/cubit/setting_state.dart';


class SettingCubit extends Cubit<SettingState> {
  final SettingRepo settingRepo;

  SettingCubit(this.settingRepo) : super(const SettingState());

  Future<void> changePassword(ChangePasswordRequest request) async {
    emit(state.copyWith(changePasswordStatus: const StatusState.loading()));

    final result = await settingRepo.changePassword(request);

    result.fold(
      (failure) {
        emit(state.copyWith(changePasswordStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(changePasswordStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> addTimeSheetIn(TimeSheetInRequestmodel request) async {
    emit(state.copyWith(timeSheetStatus: const StatusState.loading()));

    CommonMethods.showToast(message: AppLocalKay.loading.tr(), type: ToastType.help);
    final result = await settingRepo.addTimeSheetIn(request);

    result.fold(
      (failure) {
        emit(state.copyWith(timeSheetStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(timeSheetStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> addTimeSheetOut(TimeSheetOutRequestModel request) async {
    emit(state.copyWith(timeSheetOutStatus: const StatusState.loading()));
    CommonMethods.showToast(message: AppLocalKay.loading.tr(), type: ToastType.help);
    final result = await settingRepo.addTimeSheetOut(request);

    result.fold(
      (failure) {
        emit(state.copyWith(timeSheetOutStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(timeSheetOutStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> getTimeSheet(String day, int empcode) async {
    emit(state.copyWith(timeSheetListStatus: const StatusState.loading()));

    final result = await settingRepo.getTimeSheet(day, empcode);

    result.fold(
      (failure) {
        emit(state.copyWith(timeSheetListStatus: StatusState.failure(failure.errMessage)));
      },
      (timeSheets) {
        // timeSheets هنا List<TimeSheetModel>
        emit(state.copyWith(timeSheetListStatus: StatusState.success(timeSheets)));
      },
    );
  }

  Future<void> employeeSalary(int year, int empcode, int month, String lang) async {
    emit(state.copyWith(employeeSalaryStatus: const StatusState.loading()));

    final result = await settingRepo.getEmployeeSalary(empcode, month, year, lang);

    result.fold(
      (failure) {
        emit(state.copyWith(employeeSalaryStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(employeeSalaryStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> employeeMobileSerialno(int empcode) async {
    emit(state.copyWith(mobileSerialnoStatus: const StatusState.loading()));

    final result = await settingRepo.employeeMobileSerialno(empcode);

    result.fold(
      (failure) {
        emit(state.copyWith(mobileSerialnoStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(mobileSerialnoStatus: StatusState.success(response)));
      },
    );
  }
}
