import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              const Spacer(),
              CustomButton(
                radius: 12,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                text: AppLocalKay.send.tr(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
