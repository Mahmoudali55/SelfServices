import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';

class CustomTitelCardPendingWidget extends StatelessWidget {
  const CustomTitelCardPendingWidget({
    super.key,

    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColor.blackColor(context)),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyle.text14RGrey(
            context,
            color: AppColor.darkTextColor(context).withAlpha(140),
          ),
        ),
        const Spacer(),
        Text(
          context.locale.languageCode == 'en'
              ? description.split(' ').take(2).join(' ')
              : description.split(' ').take(3).join(' '),
          textAlign: TextAlign.center,
          style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
        ),
      ],
    );
  }
}
