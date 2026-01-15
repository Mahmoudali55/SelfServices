import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/sliding_text_widget.dart';

class AnimatedActionNote extends StatelessWidget {
  final String text;

  const AnimatedActionNote({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppColor.primaryColor(context), AppColor.primaryColor(context).withOpacity(.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor(context).withValues(alpha: .25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const Gap(8),
          Expanded(child: SlidingTextWidget(text: text)),
        ],
      ),
    );
  }
}
