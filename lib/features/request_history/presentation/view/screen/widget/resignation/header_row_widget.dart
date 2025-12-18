import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class HeaderRowWidget extends StatelessWidget {
  const HeaderRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.leave_bags_at_home_rounded, size: 16, color: AppColor.blackColor(context)),
            const SizedBox(width: 8),
            Text(
              AppLocalKay.resignation.tr(),
              style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
            ),
          ],
        ),
      ],
    );
  }
}
