import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:my_template/features/attendance/data/models/attendance_record_model.dart';
import 'package:my_template/features/attendance/data/models/student_face_model.dart';

import 'core/services/notification_service.dart';
import 'core/services/services_locator.dart';
import 'features/notification/services/request_status_monitor.dart';

class ServiceInitialize {
  ServiceInitialize._();
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Hive is initialized and opened in main.dart with encryption
    try {
      Hive.registerAdapter(StudentFaceModelAdapter());
      Hive.registerAdapter(AttendanceRecordModelAdapter());
      Hive.registerAdapter(AttendanceStatusAdapter());
      Hive.registerAdapter(RecognitionMethodAdapter());
    } catch (e) {
      debugPrint(
        'Warning: Hive adapters failed to register (might be already registered or not generated): $e',
      );
    }

    await ScreenUtil.ensureScreenSize();
    await EasyLocalization.ensureInitialized();
    await NotificationService.initialize();
    await initDependencies();
    // Start monitoring request status
    final monitor = sl<RequestStatusMonitor>();
    await monitor.initialize();
  }
}
