import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/services/saudi_holiday_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/app_local_kay.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColor.whiteColor(context) : AppColor.blackColor(context);

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        title: Text(AppLocalKay.calendar.tr(), style: AppTextStyle.text18MSecond(context)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendarCard(textColor),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildDayDetails(textColor),
            ),
            Gap(20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(Color textColor) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackColor(context).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TableCalendar(
        locale: context.locale.languageCode,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2050, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        eventLoader: (day) {
          return SaudiHolidayService.isHoliday(day, contextLocale: context.locale)
              ? ['Holiday']
              : [];
        },
        daysOfWeekHeight: 30.h,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: textColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
          weekendStyle: TextStyle(color: textColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final isHoliday = SaudiHolidayService.isHoliday(day, contextLocale: context.locale);

            return Center(
              child: Text(
                '${day.day}',
                style: AppTextStyle.text16MSecond(
                  context,
                  color: isHoliday ? Colors.red : Colors.black,
                ),
              ),
            );
          },

          dowBuilder: (context, day) {
            final text = DateFormat.E(context.locale.languageCode).format(day);

            return Center(
              child: Text(
                text,
                style: AppTextStyle.text14RGrey(
                  context,
                  color: textColor,
                ).copyWith(fontSize: 10.sp),
              ),
            );
          },

          selectedBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(6.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.primaryColor(context),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: AppTextStyle.text16MSecond(context, color: AppColor.whiteColor(context)),
              ),
            );
          },

          todayBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(6.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.primaryColor(context).withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: AppTextStyle.text16MSecond(context, color: AppColor.primaryColor(context)),
              ),
            );
          },
        ),
        calendarStyle: CalendarStyle(outsideDaysVisible: false, markersMaxCount: 0),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyle.text16MSecond(context),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppColor.primaryColor(context)),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppColor.primaryColor(context)),
        ),
      ),
    );
  }

  Widget _buildDayDetails(Color textColor) {
    final date = _selectedDay ?? DateTime.now();
    final hijriLang = context.locale.languageCode == 'en' ? 'en' : 'ar';
    HijriCalendar.setLocal(hijriLang);
    final hijriDate = HijriCalendar.fromDate(date);
    final holiday = SaudiHolidayService.getHoliday(date, contextLocale: context.locale);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.greyColor(context).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, d MMMM yyyy ', context.locale.languageCode).format(date),
                style: AppTextStyle.text14MPrimary(context, color: textColor),
              ),
              Icon(Icons.calendar_month, color: AppColor.primaryColor(context)),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Text(
                '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear} هـ',
                style: AppTextStyle.text16MSecond(
                  context,
                ).copyWith(color: AppColor.primaryColor(context)),
              ),
              const Spacer(),
              Text(AppLocalKay.hijri_calendar.tr(), style: AppTextStyle.text14RGrey(context)),
            ],
          ),
          if (holiday.isNotEmpty) ...[
            Gap(16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: holiday['type'] == 'national'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: holiday['type'] == 'national' ? Colors.green : Colors.orange,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    holiday['type'] == 'national' ? Icons.flag : Icons.celebration,
                    color: holiday['type'] == 'national' ? Colors.green : Colors.orange,
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holiday['name']!,
                          style: AppTextStyle.text16MSecond(context).copyWith(
                            color: holiday['type'] == 'national' ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppLocalKay.saudi_holidays.tr(),
                          style: AppTextStyle.text14RGrey(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
