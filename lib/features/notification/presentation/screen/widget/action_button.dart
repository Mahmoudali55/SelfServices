import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({super.key, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyle.text14RGrey(
              context,
              color: AppColor.whiteColor(context),
            ).copyWith(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
