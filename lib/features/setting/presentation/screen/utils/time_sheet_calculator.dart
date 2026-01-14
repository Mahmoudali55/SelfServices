import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/features/setting/data/model/time_sheet_model.dart';
import 'package:intl/intl.dart';

class TimeSheetCalculator {
  final TimeSheetModel model;
  final DateTime currentDate;

  TimeSheetCalculator(this.model, this.currentDate);

  DateTime? get projectStart => _parseDateTime(baseDateStr, model.projectSignInTime);
  DateTime? get projectEnd =>
      _handleNightShift(projectStart, _parseDateTime(baseDateStr, model.projectSignOutTime));

  DateTime? get actualSignIn => _parseDateTime(model.signInDate, model.signInTime);
  DateTime? get actualSignOut => _handleActualNightShift(
    actualSignIn,
    _parseDateTime(_effectiveSignOutDate, model.signOutTime),
  );

  String get baseDateStr =>
      model.signInDate.isNotEmpty ? model.signInDate : DateFormat('yyyy-MM-dd').format(currentDate);
  String? get _effectiveSignOutDate {
    if (model.signOutDate != null && model.signOutDate!.isNotEmpty) return model.signOutDate;
    if (model.signOutTime != null && model.signOutTime!.isNotEmpty) return baseDateStr;
    return null;
  }

  DateTime? _handleNightShift(DateTime? start, DateTime? end) {
    if (start != null && end != null && end.isBefore(start)) {
      return end.add(const Duration(days: 1));
    }
    return end;
  }

  DateTime? _handleActualNightShift(DateTime? start, DateTime? end) {
    // If model explicitly has date, trust it. If we inferred date (baseDateStr) and time is next day, adjust.
    if (start != null && end != null && (model.signOutDate == null || model.signOutDate!.isEmpty)) {
      if (end.isBefore(start)) {
        return end.add(const Duration(days: 1));
      }
    }
    return end;
  }

  Duration get delay {
    if (actualSignIn != null && projectStart != null) {
      if (actualSignIn!.isAfter(projectStart!)) {
        return actualSignIn!.difference(projectStart!);
      }
    }
    return Duration.zero;
  }

  Duration get overtime {
    Duration total = Duration.zero;
    if (actualSignIn != null && projectStart != null && actualSignIn!.isBefore(projectStart!)) {
      total += projectStart!.difference(actualSignIn!);
    }
    if (actualSignOut != null && projectEnd != null && actualSignOut!.isAfter(projectEnd!)) {
      total += actualSignOut!.difference(projectEnd!);
    }
    return total;
  }

  Duration get workDuration {
    if (actualSignIn != null && actualSignOut != null) {
      return actualSignOut!.difference(actualSignIn!);
    }
    return Duration.zero;
  }

  DateTime? _parseDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null || dateStr.isEmpty || timeStr == null || timeStr.isEmpty) return null;
    try {
      final d = dateStr.trim();
      final t = timeStr.trim();

      // Use English locale as per recent fix
      if (t.toUpperCase().contains('AM') || t.toUpperCase().contains('PM')) {
        return DateFormat('dd/MM/yyyy hh:mm:ss a', 'en').parse('$d $t');
      } else {
        return DateFormat('dd/MM/yyyy HH:mm:ss', 'en').parse('$d $t');
      }
    } catch (e) {
      debugPrint('Error parsing datetime: $dateStr $timeStr | $e');
      return null;
    }
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes';
  }
}
