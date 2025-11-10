import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/features/setting/presentation/screen/widget/row_title_and_value_time_sheet.dart';

class TimeSheetRow extends StatelessWidget {
  const TimeSheetRow({super.key, required this.title, required this.value, required this.color});
  final String title;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RowTitleAndValueTimeSheet(title: title, value: value, valueColor: color),
    );
  }
}
