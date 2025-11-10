import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/theme/app_colors.dart';

class TimeSheetDateSelector extends StatelessWidget {
  final DateTime currentDate;
  final List<DateTime> visibleDays;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;

  const TimeSheetDateSelector({
    super.key,
    required this.currentDate,
    required this.visibleDays,
    required this.onDaySelected,
    required this.onPrevDay,
    required this.onNextDay,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20.h,
      left: 20.w,
      right: 20.w,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            children: [_buildDateNavigation(context), Gap(10.h), _buildDateList(context)],
          ),
        ),
      ),
    );
  }

  Widget _buildDateNavigation(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _navButton(context, Icons.arrow_back_ios, onPrevDay),
        Text(
          DateFormat('EEEE, dd MMM yyyy', context.locale.languageCode).format(currentDate),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        _navButton(context, Icons.arrow_forward_ios, onNextDay),
      ],
    );
  }

  Widget _navButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      backgroundColor: AppColor.primaryColor(context),
      child: IconButton(
        icon: Icon(icon, color: AppColor.whiteColor(context)),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildDateList(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        itemCount: visibleDays.length,
        itemBuilder: (context, index) {
          final day = visibleDays[index];
          final isSelected = day == currentDate;
          final dayNumber = DateFormat('dd', context.locale.languageCode).format(day);
          final dayText = DateFormat('EEE', context.locale.languageCode).format(day);

          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: Container(
              width: 50.w,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColor.primaryColor(context).withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayNumber,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColor.primaryColor(context)
                            : AppColor.blackColor(context),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      dayText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected
                            ? AppColor.primaryColor(context)
                            : AppColor.blackColor(context),
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
