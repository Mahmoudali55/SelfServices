import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/presentation/screen/widget/message_bubble.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final int currentUserId;
  final String? otherUserName;
  final String? Function(int)? getSenderName;
  final ScrollController scrollController;
  final String? selectedMessageId;
  final String? highlightedMessageId;
  final Function(ChatMessage) onLongPress;
  final Function(String) onReplyTap;
  final bool isLoadingMore;

  const MessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
    this.otherUserName,
    this.getSenderName,
    required this.scrollController,
    this.selectedMessageId,
    this.highlightedMessageId,
    required this.onLongPress,
    required this.onReplyTap,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          context.locale.languageCode == 'ar' ? 'لا توجد رسائل بعد' : 'No messages yet',
          style: AppTextStyle.text16MSecond(context),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      reverse: true,
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      itemCount: messages.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (isLoadingMore && index == messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        final nextMessage = index < messages.length - 1 ? messages[index + 1] : null;

        // Date separator logic
        bool showDate = false;
        if (nextMessage == null) {
          showDate = true;
        } else {
          final currentDate = DateTime(
            message.timestamp.year,
            message.timestamp.month,
            message.timestamp.day,
          );
          final nextDate = DateTime(
            nextMessage.timestamp.year,
            nextMessage.timestamp.month,
            nextMessage.timestamp.day,
          );
          if (currentDate != nextDate) {
            showDate = true;
          }
        }

        return Column(
          children: [
            if (showDate) _buildDateSeparator(context, message.timestamp),
            MessageBubble(
              message: message,
              isMe: isMe,
              otherUserName: otherUserName,
              senderName: getSenderName?.call(message.senderId),
              getSenderName: getSenderName,
              isSelected: message.id == selectedMessageId,
              isHighlighted: message.id == highlightedMessageId,
              onLongPress: () => onLongPress(message),
              onReplyTap: onReplyTap,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(BuildContext context, DateTime timestamp) {
    String dateLabel;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (msgDate == today) {
      dateLabel = context.locale.languageCode == 'ar' ? 'اليوم' : 'Today';
    } else if (msgDate == yesterday) {
      dateLabel = context.locale.languageCode == 'ar' ? 'أمس' : 'Yesterday';
    } else {
      dateLabel = DateFormat('dd/MM/yyyy', 'en').format(timestamp);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD1D7DB),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            dateLabel,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
