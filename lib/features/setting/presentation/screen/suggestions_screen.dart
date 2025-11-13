import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/url_launcher_methods%20.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController suggestionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 20.h,
                        width: 20.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.whiteColor(context),
                          border: Border.all(color: AppColor.greyColor(context)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, color: AppColor.blackColor(context), size: 15),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppLocalKay.suggestions.tr(),
                      style: AppTextStyle.text16MSecond(
                        context,
                      ).copyWith(color: AppColor.primaryColor(context)),
                    ),
                    const Spacer(),
                  ],
                ),
                Gap(30.h),

                CustomFormField(
                  controller: titleController,
                  title: AppLocalKay.send_suggestion.tr(),
                  hintText: AppLocalKay.suggestion_placeholder.tr(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalKay.suggestion_required.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomFormField(
                  controller: suggestionController,
                  title: AppLocalKay.suggestion.tr(),
                  hintText: AppLocalKay.suggestion_placeholder2.tr(),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalKay.suggestion_required.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomButton(
                  radius: 12,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final title = titleController.text.trim();
                      final suggestion = suggestionController.text.trim();
                      final lang = context.locale.languageCode;

                      if (title.isEmpty || suggestion.isEmpty) {
                        CommonMethods.showToast(
                          message: lang == 'ar'
                              ? 'يرجى كتابة العنوان والمقترح قبل الإرسال ✏️'
                              : 'Please fill in both title and suggestion ✏️',
                          type: ToastType.error,
                        );
                        return;
                      }

                      final message = (lang == 'ar')
                          ? '⭐ * اقتراح جديد *:\nالعنوان: $title\nالمقترح: $suggestion'
                          : '⭐ *New Suggestion - SelfServices*:\nTitle: $title\nSuggestion: $suggestion';

                      const phoneNumber = '966503432569';

                      try {
                        await UrlLauncherMethods.launchWhatsApp(phoneNumber, message: message);
                        CommonMethods.showToast(
                          message: lang == 'ar'
                              ? 'تم إرسال الاقتراح بنجاح ✅'
                              : 'Suggestion sent successfully ✅',
                          type: ToastType.success,
                        );

                        titleController.clear();
                        suggestionController.clear();

                        Navigator.pop(context);
                      } catch (e) {
                        CommonMethods.showToast(
                          message: lang == 'ar'
                              ? 'حدث خطأ ما، يرجى المحاولة مرة اخرى'
                              : 'An error occurred, please try again later',
                          type: ToastType.error,
                        );
                      }
                    }
                  },
                  text: AppLocalKay.send.tr(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
