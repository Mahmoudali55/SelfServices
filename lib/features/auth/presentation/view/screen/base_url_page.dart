import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/network/contants.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/navigator_methods.dart';

class BaseUrlPage extends StatelessWidget {
  BaseUrlPage({super.key});

  final TextEditingController urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        centerTitle: false,
        automaticallyImplyLeading: true,
        leading: BackButton(color: AppColor.blackColor(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalKay.companysubdomain.tr(), style: AppTextStyle.text18MSecond(context)),
                const Gap(20),

                CustomFormField(
                  controller: urlController,
                  hintText: 'https://www.example.com',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.locale.languageCode == 'ar'
                          ? 'الرابط لا يمكن أن يكون فارغًا'
                          : 'URL can not be empty';
                    }
                    final pattern = r'^(http|https)://[^\s/$.?#].[^\s]*$';
                    final regExp = RegExp(pattern);
                    if (!regExp.hasMatch(value.trim())) {
                      return context.locale.languageCode == 'ar'
                          ? 'الرابط غير صحيح'
                          : 'Invalid URL';
                    }
                    return null;
                  },
                ),
                const Gap(30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await Constants.setBaseUrl(urlController.text.trim());
                        await Constants.loadBaseUrl();

                        CommonMethods.showToast(
                          message: context.locale.languageCode == 'ar'
                              ? 'تم حفظ الرابط وتحديثه بنجاح'
                              : 'Base URL updated successfully',
                          seconds: 3,
                          type: ToastType.success,
                        );

                        NavigatorMethods.pushNamedAndRemoveUntil(context, RoutesName.loginScreen);
                      }
                    },
                    child: Text(
                      AppLocalKay.save.tr(),
                      style: AppTextStyle.formTitleStyle(context, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
