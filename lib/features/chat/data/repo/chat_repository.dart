import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore firestore;

  ChatRepository({required this.firestore});

  Future<void> sendMessage(ChatMessage message) async {
    final data = message.toMap();
    if (!data.containsKey('participants')) {
      data['participants'] = [message.senderId, message.receiverId];
    }
    await firestore.collection('chats').add(data);
  }

  Future<void> updateMessageModel(ChatMessage message) async {
    if (message.id == null) return;
    await firestore.collection('chats').doc(message.id).update(message.toMap());
  }

  Stream<List<ChatMessage>> getChatMessages(int currentUserId, int otherUserId) {
    final conversationId = currentUserId < otherUserId
        ? '${currentUserId}_$otherUserId'
        : '${otherUserId}_$currentUserId';

    return firestore
        .collection('chats')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data(), id: doc.id)).toList(),
        );
  }

  Stream<List<ChatMessage>> getLastMessagesForUser(int currentUserId) {
    return firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.data(), id: doc.id))
              .toList();
          final Map<int, ChatMessage> lastMessageMap = {};
          for (var msg in messages) {
            int otherId = msg.senderId == currentUserId ? msg.receiverId : msg.senderId;
            if (!lastMessageMap.containsKey(otherId)) lastMessageMap[otherId] = msg;
          }
          return lastMessageMap.values.toList();
        });
  }

  Future<void> markMessageAsRead(String messageId) async {
    if (messageId.isEmpty) return;
    await firestore.collection('chats').doc(messageId).update({'isRead': true});
  }

  Future<void> updateUserStatus(int userId, {required bool isOnline}) async {
    await firestore.collection('online_status').doc(userId.toString()).set({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> getUserStatus(int userId) {
    return firestore.collection('online_status').doc(userId.toString()).snapshots().map((snap) {
      if (!snap.exists) return {'isOnline': false, 'lastSeen': null};
      final data = snap.data()!;
      final lastSeen = data['lastSeen']?.toDate() ?? DateTime.now();

      final online = DateTime.now().difference(lastSeen).inSeconds < 60;

      return {'isOnline': online, 'lastSeen': lastSeen};
    });
  }

  Future<void> updateTypingStatus(int currentUserId, int otherUserId, bool isTyping) async {
    final conversationId = currentUserId < otherUserId
        ? '${currentUserId}_$otherUserId'
        : '${otherUserId}_$currentUserId';

    await firestore.collection('typing_status').doc(conversationId).set({
      currentUserId.toString(): {'isTyping': isTyping, 'lastUpdate': DateTime.now()},
    }, SetOptions(merge: true));
  }

  Stream<bool> getTypingStatus(int currentUserId, int otherUserId) {
    final conversationId = currentUserId < otherUserId
        ? '${currentUserId}_$otherUserId'
        : '${otherUserId}_$currentUserId';

    return firestore.collection('typing_status').doc(conversationId).snapshots().map((doc) {
      if (!doc.exists) return false;
      final data = doc.data()?[otherUserId.toString()];
      if (data == null) return false;
      final lastUpdate = (data['lastUpdate'] as Timestamp).toDate();
      final isTyping = data['isTyping'] as bool? ?? false;

      if (DateTime.now().difference(lastUpdate).inSeconds > 5) return false;
      return isTyping;
    });
  }

  Stream<List<ChatMessage>> listenToIncomingMessages(int currentUserId) {
    return firestore
        .collection('chats')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data(), id: doc.id)).toList(),
        );
  }
}
