import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class RequestTypeDropdown extends StatelessWidget {
  final List<String> requestTypes;
  final String selectedType;
  final ValueChanged<String> onChanged;

  const RequestTypeDropdown({
    super.key,
    required this.requestTypes,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String>(
        style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
        decoration: InputDecoration(
          labelText: AppLocalKay.chooseRequestType.tr(),
          labelStyle: AppTextStyle.text18MSecond(context, color: AppColor.primaryColor(context)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: selectedType,
        items: requestTypes
            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
            .toList(),
        onChanged: (value) => onChanged(value!),
      ),
    );
  }
}
