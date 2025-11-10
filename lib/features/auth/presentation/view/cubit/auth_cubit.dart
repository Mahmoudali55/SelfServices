import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/network/connection_checker.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/auth/data/repository/auth_repo.dart';
import 'package:my_template/features/auth/presentation/view/screen/widget/normalize_arabic_Input.dart';
import 'package:my_template/features/setting/presentation/screen/widget/show_change_password_sheet_widget.dart';

import '../../../data/model/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  final ConnectionChecker connectionChecker;

  AuthCubit(this.authRepo, this.connectionChecker) : super(const AuthState());

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool rememberMe = false;

  set mobile(String mobile) => mobileController.text = mobile;
  set password(String password) => passwordController.text = password;

  void changeRememberMe() {
    rememberMe = !rememberMe;
    emit(state.copyWith());
  }

  Future<void> login({BuildContext? context}) async {
    final isConnected = await connectionChecker.isConnected;
    if (!isConnected) {
      CommonMethods.showToast(
        message: context != null
            ? (context.locale.languageCode == 'ar'
                  ? 'لا يوجد اتصال بالإنترنت'
                  : 'No internet connection')
            : 'No internet connection',
        type: ToastType.error,
      );
      return;
    }
    final normalizedMobile = normalizeArabicInput(mobileController.text);
    final normalizedPassword = normalizeArabicInput(passwordController.text);

    emit(state.copyWith(loginStatus: const StatusState.loading()));

    final result = await authRepo.login(mobile: normalizedMobile, password: normalizedPassword);

    result.fold(
      (error) => emit(state.copyWith(loginStatus: StatusState.failure(error.errMessage))),
      (success) {
        HiveMethods.updateToken(success.accessToken);
        HiveMethods.getLang();
        HiveMethods.updateEmpNameAr(success.user.empName);
        HiveMethods.updateEmpNameEN(success.user.empNameE);
        HiveMethods.updateEmpCode(success.user.empCode);
        HiveMethods.updateEmpPassword(passwordController.text);
        emit(state.copyWith(loginStatus: StatusState.success(success)));
      },
    );
  }

  void submitLogin(BuildContext context) {
    if (formKey.currentState!.validate()) {
      login(context: context);
    }
  }

  String? validatePassword(value, BuildContext context) {
    final bool isFirstLogin = HiveMethods.getToken() == null;
    if (!isFirstLogin) {
      if (value == null || value.isEmpty) {
        return context.locale.languageCode == 'ar' ? 'ادخل كلمة المرور' : 'Enter password';
      }
    }
    return null;
  }

  String? validateMobile(value, BuildContext context) => value!.isEmpty
      ? context.locale.languageCode == 'ar'
            ? 'ادخل رقم الموظف'
            : 'Enter mobile'
      : null;

  void onLoginSuccess({
    required BuildContext context,
    required AuthState state,
    required String languageCode,
  }) {
    if (state.loginStatus.isSuccess) {
      CommonMethods.showToast(
        message: languageCode == 'ar' ? 'تم تسجيل الدخول بنجاح' : 'Login successful',
        type: ToastType.success,
      );
      if (HiveMethods.getToken() == null) {
        showChangePasswordSheet(context);
      } else {
        NavigatorMethods.pushNamedAndRemoveUntil(
          context,
          RoutesName.layoutScreen,
          arguments: {
            'username': languageCode == 'ar'
                ? state.loginStatus.data?.user.empName
                : state.loginStatus.data?.user.empNameE,
            'empCode': int.tryParse(state.loginStatus.data?.user.empCode ?? '0') ?? 0,
          },
        );
      }
    }

    if (state.loginStatus.isFailure) {
      final error =
          state.loginStatus.error ?? (languageCode == 'ar' ? 'فشل تسجيل الدخول' : 'Login failed');
      CommonMethods.showToast(message: error, type: ToastType.error);
    }
  }
}
