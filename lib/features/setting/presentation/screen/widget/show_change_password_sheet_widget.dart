import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/features/setting/data/model/change_password_resquest.dart';
import 'package:my_template/features/setting/presentation/cubit/setting_state.dart';
import 'package:my_template/features/setting/presentation/cubit/settting_cubit.dart';

void showChangePasswordSheet(BuildContext context) {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final storedPassword = HiveMethods.getEmpPassword();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: storedPassword == null || storedPassword.isEmpty || storedPassword == ''
        ? false
        : true,
    enableDrag: storedPassword == null || storedPassword.isEmpty || storedPassword == ''
        ? false
        : true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return WillPopScope(
        // ✅ يمنع إغلاق الـ BottomSheet بزر الرجوع
        onWillPop: () async => false,
        child: BlocProvider.value(
          value: context.read<SettingCubit>(),
          child: BlocListener<SettingCubit, SettingState>(
            listener: (context, state) {
              final status = state.changePasswordStatus;

              if (status.isSuccess) {
                CommonMethods.showToast(
                  message: context.locale.languageCode == 'ar'
                      ? 'تم تغيير كلمة المرور بنجاح'
                      : 'Password changed successfully',
                  type: ToastType.success,
                );

                HiveMethods.updateEmpPassword(passwordController.text.trim());

                Navigator.pop(context);
              } else if (status.isFailure) {
                CommonMethods.showToast(
                  message: status.message ?? 'حدث خطأ ما',
                  type: ToastType.error,
                );
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 30,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalKay.enterNewPassword.tr(),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // كلمة المرور الجديدة
                      CustomFormField(
                        controller: passwordController,
                        title: AppLocalKay.password.tr(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.locale.languageCode == 'ar'
                                ? 'الرجاء إدخال كلمة المرور الجديدة'
                                : 'Please enter a new password';
                          }
                          if (value.length < 6) {
                            return context.locale.languageCode == 'ar'
                                ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                                : 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // تأكيد كلمة المرور
                      CustomFormField(
                        controller: confirmController,
                        title: AppLocalKay.confirmPassword.tr(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.locale.languageCode == 'ar'
                                ? 'الرجاء تأكيد كلمة المرور'
                                : 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return context.locale.languageCode == 'ar'
                                ? 'كلمة المرور غير متطابقة'
                                : 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      BlocBuilder<SettingCubit, SettingState>(
                        builder: (context, state) {
                          return CustomButton(
                            text: AppLocalKay.save.tr(),
                            cubitState: state.changePasswordStatus,
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final empCode = HiveMethods.getEmpCode() ?? '0';
                                final request = ChangePasswordRequest(
                                  empId: int.tryParse(empCode) ?? 0,
                                  userPassword: passwordController.text.trim(),
                                );
                                context.read<SettingCubit>().changePassword(request);
                              }
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                      storedPassword == null || storedPassword.isEmpty || storedPassword == ''
                          ? Text(
                              context.locale.languageCode == 'ar'
                                  ? 'لا يمكنك استخدام التطبيق قبل تغيير كلمة المرور'
                                  : 'You cannot use the app until you change your password',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
