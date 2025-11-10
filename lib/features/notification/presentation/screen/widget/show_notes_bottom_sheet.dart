import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';

Future<String?> showNotesBottomSheet(BuildContext context) {
  final controller = TextEditingController();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.locale.languageCode == 'ar' ? 'إضافة ملاحظات' : 'Add Notes',
              style: AppTextStyle.text18MSecond(context, color: AppColor.blackColor(context)),
            ),
            const SizedBox(height: 12),
            CustomFormField(
              controller: controller,
              radius: 20,
              hintText: context.locale.languageCode == 'ar'
                  ? 'اكتب ملاحظاتك هنا'
                  : 'Write your notes here',
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    child: Text(context.locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel'),
                    onPressed: () => Navigator.pop(context, null),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(context.locale.languageCode == 'ar' ? 'إرسال' : 'Send'),
                    onPressed: () => Navigator.pop(context, controller.text.trim()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
