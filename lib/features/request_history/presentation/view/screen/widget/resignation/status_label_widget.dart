import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_text_style.dart';

class StatusLabel extends StatelessWidget {
  final String status;
  final Color color;

  const StatusLabel({super.key, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        status,
        style: AppTextStyle.text14RGrey(
          context,
          color: color,
        ).copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
