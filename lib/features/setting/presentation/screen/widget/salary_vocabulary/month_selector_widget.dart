import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/theme/app_colors.dart';

class MonthSelectorWidget extends StatelessWidget {
  final DateTime currentDate;
  final DateTime currentMonth;
  final ScrollController monthScrollController;
  final List<DateTime> visibleMonths;
  final Function(DateTime) onMonthChanged;

  const MonthSelectorWidget({
    super.key,
    required this.currentDate,
    required this.currentMonth,
    required this.monthScrollController,
    required this.visibleMonths,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColor.whiteColor(context),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.blackColor(context),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(children: [_buildHeader(context), _buildMonthList(context)]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _arrowButton(context, Icons.arrow_back_ios, -1),
        Text(
          DateFormat('MMM - yyyy', context.locale.languageCode).format(currentDate),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        _arrowButton(context, Icons.arrow_forward_ios, 1),
      ],
    );
  }

  Widget _arrowButton(BuildContext context, IconData icon, int step) {
    return CircleAvatar(
      backgroundColor: AppColor.primaryColor(context),
      child: IconButton(
        icon: Icon(icon, color: AppColor.whiteColor(context)),
        onPressed: () {
          final newDate = DateTime(currentDate.year, currentDate.month + step, currentDate.day);
          onMonthChanged(newDate);
        },
      ),
    );
  }

  Widget _buildMonthList(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: ListView.builder(
        controller: monthScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        itemCount: visibleMonths.length,
        itemBuilder: (context, index) {
          final monthDate = visibleMonths[index];
          final monthText = DateFormat('MMM', context.locale.languageCode).format(monthDate);
          final yearText = DateFormat('yyyy', context.locale.languageCode).format(monthDate);
          final isSelected = monthDate.month == currentMonth.month;

          return GestureDetector(
            onTap: () => onMonthChanged(monthDate),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColor.primaryColor(context).withOpacity(0.8),
                          AppColor.primaryColor(context),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.grey[200],
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColor.whiteColor(context)
                            : AppColor.blackColor(context),
                      ),
                    ),
                    Text(
                      yearText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected ? Colors.white70 : AppColor.blackColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
