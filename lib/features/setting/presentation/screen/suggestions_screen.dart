import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
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
    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(AppLocalKay.suggestions.tr(), style: AppTextStyle.text18MSecond(context)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalKay.suggestion_required.tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),
              CustomButton(
                radius: 12,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showSuccessDialog(context);
                  }
                },
                text: AppLocalKay.send.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // نافذة رسالة الشكر
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(AppLocalKay.thank.tr(), style: AppTextStyle.text18MSecond(context)),
        content: Text(
          AppLocalKay.send_suggestion_success.tr(),
          style: AppTextStyle.text18MSecond(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalKay.good.tr(), style: AppTextStyle.text18MSecond(context)),
          ),
        ],
      ),
    );

    titleController.clear();
    suggestionController.clear();
  }
}
