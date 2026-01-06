import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

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
              AppLocalKay.device_not_registered.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),
            CustomButton(onPressed: onSubmit, text: AppLocalKay.add_new_device.tr()),
          ],
        ),
      ),
    );
  }
}
