import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_text_style.dart';

class CustomTittelAndSubTittelWidget extends StatelessWidget {
  const CustomTittelAndSubTittelWidget({
    super.key,

    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.text16MSecond(context)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyle.text14RGrey(context)),
            ],
          ),
        ),
      ],
    );
  }
}
