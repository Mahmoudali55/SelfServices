import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:my_template/core/routes/app_routers_import.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:my_template/features/chat/presentation/screen/chat_screen.dart';
import 'package:my_template/features/chat/presentation/screen/group_chat_screen.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static StreamSubscription? _chatSubscription;
  static StreamSubscription? _groupSubscription;

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
      onDidReceiveNotificationResponse: (details) {
        log('Notification tapped: ${details.payload}');
        if (details.payload != null) {
          try {
            final data = jsonDecode(details.payload!);
            final senderId = data['senderId'] as int?;
            final senderName = data['senderName'] as String?;
            final currentUserId = data['currentUserId'] as int?;

            if (senderId != null && senderName != null && currentUserId != null) {
              // Use addPostFrameCallback to ensure navigation happens after the current frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Check if it's a group notification
                final groupId = data['groupId'] as String?;
                final groupName = data['groupName'] as String?;

                if (groupId != null && groupName != null) {
                  // Navigate to GroupChatScreen
                  AppRouters.navigatorKey.currentState?.push(
                    MaterialPageRoute(
                      builder: (context) => GroupChatScreen(groupId: groupId, groupName: groupName),
                    ),
                  );
                } else {
                  // Navigate to ChatScreen
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
            }
          } catch (e) {
            log('Error parsing notification payload: $e');
          }
        }
      },
    );

    // 3. Create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'chat_messages',
      'رسائل الدردشة',
      description: 'تنبيهات الرسائل الجديدة',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final dynamic androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
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
      // To use a custom sound like WhatsApp, you'd place 'whatsapp_tone.mp3' in res/raw/
      // and use: sound: RawResourceAndroidNotificationSound('whatsapp_tone'),
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
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
}
