import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/setting/data/model/time_sheet_model.dart';
import 'package:my_template/features/setting/presentation/screen/widget/time_sheet_row.dart';

class TimeSheetCard extends StatelessWidget {
  final TimeSheetModel model;
  final DateTime currentDate;

  const TimeSheetCard({super.key, required this.model, required this.currentDate});

  /// دالة لتحويل الوقت بصيغة HH:mm:ss أو تركها إذا فارغة/غير صالحة
  DateTime _parseTime(DateTime date, String? time) {
    if (time == null || time.isEmpty) {
      return DateTime(date.year, date.month, date.day);
    }

    try {
      // تحقق من صيغة الوقت HH:mm:ss
      final parts = time.split(':').map(int.parse).toList();
      return DateTime(date.year, date.month, date.day, parts[0], parts[1], parts[2]);
    } catch (_) {
      // لو الوقت غير صالح
      return DateTime(date.year, date.month, date.day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectStart = _parseTime(currentDate, model.projectSignInTime);
    final projectEnd = _parseTime(currentDate, model.projectSignOutTime);
    final actualSignIn = _parseTime(currentDate, model.signInTime);
    final actualSignOut = model.signOutTime != null
        ? _parseTime(currentDate, model.signOutTime!)
        : projectEnd;

    final delay = actualSignIn.isAfter(projectStart)
        ? actualSignIn.difference(projectStart)
        : Duration.zero;

    Duration overtime = Duration.zero;
    if (actualSignIn.isBefore(projectStart)) {
      overtime += projectStart.difference(actualSignIn);
    }
    if (actualSignOut.isAfter(projectEnd)) {
      overtime += actualSignOut.difference(projectEnd);
    }

    final workDuration = actualSignOut.difference(actualSignIn);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalKay.project.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: AppColor.blackColor(context),
              ),
            ),
            Text(
              model.nameGpf ?? '-',
              style: AppTextStyle.text16MSecond(context, color: AppColor.greenColor(context)),
            ),
            Gap(10.h),
            TimeSheetRow(
              title: AppLocalKay.checkin.tr(),
              value: model.signInTime ?? '-',
              color: AppColor.greenColor(context),
            ),
            TimeSheetRow(
              title: AppLocalKay.checkout.tr(),
              value: model.signOutTime ?? '-',
              color: model.signOutTime == null ? Colors.grey : Colors.red,
            ),
            TimeSheetRow(
              title: AppLocalKay.ProjectCheckIn.tr(),
              value: model.projectSignInTime ?? '-',
              color: AppColor.greenColor(context),
            ),
            TimeSheetRow(
              title: AppLocalKay.ProjectCheckout.tr(),
              value: model.projectSignOutTime ?? '-',
              color: Colors.blueGrey,
            ),
            TimeSheetRow(
              title: AppLocalKay.delay.tr(),
              value: '${delay.inHours}h ${delay.inMinutes.remainder(60)}m',
              color: delay > Duration.zero ? Colors.red : AppColor.greenColor(context),
            ),
            TimeSheetRow(
              title: AppLocalKay.extra.tr(),
              value: '${overtime.inHours}h ${overtime.inMinutes.remainder(60)}m',
              color: overtime > Duration.zero ? Colors.blue : AppColor.blackColor(context),
            ),
            TimeSheetRow(
              title: AppLocalKay.totalWork.tr(),
              value: '${workDuration.inHours}h ${workDuration.inMinutes.remainder(60)}m',
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}
