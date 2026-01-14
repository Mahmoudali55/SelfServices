import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/presentation/screen/widget/audio_message_widget.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String? otherUserName;
  final String? senderName;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final Function(String)? onReplyTap;
  final String? Function(int)? getSenderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.otherUserName,
    this.senderName,
    this.isSelected = false,
    this.isHighlighted = false,
    this.onLongPress,
    this.onTap,
    this.onReplyTap,
    this.getSenderName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        color: isSelected
            ? Colors.blue.withOpacity(0.2)
            : (isHighlighted ? Colors.greenAccent.withOpacity(0.3) : Colors.transparent),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(left: isMe ? 50 : 12, right: isMe ? 12 : 50, top: 2, bottom: 2),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: message.isDeleted
                  ? Colors.grey[200]
                  : (isMe ? const Color(0xFFDCF8C6) : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isMe ? 12 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe && senderName != null && !message.isDeleted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      senderName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _getSenderColor(message.senderId),
                      ),
                    ),
                  ),
                if (message.repliedTo != null) _buildReplySection(context),
                _buildMessageContent(context),
                const SizedBox(height: 2),
                _buildStatusRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplySection(BuildContext context) {
    return GestureDetector(
      onTap: () => onReplyTap?.call(message.repliedTo!),
      child: Container(
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: isMe ? Colors.white70 : Colors.teal, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.repliedSenderId == (isMe ? message.senderId : message.receiverId)
                  ? AppLocalKay.you.tr()
                  : (getSenderName?.call(message.repliedSenderId!) ?? otherUserName ?? ''),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isMe ? Colors.white.withOpacity(0.9) : Colors.teal,
              ),
            ),
            Text(
              message.repliedText ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    if (message.isDeleted) {
      return Text(
        AppLocalKay.message_deletedes.tr(),
        style: AppTextStyle.text14RGrey(
          context,
        ).copyWith(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    switch (message.type) {
      case MessageType.text:
        return Text(
          message.message ?? '',
          style: AppTextStyle.text16MSecond(context).copyWith(color: Colors.black),
        );
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CustomNetworkImage(imageUrl: message.message ?? '', width: 250, fit: BoxFit.cover),
        );
      case MessageType.audio:
        return AudioMessageWidget(audioUrl: message.message ?? '', isReading: message.isRead);
      case MessageType.file:
        return _buildFileWidget(context);
    }
  }

  Widget _buildFileWidget(BuildContext context) {
    return InkWell(
      onTap: () async {
        final url = message.message ?? '';
        if (url.isEmpty) return;
        final fileName = message.fileName ?? url.split('/').last;
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');

        if (!await file.exists()) {
          final response = await HttpClient().getUrl(Uri.parse(url));
          final result = await response.close();
          final bytes = await consolidateHttpClientResponseBytes(result);
          await file.writeAsBytes(bytes);
        }
        await OpenFilex.open(file.path);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.teal),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.fileName ?? AppLocalKay.file.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (message.isEdited && !message.isDeleted)
          Text(
            AppLocalKay.edited.tr(),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black45,
              fontStyle: FontStyle.italic,
            ),
          ),
        Text(
          DateFormat('hh:mm a', context.locale.languageCode).format(message.timestamp),
          style: const TextStyle(fontSize: 10, color: Colors.black45),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          Icon(
            message.isRead ? Icons.done_all : Icons.check,
            size: 14,
            color: message.isRead ? Colors.blueAccent : Colors.black45,
          ),
        ],
      ],
    );
  }

  Color _getSenderColor(int userId) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
    ];
    return colors[userId % colors.length];
  }
}
