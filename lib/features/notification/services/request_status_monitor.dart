import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/services/notification_service.dart';
import 'package:my_template/features/notification/data/model/employee_requests_notify_model.dart';
import 'package:my_template/features/notification/data/repo/notifiction_repo.dart';

class RequestStatusMonitor {
  final NotifictionRepo _repo;
  Timer? _timer;
  static const Duration _checkInterval = Duration(seconds: 10);
  final Box _box = Hive.box('app');
  static const String _lastRequestsKey = 'last_known_requests_state';

  RequestStatusMonitor(this._repo);

  Future<void> initialize() async {
    log('RequestStatusMonitor initialized');
    await _checkStatus(); // Initial check
    _timer?.cancel();
    _timer = Timer.periodic(_checkInterval, (_) => _checkStatus());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    log('RequestStatusMonitor stopped');
  }

  bool _isChecking = false;

  Future<void> _checkStatus() async {
    if (_isChecking) {
      log('RequestStatusMonitor: Skipping check, previous check still in progress.');
      return;
    }
    _isChecking = true;

    try {
      final empIdStr = HiveMethods.getEmpCode();
      if (empIdStr == null) return;

      final empId = int.tryParse(empIdStr);
      if (empId == null) return;

      log('Checking request status for empId: $empId'); // Added log

      final result = await _repo.employeeRequestsNotify(empId);

      result.fold((failure) => log('Failed to check request status: ${failure.errMessage}'), (
        response,
      ) {
        log('Fetched ${response.data.length} requests'); // Added log
        _compareAndNotify(response.data);
      });
    } finally {
      _isChecking = false;
    }
  }

  void _compareAndNotify(List<RequestItem> currentRequests) {
    final lastRequestsJson = _box.get(_lastRequestsKey);
    List<RequestItem> lastRequests = [];

    if (lastRequestsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(lastRequestsJson);
        lastRequests = decoded.map((e) => RequestItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        log('RequestStatusMonitor: Error decoding last requests state: $e');
      }
    } else {
      log('RequestStatusMonitor: No previous requests state found (first run or cleared).');
    }

    // Use composite key (ID_Type) to ensure uniqueness
    final lastRequestsMap = {
      for (var item in lastRequests) '${item.vacRequestId}_${item.reqtype}': item,
    };

    for (var current in currentRequests) {
      final key = '${current.vacRequestId}_${current.reqtype}';
      final last = lastRequestsMap[key];

      if (last != null) {
        // Compare status
        if (current.reqDecideState != last.reqDecideState ||
            current.reqDicidState != last.reqDicidState) {
          log(
            'RequestStatusMonitor: Status change detected for $key! '
            'Old: ${last.reqDecideState}/${last.reqDicidState}, '
            'New: ${current.reqDecideState}/${current.reqDicidState}',
          );

          _triggerNotification(current);
        } else {
          // log('RequestStatusMonitor: No change for $key'); // Optional verbose log
        }
      } else {
        // New request or unseen before
        // FOR TESTING: Notify on new items too so the user sees it works immediately after update
        log('RequestStatusMonitor: New request found: $key. Triggering test notification.');
        _triggerNotification(current);
      }
    }

    // Update local state
    final String encoded = jsonEncode(currentRequests.map((e) => e.toJson()).toList());
    _box.put(_lastRequestsKey, encoded);
    // log('RequestStatusMonitor: Saved new state with ${currentRequests.length} items.');
  }

  void _triggerNotification(RequestItem request) {
    final requestName = _getRequestName(request.reqtype);

    NotificationService.showRequestNotification(
      title: 'تحديث حالة الطلب: $requestName',
      body: '${request.requestDesc}',
      requestId: request.vacRequestId,
      reqType: request.reqtype,
    );
  }

  String _getRequestName(int reqType) {
    switch (reqType) {
      case 1:
        return 'إجازة';
      case 18:
        return 'عودة من إجازة';
      case 4:
        return 'سلفة';
      case 8:
        return 'بدل سكن';
      case 9:
        return 'سيارة';
      case 5:
        return 'استقالة';
      case 19:
        return 'نقل';
      case 7:
        return 'تذاكر سفر';
      case 2:
        return 'خطاب تعريف';
      case 3:
        return 'دورة تدريبية';
      case 15:
        return 'طلب توظيف';
      case 16:
        return 'تقييم موظف';
      case 17:
        return 'إنذار';
      case 6:
        return 'جواز سفر';
      default:
        return 'طلب عام';
    }
  }
}
