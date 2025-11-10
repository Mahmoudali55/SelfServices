import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';

class AddDeviceBottomSheet extends StatelessWidget {
  final VoidCallback onSubmit;
  const AddDeviceBottomSheet({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.locale.languageCode == 'ar'
                  ? 'هذا الجهاز غير مسجل من قبل '
                  : 'This device is not registered before ',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),
            CustomButton(
              onPressed: onSubmit,
              text: context.locale.languageCode == 'ar' ? 'أضف جهاز جديد' : 'Add New Device',
            ),
          ],
        ),
      ),
    );
  }
}
