import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/url_launcher_methods%20.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  double rating = 0.0;
  final TextEditingController feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // يسمح بتحريك الشاشة عند ظهور الكيبورد
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    children: [Icon(Icons.close, color: AppColor.blackColor(context), size: 15)],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  AppLocalKay.how_was_your_experience.tr(),
                  style: AppTextStyle.text16MSecond(context),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isActive = index < rating;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = index + 1.0;
                      });
                    },
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 1.0, end: isActive ? 1.3 : 1.0),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Icon(
                            Icons.star,
                            size: 40,
                            color: isActive ? Colors.amber : Colors.grey,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              CustomFormField(
                controller: feedbackController,
                maxLines: 2,
                title: AppLocalKay.notes.tr(),
                hintText: AppLocalKay.write_notes.tr(),
              ),
              const SizedBox(height: 20),
              CustomButton(
                radius: 12,
                text: AppLocalKay.send_rating.tr(),
                onPressed: () async {
                  final feedback = feedbackController.text.trim();
                  final lang = context.locale.languageCode;

                  if (rating == 0.0) {
                    CommonMethods.showToast(
                      message: lang == 'ar'
                          ? 'من فضلك اختر تقييمًا قبل الإرسال ⭐'
                          : 'Please select a rating before sending ⭐',
                      type: ToastType.success,
                    );
                    return; // وقف التنفيذ
                  }

                  final message = (lang == 'ar')
                      ? '⭐ * تقييم التطبيق*:\nالتقييم: $rating من 5\nالملاحظات: ${feedback.isEmpty ? "لا توجد ملاحظات" : feedback}'
                      : '⭐ *App Rating *:\nRating: $rating out of 5\nFeedback: ${feedback.isEmpty ? "No feedback" : feedback}';

                  const phoneNumber = '+966503432569';

                  try {
                    await UrlLauncherMethods.launchWhatsApp(phoneNumber, message: message);
                  } catch (e) {
                    CommonMethods.showToast(message: e.toString(), type: ToastType.error);
                  }
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
