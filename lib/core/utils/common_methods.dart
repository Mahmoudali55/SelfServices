import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

import '../services/services_locator.dart';

class CommonMethods {
  static Future<bool> hasConnection() async {
    var isConnected = await sl<InternetConnection>().hasInternetAccess;
    if (isConnected) {
      return true;
    } else {
      return false;
    }
  }

  static void showToast({
    required String message,
    String? title,
    String? icon,
    ToastType type = ToastType.success,
    Color? backgroundColor,
    Color? textColor,
    int seconds = 4,
  }) {
    BotToast.showCustomText(
      duration: Duration(seconds: seconds),
      toastBuilder: (cancelFunc) => CustomToast(
        type: type,
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        textColor: textColor,
      ),
    );
  }

  static void showPasswordVerificationDialog(
    BuildContext context, {
    required VoidCallback onSuccess,
  }) {
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalKay.enterYourPin.tr()),
        content: SizedBox(
          height: 150,
          child: Form(
            key: formKey,
            child: CustomFormField(
              controller: passwordController,
              title: AppLocalKay.password.tr(),
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalKay.enterValidPin.tr();
                }
                final savedPassword = HiveMethods.getEmpPassword();
                if (value != savedPassword) {
                  return AppLocalKay.loginError.tr();
                }
                return null;
              },
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalKay.cancel.tr())),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                onSuccess();
              }
            },
            child: Text(AppLocalKay.submit.tr()),
          ),
        ],
      ),
    );
  }
}
