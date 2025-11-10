import 'package:my_template/features/chat/data/model/chat_model.dart';

class ChatState {
  final List<ChatMessage> chatMessages;
  final List<ChatMessage> lastMessages;
  final bool otherUserIsOnline;
  final DateTime? otherUserLastSeen;

  ChatState({
    this.chatMessages = const [],
    this.lastMessages = const [],
    this.otherUserIsOnline = false,
    this.otherUserLastSeen,
  });

  ChatState copyWith({
    List<ChatMessage>? chatMessages,
    List<ChatMessage>? lastMessages,
    bool? otherUserIsOnline,
    DateTime? otherUserLastSeen,
  }) {
    return ChatState(
      chatMessages: chatMessages ?? this.chatMessages,
      lastMessages: lastMessages ?? this.lastMessages,
      otherUserIsOnline: otherUserIsOnline ?? this.otherUserIsOnline,
      otherUserLastSeen: otherUserLastSeen ?? this.otherUserLastSeen,
    );
  }
}
