import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file, audio }

class ChatMessage {
  final String? id;
  final int senderId;
  final int receiverId;
  final String? message;
  final String? fileUrl;
  final String? fileName;
  final DateTime timestamp;
  final String conversationId;
  final bool isRead;
  final bool isEdited;
  final bool isDeleted;
  final MessageType type;
  final String? repliedTo;
  final String? repliedText;
  final int? repliedSenderId;
  final List<int> participants;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.fileUrl,
    this.fileName,
    required this.timestamp,
    required this.conversationId,
    this.isRead = false,
    this.isEdited = false,
    this.isDeleted = false,
    this.type = MessageType.text,
    this.repliedTo,
    this.repliedText,
    this.repliedSenderId,
    List<int>? participants,
  }) : participants = participants ?? [senderId, receiverId];

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'timestamp': Timestamp.fromDate(timestamp),
      'conversationId': conversationId,
      'isRead': isRead,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'type': type.index,
      'repliedTo': repliedTo,
      'repliedText': repliedText,
      'repliedSenderId': repliedSenderId,
      'participants': participants,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, {String? id}) {
    final timestamp = map['timestamp'];
    DateTime ts = DateTime.now();
    if (timestamp != null) {
      if (timestamp is Timestamp) {
        ts = timestamp.toDate();
      } else if (timestamp is Map) {
        // في حال تم تخزينه كـ map (أمان إضافي)
        ts = (timestamp['seconds'] != null)
            ? DateTime.fromMillisecondsSinceEpoch(timestamp['seconds'] * 1000)
            : DateTime.now();
      }
    }

    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? 0,
      receiverId: map['receiverId'] ?? 0,
      message: map['message'],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      timestamp: ts,
      conversationId: map['conversationId'] ?? '',
      isRead: map['isRead'] ?? false,
      isEdited: map['isEdited'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      type: MessageType.values[map['type'] ?? 0],
      repliedTo: map['repliedTo'],
      repliedText: map['repliedText'],
      repliedSenderId: map['repliedSenderId'],
      participants: List<int>.from(map['participants'] ?? []),
    );
  }

  ChatMessage copyWith({
    String? id,
    int? senderId,
    int? receiverId,
    String? message,
    String? fileUrl,
    String? fileName,
    DateTime? timestamp,
    String? conversationId,
    bool? isRead,
    bool? isEdited,
    bool? isDeleted,
    MessageType? type,
    String? repliedTo,
    String? repliedText,
    int? repliedSenderId,
    List<int>? participants,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      timestamp: timestamp ?? this.timestamp,
      conversationId: conversationId ?? this.conversationId,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      type: type ?? this.type,
      repliedTo: repliedTo ?? this.repliedTo,
      repliedText: repliedText ?? this.repliedText,
      repliedSenderId: repliedSenderId ?? this.repliedSenderId,
      participants: participants ?? this.participants,
    );
  }
}

/// موديل المستخدم مع حالة الاتصال
class ChatUser {
  final int id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    final lastSeenMap = map['lastSeen'];
    DateTime? lastSeenDt;
    if (lastSeenMap != null) {
      if (lastSeenMap is Timestamp) {
        lastSeenDt = lastSeenMap.toDate();
      } else if (lastSeenMap is Map && lastSeenMap['seconds'] != null) {
        lastSeenDt = DateTime.fromMillisecondsSinceEpoch(lastSeenMap['seconds'] * 1000);
      }
    }

    return ChatUser(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: lastSeenDt,
    );
  }
}
