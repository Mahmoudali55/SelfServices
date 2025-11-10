import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';

class CustomTitelCardWidget extends StatelessWidget {
  const CustomTitelCardWidget({
    super.key,
    required this.request,
    required this.title,
    required this.description,
    required this.icon,
  });

  final dynamic request;
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
        Expanded(
          child: Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
          ),
        ),
      ],
    );
  }
}
