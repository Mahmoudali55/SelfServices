import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/routes/app_routers_import.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/services/services_locator.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/data/repo/chat_repository.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:my_template/features/chat/presentation/screen/chat_screen.dart';
import 'package:my_template/features/chat/presentation/screen/group_chat_screen.dart';
import 'package:my_template/features/notification/presentation/screen/widget/notification_request_type_mapper.dart';
import 'package:my_template/features/request_history/data/repo/vacation_requests_repo.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static StreamSubscription? _chatSubscription;
  static StreamSubscription? _groupSubscription;
  static const String replyActionId = 'reply_chat_action';

  static Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    }

    // 2. Initialize Local Notifications for Foreground
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static void _handleNotificationResponse(NotificationResponse details) {
    log('Notification action: ${details.actionId}, payload: ${details.payload}');

    if (details.payload != null) {
      try {
        final data = jsonDecode(details.payload!);

        if (details.actionId == replyActionId &&
            details.input != null &&
            details.input!.isNotEmpty) {
          _handleInlineReply(data, details.input!);
          return;
        }

        final senderId = data['senderId'] as int?;
        final senderName = data['senderName'] as String?;
        final currentUserId = data['currentUserId'] as int?;

        if (senderId != null && senderName != null && currentUserId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final groupId = data['groupId'] as String?;
            final groupName = data['groupName'] as String?;

            if (groupId != null && groupName != null) {
              AppRouters.navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => GroupChatScreen(groupId: groupId, groupName: groupName),
                ),
              );
            } else {
              AppRouters.navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    currentUserId: currentUserId,
                    otherUserId: senderId,
                    otherUserName: senderName,
                  ),
                ),
              );
            }
          });
        } else if (data['type'] == 'request_update') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleRequestNotificationTap(data);
          });
        }
      } catch (e) {
        log('Error parsing notification payload: $e');
      }
    }
  }

  static Future<void> _handleInlineReply(Map<String, dynamic> data, String replyText) async {
    final senderId = data['senderId'] as int?;
    final currentUserId = data['currentUserId'] as int?;
    final senderName = data['senderName'] as String?;

    if (senderId == null || currentUserId == null) return;

    log('Handling inline reply: "$replyText" to user $senderId');

    final repo = sl<ChatRepository>();
    final conversationId = currentUserId < senderId
        ? '${currentUserId}_${senderId}'
        : '${senderId}_${currentUserId}';

    final message = ChatMessage(
      senderId: currentUserId,
      receiverId: senderId,
      message: replyText.trim(),
      timestamp: DateTime.now(),
      conversationId: conversationId,
      senderName: HiveMethods.getEmpNameAR(),
      type: MessageType.text,
    );

    try {
      await repo.sendMessage(message);
      log('Inline reply sent successfully');
      // Dismiss the notification
      await _localNotifications.cancelAll(); // Or use a specific ID if tracked
    } catch (e) {
      log('Error sending inline reply: $e');
    }

    // 3. Create Android Notification Channel
    const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
      'chat_messages',
      'رسائل الدردشة',
      description: 'تنبيهات الرسائل الجديدة',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel requestChannel = AndroidNotificationChannel(
      'request_updates',
      'تحديثات الطلبات',
      description: 'تنبيهات تغيير حالة الطلبات',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final dynamic androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(chatChannel);
      await androidPlugin.createNotificationChannel(requestChannel);
    }

    // 4. Listen for Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      if (message.notification != null) {
        showChatNotification(
          senderId: message.data['senderId'] as int,
          senderName: message.data['senderName'] as String,
          currentUserId: message.data['currentUserId'] as int,
          title: message.notification?.title ?? 'رسالة جديدة',
          body: message.notification?.body ?? '',
        );
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    log('Handling a background message: ${message.messageId}');
  }

  static Future<void> showChatNotification({
    required String title,
    required String body,
    required int senderId,
    required String senderName,
    required int currentUserId,
    String? groupId,
    String? groupName,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'رسائل الدردشة',
      channelDescription: 'تنبيهات الرسائل الجديدة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      actions: <AndroidNotificationAction>[],
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'chat_reply_category',
      ),
    );

    // Create payload with sender info and optional group info
    final payload = jsonEncode({
      'senderId': senderId,
      'senderName': senderName,
      'currentUserId': currentUserId,
      if (groupId != null) 'groupId': groupId,
      if (groupName != null) 'groupName': groupName,
    });

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  static Future<void> showRequestNotification({
    required String title,
    required String body,
    required int requestId,
    required int reqType,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'request_updates',
      'تحديثات الطلبات',
      channelDescription: 'تنبيهات تغيير حالة الطلبات',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    final payload = jsonEncode({
      'requestId': requestId,
      'reqType': reqType,
      'type': 'request_update',
    });

    await _localNotifications.show(
      requestId, // Use requestId as notification ID to update existing if needed
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  static Future<void> updateTokenInFirestore(int userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId.toString()).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        log('FCM Token updated for user $userId');
      }
    } catch (e) {
      log('Error updating FCM token: $e');
    }
  }

  /// Remove FCM token from Firestore on logout
  static Future<void> removeTokenFromFirestore(int userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId.toString()).update({
        'fcmToken': FieldValue.delete(),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      log('FCM Token removed for user $userId');
    } catch (e) {
      log('Error removing FCM token: $e');
    }
  }

  // Helper to get a user's token from Firestore
  static Future<String?> getUserToken(int userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId.toString()).get();
    return doc.data()?['fcmToken'] as String?;
  }

  // Send a push notification directly from the app
  static Future<void> sendPushNotification({
    required int receiverId,
    required String senderName,
    required String body,
    String? conversationId,
    int? senderId,
  }) async {
    try {
      final token = await getUserToken(receiverId);
      if (token == null) {
        log('Cannot send notification: No token found for user $receiverId');
        return;
      }

      // Note: In a production app, you should use a backend or Cloud Functions.
      // If you must send from the app, you need the FCM Server Key.
      // For now, we use a placeholder or the legacy API if the user provides the key.
      const String serverKey = 'YOUR_SERVER_KEY_HERE';

      if (serverKey == 'YOUR_SERVER_KEY_HERE') {
        log('FCM Server Key not set. Notification not sent.');
        return;
      }

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'key=$serverKey'},
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': senderName,
            'body': body,
            'sound': 'default',
            'android_channel_id': 'chat_messages',
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'senderId': senderId?.toString(),
            'conversationId': conversationId,
          },
        }),
      );

      if (response.statusCode == 200) {
        log('Push notification sent successfully to user $receiverId');
      } else {
        log('Failed to send push notification: ${response.body}');
      }
    } catch (e) {
      log('Error sending push notification: $e');
    }
  }

  static Future<void> startListeningForNotifications(int userId) async {
    // Stop any existing subscription
    await stopListening();

    log('Started listening for free notifications for user $userId');

    // Filter to only listen for messages created AFTER app start
    final DateTime appStartTime = DateTime.now();

    _chatSubscription = FirebaseFirestore.instance
        .collection('chats')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              if (data == null) continue;

              // Verify timestamp to avoid old notifications
              final timestamp = data['timestamp'];
              if (timestamp != null && timestamp is Timestamp) {
                final messageTime = timestamp.toDate();
                if (messageTime.isBefore(appStartTime)) {
                  continue;
                }
              }

              final senderName = data['senderName'] ?? 'رسالة جديدة';
              final messageText = data['message'] ?? 'أرسل لك ملفاً أو صورة';
              final senderId = data['senderId'];

              // Only notify if NOT currently chatting with this person
              if (ChatCubit.activeOtherUserId != senderId) {
                showChatNotification(
                  title: senderName,
                  body: messageText,
                  senderId: senderId,
                  senderName: senderName,
                  currentUserId: userId,
                );
                log('Free notification triggered for message: ${change.doc.id}');
              }
            }
          }
        });
  }

  static Future<void> stopListening() async {
    if (_chatSubscription != null) {
      await _chatSubscription!.cancel();
      _chatSubscription = null;
      log('Stopped chat notification listener');
    }
    if (_groupSubscription != null) {
      await _groupSubscription!.cancel();
      _groupSubscription = null;
      log('Stopped group notification listener');
    }
  }

  static Future<void> startListeningForGroupNotifications(int userId) async {
    // Stop any existing subscription
    if (_groupSubscription != null) {
      await _groupSubscription!.cancel();
      _groupSubscription = null;
    }

    log('Started listening for group notifications for user $userId');

    // Filter to only listen for messages created AFTER app start
    final DateTime appStartTime = DateTime.now();

    // Get all groups where user is a member
    _groupSubscription = FirebaseFirestore.instance
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .listen((groupSnapshot) {
          for (var groupDoc in groupSnapshot.docs) {
            final groupId = groupDoc.id;
            final groupName = groupDoc.data()['name'] ?? 'مجموعة';

            // Listen to messages in this group
            FirebaseFirestore.instance
                .collection('groups')
                .doc(groupId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .snapshots()
                .listen((messageSnapshot) {
                  for (var change in messageSnapshot.docChanges) {
                    if (change.type == DocumentChangeType.added) {
                      final data = change.doc.data();
                      if (data == null) continue;

                      // Verify timestamp to avoid old notifications
                      final timestamp = data['timestamp'];
                      if (timestamp != null && timestamp is Timestamp) {
                        final messageTime = timestamp.toDate();
                        if (messageTime.isBefore(appStartTime)) {
                          continue;
                        }
                      }

                      final senderId = data['senderId'];
                      final senderName = data['senderName'] ?? 'عضو';
                      final messageText = data['message'] ?? 'أرسل ملفاً أو صورة';

                      // Only notify if message is not from current user
                      if (senderId != userId) {
                        showChatNotification(
                          title: groupName,
                          body: '$senderName: $messageText',
                          senderId: senderId,
                          senderName: senderName,
                          currentUserId: userId,
                          groupId: groupId,
                          groupName: groupName,
                        );
                        log('Group notification triggered for group: $groupId');
                      }
                    }
                  }
                });
          }
        });
  }

  static Future<void> _handleRequestNotificationTap(Map<String, dynamic> data) async {
    final requestId = data['requestId'] as int;
    final reqType = data['reqType'] as int;
    final initialType = mapReqTypeToInitialType(reqType);
    final context = AppRouters.navigatorKey.currentState?.context;

    if (context == null) return;

    final repo = sl<VacationRequestsRepo>();
    final empCodeStr = HiveMethods.getEmpCode();
    if (empCodeStr == null) return;
    final empCode = int.parse(empCodeStr);

    BotToast.showLoading();

    try {
      // 1. Vacation Request (reqtype == 1)
      if (reqType == 1) {
        final result = await repo.vacationRequests(empcode: empCode, requestId: requestId);
        result.fold((failure) => _fallback(context, initialType), (requests) {
          BotToast.closeAllLoading();
          if (requests.isNotEmpty) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.requestHistoryDetilesScreen,
              arguments: requests.first,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 2. Back From Vacation (reqtype == 18)
      else if (reqType == 18) {
        final result = await repo.getRequestVacationBack(empCode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.vacRequestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.backFromVacationDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 3. Solfa (reqtype == 4)
      else if (reqType == 4) {
        final result = await repo.getSolfaRequests(empCode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(context, RoutesName.solfaDetailsScreen, arguments: target);
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 4. Housing Allowance (reqtype == 8)
      else if (reqType == 8) {
        final result = await repo.getAllHousingAllowance(empCode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.housingAllowanceDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 5. Cars (reqtype == 9)
      else if (reqType == 9) {
        final result = await repo.getAllCars(empcode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(context, RoutesName.carDetailsScreen, arguments: target);
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 6. Resignation (reqtype == 5)
      else if (reqType == 5) {
        final result = await repo.getAllResignation(empCode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.resignationDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 7. Transfer (reqtype == 19)
      else if (reqType == 19) {
        final result = await repo.getAllTransfer(empcode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.transferDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 8. Tickets (reqtype == 7)
      else if (reqType == 7) {
        final result = await repo.getAllTickets(empcode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(context, RoutesName.ticketDetailsScreen, arguments: target);
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 9. General Requests and others (reqtype: 2, 3, 15, 16, 17)
      else if ([2, 3, 15, 16, 17].contains(reqType)) {
        final result = await repo.getDynamicOrder(empcode: empCode, requesttypeid: reqType);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.generalRequestDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      } else {
        BotToast.closeAllLoading();
        _fallback(context, initialType);
      }
    } catch (e) {
      BotToast.closeAllLoading();
      _fallback(context, initialType);
    }
  }

  /* Duplicate removed

  static Future<void> _handleRequestNotificationTap(Map<String, dynamic> data) async {
    final requestId = data['requestId'] as int;
    final reqType = data['reqType'] as int;
    final initialType = mapReqTypeToInitialType(reqType);
    final context = AppRouters.navigatorKey.currentState?.context;

    if (context == null) return;

    final repo = sl<VacationRequestsRepo>();
    final empCodeStr = HiveMethods.getEmpCode();
    if (empCodeStr == null) return;
    final empCode = int.parse(empCodeStr);

    BotToast.showLoading();

    try {
      // 1. Vacation Request (reqtype == 1)
      if (reqType == 1) {
        final result = await repo.vacationRequests(empcode: empCode, requestId: requestId);
        result.fold((failure) => _fallback(context, initialType), (requests) {
          BotToast.closeAllLoading();
          if (requests.isNotEmpty) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.requestHistoryDetilesScreen,
              arguments: requests.first,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 2. Back From Vacation (reqtype == 18)
      else if (reqType == 18) {
        final result = await repo.getRequestVacationBack(empCode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.vacRequestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.backFromVacationDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 3. Solfa (reqtype == 4)
      else if (reqType == 4) {
        final result = await repo.getSolfaRequests(empCode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(context, RoutesName.solfaDetailsScreen, arguments: target);
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 4. Housing Allowance (reqtype == 8)
      else if (reqType == 8) {
        final result = await repo.getAllHousingAllowance(empCode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.housingAllowanceDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 5. Cars (reqtype == 9)
      else if (reqType == 9) {
        final result = await repo.getAllCars(empcode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(context, RoutesName.carDetailsScreen, arguments: target);
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 6. Resignation (reqtype == 5)
      else if (reqType == 5) {
        final result = await repo.getAllResignation(empCode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.resignationDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 7. Transfer (reqtype == 19)
      else if (reqType == 19) {
        final result = await repo.getAllTransfer(empcode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.transferDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 8. Tickets (reqtype == 7)
      else if (reqType == 7) {
        final result = await repo.getAllTickets(empcode: empCode);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(context, RoutesName.ticketDetailsScreen, arguments: target);
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 9. General Requests and others (reqtype: 2, 3, 15, 16, 17)
      else if ([2, 3, 15, 16, 17].contains(reqType)) {
        final result = await repo.getDynamicOrder(empcode: empCode, requesttypeid: reqType);
        result.fold((failure) => _fallback(context, initialType), (list) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.generalRequestDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      } else {
        BotToast.closeAllLoading();
        _fallback(context, initialType);
      }
    } catch (e) {
      BotToast.closeAllLoading();
      _fallback(context, initialType);
    }
  }

   */
  static void _fallback(BuildContext context, String initialType) {
    NavigatorMethods.pushNamedAndRemoveUntil(
      context,
      RoutesName.layoutScreen,
      arguments: {'restoreIndex': 1, 'initialType': initialType},
    );
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  log('Notification background action: ${details.actionId}, payload: ${details.payload}');
  // For now, we reuse the foreground handler logic if possible,
  // but background reply might need service re-initialization.
  if (details.actionId == NotificationService.replyActionId && details.input != null) {
    // We can't easily call the async handler without ensuring sl and Hive are ready.
    // In a real app, you might need a separate minimal init for background tasks.
  }
}
