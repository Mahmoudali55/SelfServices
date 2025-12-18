import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/details_row_widget.dart';

class SectionWidget extends StatelessWidget {
  const SectionWidget({super.key, required this.title, required this.items, this.color});
  final String title;
  final Map<String, String> items;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.text18MSecond(context).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...items.entries.map(
              (e) => DetailsRowWidget(label: e.key, value: e.value, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
