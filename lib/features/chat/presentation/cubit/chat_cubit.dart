import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/data/repo/chat_repository.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  static int? activeOtherUserId;
  final int currentUserId;
  int? otherUserId;

  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<List<ChatMessage>>? _lastMessagesSubscription;
  StreamSubscription<Map<String, dynamic>>? _otherUserStatusSubscription;

  final Set<String> _selectedMessageIds = {};

  ChatCubit({required this.repository, required this.currentUserId}) : super(ChatState()) {
    repository.updateUserStatus(currentUserId, isOnline: true);
    startHeartbeat();
    listenToLastMessages();
    listenToAllIncomingMessages();
  }
  StreamSubscription<List<ChatMessage>>? _incomingMessagesSubscription;

  void listenToAllIncomingMessages() {
    _incomingMessagesSubscription?.cancel();

    _incomingMessagesSubscription = repository.listenToIncomingMessages(currentUserId).listen((
      newMessages,
    ) {
      if (isClosed) return;
      final updated = List<ChatMessage>.from(state.chatMessages);

      for (var msg in newMessages) {
        if (!updated.any((m) => m.id == msg.id)) {
          updated.add(msg);
        }
      }

      emit(state.copyWith(chatMessages: updated));
    });
  }

  void setOtherUserId(int id) async {
    if (id == currentUserId || otherUserId == id) return;

    otherUserId = id;
    _messagesSubscription?.cancel();
    _otherUserStatusSubscription?.cancel();

    final initialMessages = await repository.getChatMessages(currentUserId, otherUserId!).first;

    activeOtherUserId = otherUserId;
    emit(state.copyWith(chatMessages: initialMessages));

    // Mark messages as read after loading them
    markAllAsRead();

    _messagesSubscription = repository.getChatMessages(currentUserId, otherUserId!).skip(1).listen((
      messages,
    ) {
      emit(state.copyWith(chatMessages: messages));
    });

    _otherUserStatusSubscription = repository.getUserStatus(otherUserId!).listen((status) {
      emit(
        state.copyWith(
          otherUserIsOnline: status['isOnline'] ?? false,
          otherUserLastSeen: status['lastSeen'],
        ),
      );
    });
  }

  Future<void> sendMessage(
    String content, {
    MessageType type = MessageType.text,
    ChatMessage? repliedMessage,
    String? fileUrl,
    String? fileName,
  }) async {
    if (otherUserId == null || (content.trim().isEmpty && fileUrl == null)) return;

    final conversationId = currentUserId < otherUserId!
        ? '${currentUserId}_${otherUserId!}'
        : '${otherUserId!}_${currentUserId}';

    final message = ChatMessage(
      senderId: currentUserId,
      receiverId: otherUserId!,
      message: content.trim().isEmpty ? null : content.trim(),
      timestamp: DateTime.now(),
      conversationId: conversationId,
      type: type,
      repliedTo: repliedMessage?.id,
      repliedText: repliedMessage?.message,
      repliedSenderId: repliedMessage?.senderId,
      senderName: HiveMethods.getEmpNameAR(),
      fileUrl: fileUrl,
      fileName: fileName,
    );

    await repository.sendMessage(message);
  }

  Future<void> sendMessageToUser(
    int targetUserId,
    String content, {
    MessageType type = MessageType.text,
    ChatMessage? repliedMessage,
  }) async {
    if (content.trim().isEmpty) return;

    final conversationId = currentUserId < targetUserId
        ? '${currentUserId}_${targetUserId}'
        : '${targetUserId}_${currentUserId}';

    final message = ChatMessage(
      senderId: currentUserId,
      receiverId: targetUserId,
      message: content.trim(),
      timestamp: DateTime.now(),
      conversationId: conversationId,
      type: type,
      repliedTo: repliedMessage?.id,
      repliedText: repliedMessage?.message,
      repliedSenderId: repliedMessage?.senderId,
      senderName: HiveMethods.getEmpNameAR(),
      fileUrl: repliedMessage?.fileUrl,
      fileName: repliedMessage?.fileName,
    );

    await repository.sendMessage(message);

    if (otherUserId == targetUserId) {
      final updatedMessages = List<ChatMessage>.from(state.chatMessages)..add(message);
      emit(state.copyWith(chatMessages: updatedMessages));
    }
  }

  Future<void> deleteMessage(ChatMessage message) async {
    if (message.id == null) return;
    final deletedMessage = message.copyWith(
      message: AppLocalKay.message_deletedes.tr(),
      isDeleted: true,
    );
    await repository.updateMessageModel(deletedMessage);
  }

  Future<void> updateMessage(ChatMessage message, String newText) async {
    if (message.id == null) return;
    final editedMessage = message.copyWith(message: newText, isEdited: true);
    await repository.updateMessageModel(editedMessage);
  }

  void toggleMessageSelection(String messageId) {
    if (_selectedMessageIds.contains(messageId)) {
      _selectedMessageIds.remove(messageId);
    } else {
      _selectedMessageIds.add(messageId);
    }
    emit(state.copyWith());
  }

  bool isMessageSelected(String messageId) => _selectedMessageIds.contains(messageId);

  void clearSelection() {
    _selectedMessageIds.clear();
    emit(state.copyWith());
  }

  void listenToLastMessages() {
    _lastMessagesSubscription?.cancel();
    _lastMessagesSubscription = repository.getLastMessagesForUser(currentUserId).listen((messages) {
      emit(state.copyWith(lastMessages: messages));
    });
  }

  void markAllAsRead() async {
    if (otherUserId == null) return;

    // Find unread messages that were RECEIVED by current user (sent by other user)
    final unreadMessages = state.chatMessages
        .where(
          (msg) => !msg.isRead && msg.receiverId == currentUserId && msg.senderId == otherUserId,
        )
        .toList();

    for (var msg in unreadMessages) {
      await repository.markMessageAsRead(msg.id!);
    }

    final updatedMessages = state.chatMessages.map((msg) {
      if (unreadMessages.contains(msg)) return msg.copyWith(isRead: true);
      return msg;
    }).toList();

    emit(state.copyWith(chatMessages: updatedMessages));
  }

  Timer? _heartbeatTimer;

  void startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      repository.updateUserStatus(currentUserId, isOnline: true);
    });
  }

  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    repository.updateUserStatus(currentUserId, isOnline: false);
  }

  void setMyOnlineStatus(bool isOnline) {
    repository.updateUserStatus(currentUserId, isOnline: isOnline);
  }

  Stream<Map<String, dynamic>> getUserStatusStream(int userId) {
    return repository.getUserStatus(userId);
  }

  Timer? _typingTimer;

  void startTyping() {
    if (otherUserId == null) return;
    repository.updateTypingStatus(currentUserId, otherUserId!, true);

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      repository.updateTypingStatus(currentUserId, otherUserId!, false);
    });
  }

  void stopTyping() {
    if (otherUserId == null) return;
    _typingTimer?.cancel();
    repository.updateTypingStatus(currentUserId, otherUserId!, false);
  }

  Stream<bool> get otherUserIsTyping => repository.getTypingStatus(currentUserId, otherUserId!);

  @override
  Future<void> close() {
    activeOtherUserId = null;
    _messagesSubscription?.cancel();
    _lastMessagesSubscription?.cancel();
    _otherUserStatusSubscription?.cancel();
    _incomingMessagesSubscription?.cancel();

    stopHeartbeat();

    return super.close();
  }

  bool get isSelectionMode => _selectedMessageIds.isNotEmpty;
}
