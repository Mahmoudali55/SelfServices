import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/presentation/screen/widget/recording_widget.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final bool showEmojiPicker;
  final bool isUploading;
  final ChatMessage? repliedMessage;
  final String? repliedMessageSenderName;
  final VoidCallback onToggleEmoji;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onPickFile;
  final VoidCallback onStartRecording;
  final Function(dynamic) onRecordingComplete;
  final VoidCallback onCancelRecording;
  final VoidCallback onCancelReply;
  final String? otherUserName;
  final Function(String) onTyping;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.isRecording,
    required this.showEmojiPicker,
    this.isUploading = false,
    this.repliedMessage,
    this.repliedMessageSenderName,
    required this.onToggleEmoji,
    required this.onSend,
    required this.onPickImage,
    required this.onPickFile,
    required this.onStartRecording,
    required this.onRecordingComplete,
    required this.onCancelRecording,
    required this.onCancelReply,
    this.otherUserName,
    required this.onTyping,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (repliedMessage != null) _buildReplyPreview(context),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildAttachmentButtons(context),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: isRecording
                      ? RecordingWidget(onSend: onRecordingComplete, onCancel: onCancelRecording)
                      : _buildTextField(context),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(context),
            ],
          ),
        ),
        if (showEmojiPicker) _buildEmojiPicker(context),
      ],
    );
  }

  Widget _buildReplyPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 20, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  repliedMessageSenderName ??
                      (repliedMessage?.senderId == 0
                          ? (context.locale.languageCode == 'ar' ? 'أنت' : 'You')
                          : (otherUserName ?? '')),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  repliedMessage?.message ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, size: 20), onPressed: onCancelReply),
        ],
      ),
    );
  }

  Widget _buildAttachmentButtons(BuildContext context) {
    if (isRecording) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
          onPressed: onToggleEmoji,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
          onPressed: () => _showAttachmentModal(context),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      minLines: 1,
      onChanged: onTyping,
      decoration: InputDecoration(
        hintText: context.locale.languageCode == 'ar' ? 'اكتب رسالتك...' : 'Type a message...',
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isRecording) return const SizedBox.shrink();

    final isEmpty = controller.text.trim().isEmpty;

    return Container(
      decoration: const BoxDecoration(color: Color(0xFF075E54), shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(isEmpty ? Icons.mic : Icons.send, color: Colors.white),
        onPressed: isEmpty ? onStartRecording : onSend,
      ),
    );
  }

  void _showAttachmentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 120,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAttachmentType(
              context,
              Icons.image,
              Colors.purple,
              AppLocalKay.image.tr(),
              onPickImage,
            ),
            _buildAttachmentType(
              context,
              Icons.insert_drive_file,
              Colors.blue,
              AppLocalKay.file.tr(),
              onPickFile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentType(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 25,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker(BuildContext context) {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          onTyping(controller.text);
        },
        textEditingController: controller,
        config: Config(
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            backgroundColor: Colors.white,
            columns: 7,
            emojiSizeMax:
                32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
          ),
        ),
      ),
    );
  }
}
