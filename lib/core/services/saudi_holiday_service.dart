import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class SaudiHolidayService {
  static Map<String, String> getHoliday(DateTime date, {required Locale contextLocale}) {
    if (date.month == 2 && date.day == 22) {
      return {'name': AppLocalKay.founding_day.tr(), 'type': 'national'};
    }
    if (date.month == 9 && date.day == 23) {
      return {'name': AppLocalKay.national_day.tr(), 'type': 'national'};
    }
    if (date.month == 3 && date.day == 11) {
      return {'name': AppLocalKay.flag_day.tr(), 'type': 'national'};
    }

    HijriCalendar.setLocal(contextLocale.languageCode == 'ar' ? 'ar' : 'en');
    final hijriDate = HijriCalendar.fromDate(date);

    if (hijriDate.hMonth == 10 && hijriDate.hDay >= 1 && hijriDate.hDay <= 3) {
      return {'name': AppLocalKay.eid_al_fitr.tr(), 'type': 'religious'};
    }

    if (hijriDate.hMonth == 12 && hijriDate.hDay >= 10 && hijriDate.hDay <= 13) {
      return {'name': AppLocalKay.eid_al_adha.tr(), 'type': 'religious'};
    }

    return {};
  }

  static bool isHoliday(DateTime date, {required Locale contextLocale}) {
    return getHoliday(date, contextLocale: contextLocale).isNotEmpty;
  }
}
