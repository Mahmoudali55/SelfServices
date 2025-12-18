import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_text_style.dart';

class DetailsRowWidget extends StatelessWidget {
  const DetailsRowWidget({super.key, required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: AppTextStyle.text14RGrey(context).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: AppTextStyle.text14RGrey(context, color: color ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
