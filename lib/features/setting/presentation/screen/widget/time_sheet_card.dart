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

  DateTime? _parseDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null || dateStr.isEmpty || timeStr == null || timeStr.isEmpty) return null;

    try {
      final date = dateStr.trim();
      final time = timeStr.trim();

      if (time.toUpperCase().contains('AM') || time.toUpperCase().contains('PM')) {
        return DateFormat('dd/MM/yyyy hh:mm:ss a', 'en').parse('$date $time');
      } else {
        return DateFormat('dd/MM/yyyy HH:mm:ss', 'en').parse('$date $time');
      }
    } catch (e) {
      debugPrint('Error parsing datetime: $dateStr $timeStr | $e');
      return null;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Establish the "Base Date" for the shift (usually the sign-in date or currentDate)
    final baseDateStr = model.signInDate.isNotEmpty
        ? model.signInDate
        : DateFormat('yyyy-MM-dd').format(currentDate);

    // 2. Parse Project Schedule
    DateTime? projectStart = _parseDateTime(baseDateStr, model.projectSignInTime);
    DateTime? projectEnd = _parseDateTime(baseDateStr, model.projectSignOutTime);

    // Handle Night Shift: If Project End time is before Start time (e.g. 20:00 to 04:00), add 1 day to End
    if (projectStart != null && projectEnd != null) {
      if (projectEnd.isBefore(projectStart)) {
        projectEnd = projectEnd.add(const Duration(days: 1));
      }
    }

    // 3. Parse Actual Attendance
    DateTime? actualSignIn = _parseDateTime(model.signInDate, model.signInTime);

    // For signOut, check if model has a date.
    String? effectiveSignOutDate = model.signOutDate;
    if ((effectiveSignOutDate == null || effectiveSignOutDate.isEmpty) &&
        model.signOutTime != null) {
      // Heuristic: If we have time but no date, assume same day as signIn.
      // Only if time is drastically smaller than signInTime (e.g. 04:00 vs 20:00) we *might* assume next day,
      // but strictly speaking, missing date is ambiguous. We will assume baseDateStr.
      effectiveSignOutDate = baseDateStr;
    }

    DateTime? actualSignOut = _parseDateTime(effectiveSignOutDate, model.signOutTime);

    // Handle Night Shift for Actuals (if date was inferred):
    // If inferred actualSignOut is before actualSignIn, add 1 day
    if (actualSignIn != null &&
        actualSignOut != null &&
        (model.signOutDate == null || model.signOutDate!.isEmpty)) {
      if (actualSignOut.isBefore(actualSignIn)) {
        actualSignOut = actualSignOut.add(const Duration(days: 1));
      }
    }

    Duration delay = Duration.zero;
    Duration overtime = Duration.zero;
    Duration workDuration = Duration.zero;

    // --- Calculations ---

    // Delay: Actual Start > Project Start
    if (actualSignIn != null && projectStart != null) {
      if (actualSignIn.isAfter(projectStart)) {
        delay = actualSignIn.difference(projectStart);
      }
    }

    // Overtime
    // 1. Early Arrival (Before Project Start)
    if (actualSignIn != null && projectStart != null) {
      if (actualSignIn.isBefore(projectStart)) {
        overtime += projectStart.difference(actualSignIn);
      }
    }
    // 2. Late Departure (After Project End)
    if (actualSignOut != null && projectEnd != null) {
      if (actualSignOut.isAfter(projectEnd)) {
        overtime += actualSignOut.difference(projectEnd);
      }
    }

    // Actual Work Duration
    if (actualSignIn != null && actualSignOut != null) {
      workDuration = actualSignOut.difference(actualSignIn);
    }

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
              model.nameGpf,
              style: AppTextStyle.text16MSecond(context, color: AppColor.greenColor(context)),
            ),
            Gap(10.h),
            TimeSheetRow(
              title: AppLocalKay.checkin.tr(),
              value: model.signInTime,
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
              value: _formatDuration(delay),
              color: delay > Duration.zero ? Colors.red : AppColor.greenColor(context),
            ),
            TimeSheetRow(
              title: AppLocalKay.extra.tr(),
              value: _formatDuration(overtime),
              color: overtime > Duration.zero ? Colors.blue : AppColor.blackColor(context),
            ),
            TimeSheetRow(
              title: AppLocalKay.totalWork.tr(),
              value: actualSignOut != null ? _formatDuration(workDuration) : '-',
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}
