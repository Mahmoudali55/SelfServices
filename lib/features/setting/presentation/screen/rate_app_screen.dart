import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              Gap(10.h),
              CustomFormField(
                controller: feedbackController,
                maxLines: 2,
                title: AppLocalKay.notes.tr(),
                hintText: AppLocalKay.write_notes.tr(),
              ),
              const SizedBox(height: 20),
              CustomButton(
                radius: 12,
                onPressed: () {
                  Navigator.pop(context);
                },
                text: AppLocalKay.send_rating.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
