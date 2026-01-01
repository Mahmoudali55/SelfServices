import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/services/notification_service.dart';
import 'core/services/services_locator.dart';
import 'features/notification/services/request_status_monitor.dart';

class ServiceInitialize {
  ServiceInitialize._();
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Hive is initialized and opened in main.dart with encryption

    await ScreenUtil.ensureScreenSize();
    await EasyLocalization.ensureInitialized();
    await NotificationService.initialize();
    await initDependencies();
    // Start monitoring request status
    final monitor = sl<RequestStatusMonitor>();
    await monitor.initialize();
  }
}
