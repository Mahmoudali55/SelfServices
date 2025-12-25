import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BuildContext context;
  final String otherUserName;
  final Stream<Map<String, dynamic>>? userStatusStream;
  final Widget? subtitle;
  final bool otherUserIsTyping;
  final bool isSelectionMode;
  final VoidCallback onCloseSelection;
  final VoidCallback onDeleteMessages;
  final VoidCallback onBack;
  final List<Widget>? actions;
  final String? otherUserImage;

  const ChatAppBar({
    super.key,
    required this.context,
    required this.otherUserName,
    this.userStatusStream,
    this.subtitle,
    this.otherUserIsTyping = false,
    this.isSelectionMode = false,
    required this.onCloseSelection,
    required this.onDeleteMessages,
    required this.onBack,
    this.actions,
    this.otherUserImage,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: CustomAppBar(
        context,
        leading: IconButton(
          icon: Icon(isSelectionMode ? Icons.close : Icons.arrow_back_ios, color: Colors.black),
          onPressed: isSelectionMode ? onCloseSelection : onBack,
        ),
        title: isSelectionMode
            ? Text(
                context.locale.languageCode == 'ar' ? 'رسالة محددة' : 'Selected Message',
                style: AppTextStyle.text18MSecond(context),
              )
            : _buildTitleSection(),
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDeleteMessages,
                ),
              ]
            : actions ?? [],
      ),
    );
  }

  Widget _buildTitleSection() {
    Widget content;
    if (userStatusStream == null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(otherUserName, style: AppTextStyle.text18MSecond(context)),
          if (subtitle != null) subtitle!,
        ],
      );
    } else {
      content = StreamBuilder<Map<String, dynamic>>(
        stream: userStatusStream,
        builder: (context, snapshot) {
          final data = snapshot.data ?? {'isOnline': false, 'lastSeen': null};
          final isOnline = data['isOnline'] as bool? ?? false;
          final lastSeen = data['lastSeen'] as DateTime?;

          String statusText = '';
          if (otherUserIsTyping) {
            statusText = context.locale.languageCode == 'ar' ? 'يكتب الآن...' : 'Typing...';
          } else if (isOnline) {
            statusText = context.locale.languageCode == 'ar' ? 'متصل الآن' : 'Online';
          } else if (lastSeen != null) {
            final time = DateFormat('hh:mm a', 'en').format(lastSeen);
            statusText = context.locale.languageCode == 'ar' ? 'آخر ظهور $time' : 'Last seen $time';
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(otherUserName, style: AppTextStyle.text18MSecond(context)),
              if (statusText.isNotEmpty)
                Text(
                  statusText,
                  style: AppTextStyle.text14RGrey(context).copyWith(
                    color: isOnline || otherUserIsTyping ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              if (subtitle != null) subtitle!,
            ],
          );
        },
      );
    }

    return Row(
      children: [
        if (otherUserImage != null) ...[
          CircleAvatar(
            backgroundImage: NetworkImage(otherUserImage!),
            radius: 18,
            backgroundColor: Colors.grey[300],
            child: otherUserImage == null ? const Icon(Icons.person, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
        ] else ...[
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            child: Text(
              otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(child: content),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
