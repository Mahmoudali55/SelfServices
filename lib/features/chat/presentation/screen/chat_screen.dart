import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:my_template/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_state.dart';
import 'package:my_template/features/chat/presentation/screen/widget/audio_message_widget.dart';
import 'package:my_template/features/chat/presentation/screen/widget/cloudinary_service.dart';
import 'package:my_template/features/chat/presentation/screen/widget/recording_widget.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  final int currentUserId;
  final int otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  String? editingMessageId;
  String? selectedMessageId;
  ChatMessage? repliedMessage;
  String? highlightedMessageId;
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String? _recordedFilePath;
  late CloudinaryService _cloudinaryService;
  Timer? _typingTimer;
  bool otherUserIsTyping = false;
  bool _showRecordingWidget = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer; 
  final Set<String> selectedMessageIds = {};
  
  bool _showEmojiPicker = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final cubit = context.read<ChatCubit>();
    cubit.setOtherUserId(widget.otherUserId);
    cubit.markAllAsRead();
    _audioRecorder = FlutterSoundRecorder();
    _initRecorder();

    _cloudinaryService = CloudinaryService();

    cubit.setMyOnlineStatus(true);

    _listenToOtherUserTyping();
    _controller.addListener(() {
      setState(() {}); 
    });
  }

  Future<void> _initRecorder() async {
    await _audioRecorder!.openRecorder();
    await Permission.microphone.request();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<ChatCubit>();
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      cubit.setMyOnlineStatus(false);
    } else if (state == AppLifecycleState.resumed) {
      cubit.setMyOnlineStatus(true);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void dispose() {
    _audioRecorder!.closeRecorder();
    _audioRecorder = null;
    super.dispose();
  }

  void _startTyping() {
    final cubit = context.read<ChatCubit>();
    cubit.startTyping(); 
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      cubit.stopTyping();
    });
  }

  void _listenToOtherUserTyping() {
    final cubit = context.read<ChatCubit>();
    cubit.otherUserIsTyping.listen((isTyping) {
      if (mounted) {
        setState(() {
          otherUserIsTyping = isTyping;
        });
      }
    });
  }

  void _sendMessage(ChatCubit cubit) {
    final text = _controller.text.trim();
    if (text.isEmpty && repliedMessage == null) return;

    if (editingMessageId != null) {
      final msg = cubit.state.chatMessages.firstWhere((m) => m.id == editingMessageId);
      cubit.updateMessage(msg, text);
      editingMessageId = null;
    } else {
      cubit.sendMessage(text, type: MessageType.text, repliedMessage: repliedMessage);
    }

    _controller.clear();
    setState(() {
      selectedMessageId = null;
      repliedMessage = null;
    });
    _scrollToBottom();
  }

  bool isUploading = false; 

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    await _audioRecorder!.startRecorder(toFile: path, codec: Codec.aacADTS);

   
    _recordingSeconds = 0;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordingSeconds++);
    });

    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording(ChatCubit cubit) async {
    final path = await _audioRecorder!.stopRecorder();
    _recordingTimer?.cancel();
    _recordingSeconds = 0;

    setState(() => _isRecording = false);
    _recordedFilePath = path;

    if (_recordedFilePath != null) {
      final file = File(_recordedFilePath!);
      await _uploadAndSendFile(file, MessageType.audio, cubit);
    }
  }

  Future<void> _sendImage(ChatCubit cubit) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    await _uploadAndSendFile(file, MessageType.image, cubit);
  }

  Future<void> _sendFile(ChatCubit cubit) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.first.path!);
    await _uploadAndSendFile(file, MessageType.file, cubit);
  }

  Future<void> _uploadAndSendFile(File file, MessageType type, ChatCubit cubit) async {
    setState(() => isUploading = true);
    try {
      String? url;
      if (type == MessageType.image) {
        url = await _cloudinaryService.uploadImage(file);
      } else if (type == MessageType.audio) {
        url = await _cloudinaryService.uploadAudio(file);
      } else {
        url = await _cloudinaryService.uploadFile(file);
      }

      if (url != null) {
        cubit.sendMessage(
          url,
          type: type,
          fileName: file.path.split('/').last,
          repliedMessage: repliedMessage,
        );
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload file: $e')));
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  void _forwardMessage(ChatMessage msg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectUserScreen(message: msg, currentUserId: widget.currentUserId),
      ),
    );
  }

  void _scrollToMessageById(String messageId, List<ChatMessage> messages) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final offset = index * 120.0; // تقريبًا ارتفاع كل عنصر
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // نحدد الرسالة الأصلية مؤقتًا للتمييز
      setState(() {
        highlightedMessageId = messageId;
      });

      // إزالة التحديد بعد 2 ثانية
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            highlightedMessageId = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          context,
          title: StreamBuilder<Map<String, dynamic>>(
            stream: cubit.getUserStatusStream(widget.otherUserId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final data = snapshot.data!;
              final isOnline = data['isOnline'] as bool? ?? false;
              final lastSeen = data['lastSeen'] as DateTime?;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUserName, style: AppTextStyle.text18MSecond(context)),
                  Text(
                    otherUserIsTyping
                        ? context.locale.languageCode == 'ar'
                              ? 'يكتب الآن...'
                              : 'Typing...'
                        : (isOnline
                              ? context.locale.languageCode == 'ar'
                                    ? 'متصل الآن'
                                    : 'Online'
                              : lastSeen != null
                              ? '${context.locale.languageCode == 'ar' ? 'آخر ظهور' : 'Last seen'}: ${DateFormat(' yyyy/MM/dd ', 'en').format(lastSeen)} ${DateFormat('hh:mm a', 'en').format(lastSeen)}'
                              : ''),
                    style: AppTextStyle.text14RGrey(context, color: AppColor.blackColor(context)),
                  ),
                ],
              );
            },
          ),

          leading: IconButton(
            icon: Icon(
              selectedMessageId == null ? Icons.arrow_back_ios : Icons.close_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              if (selectedMessageId != null) {
                setState(() => selectedMessageId = null);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: selectedMessageIds.isNotEmpty
              ? [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      for (var id in selectedMessageIds) {
                        final msg = cubit.state.chatMessages.firstWhere((m) => m.id == id);
                        cubit.deleteMessage(msg);
                      }
                      setState(() => selectedMessageIds.clear());
                    },
                  ),
                ]
              : selectedMessageId == null
              ? []
              : [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onSelected: (value) {
                      final msg = cubit.state.chatMessages.firstWhere(
                        (m) => m.id == selectedMessageId,
                      );
                      if (value == 'edit' && !msg.isDeleted) {
                        _controller.text = msg.message ?? '';
                        editingMessageId = msg.id;
                      }
                      if (value == 'delete') {
                        if (msg.senderId == widget.currentUserId) {
                          cubit.deleteMessage(msg);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.locale.languageCode == 'ar'
                                    ? 'لا يمكنك حذف رسالة المرسل'
                                    : 'You cannot delete sender\'s message',
                              ),
                            ),
                          );
                        }
                      } else if (value == 'forward') {
                        _forwardMessage(msg);
                      } else if (value == 'reply') {
                        setState(() => repliedMessage = msg);
                      }
                      setState(() => selectedMessageId = null);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'reply', child: Text(AppLocalKay.reply.tr())),
                      PopupMenuItem(value: 'edit', child: Text(AppLocalKay.editmessage.tr())),
                      PopupMenuItem(value: 'delete', child: Text(AppLocalKay.deletemessage.tr())),
                      PopupMenuItem(value: 'forward', child: Text(AppLocalKay.forward.tr())),
                    ],
                  ),
                ],
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (selectedMessageId != null) setState(() => selectedMessageId = null);
            },
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: BlocBuilder<ChatCubit, ChatState>(
                      builder: (_, messages) {
                        _scrollToBottom();
                        DateTime? previousDate;

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.chatMessages.length,
                          itemBuilder: (_, index) {
                            final msg = messages.chatMessages[index];
                            final isMe = msg.senderId == widget.currentUserId;
                            final msgDate = msg.timestamp;
                            final isSelected = msg.id == selectedMessageId;

                            String dateLabel;
                            final now = DateTime.now();
                            if (msgDate.year == now.year &&
                                msgDate.month == now.month &&
                                msgDate.day == now.day) {
                              dateLabel = context.locale.languageCode == 'ar' ? 'اليوم' : 'Today';
                            } else if (msgDate.year == now.year &&
                                msgDate.month == now.month &&
                                msgDate.day == now.day - 1) {
                              dateLabel = context.locale.languageCode == 'ar' ? 'امس' : 'Yesterday';
                            } else {
                              dateLabel = DateFormat('dd/MM/yyyy').format(msgDate);
                            }

                            bool showDate =
                                previousDate == null ||
                                previousDate!.year != msgDate.year ||
                                previousDate!.month != msgDate.month ||
                                previousDate!.day != msgDate.day;
                            previousDate = msgDate;

                            return Column(
                              children: [
                                if (showDate)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          dateLabel,
                                          style: AppTextStyle.text16MSecond(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                GestureDetector(
                                  onLongPress: () => setState(() => selectedMessageId = msg.id),
                                  child: Container(
                                    key: ValueKey(msg.id),
                                    color: isSelected
                                        ? Colors.blue.withOpacity(0.2)
                                        : (msg.id == highlightedMessageId
                                              ? Colors.greenAccent.withOpacity(0.3)
                                              : Colors.transparent),
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Align(
                                      alignment: isMe
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: isMe ? 35 : 8,
                                          right: isMe ? 8 : 35,
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: msg.isDeleted
                                              ? Colors.grey[200]
                                              : (isMe ? const Color(0xFF056162) : Colors.white),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isMe
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            if (msg.repliedTo != null)
                                              GestureDetector(
                                                onTap: () => _scrollToMessageById(
                                                  msg.repliedTo!,
                                                  context.read<ChatCubit>().state.chatMessages,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  margin: const EdgeInsets.only(bottom: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '${msg.repliedSenderId == widget.currentUserId
                                                            ? context.locale.languageCode == 'ar'
                                                                  ? 'انت'
                                                                  : 'You'
                                                            : widget.otherUserName}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.black54,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      if (msg.type == MessageType.text)
                                                        Text(
                                                          msg.repliedText ?? '',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            color: isMe
                                                                ? Colors.white70
                                                                : Colors.black54,
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                        ),
                                                      if (msg.type == MessageType.image)
                                                        CustomNetworkImage(
                                                          imageUrl: repliedMessage!.message ?? '',
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      if (msg.type == MessageType.file)
                                                        Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons.insert_drive_file,
                                                              size: 20,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Flexible(
                                                              child: Text(
                                                                msg.message ?? 'ملف',
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                  color: isMe
                                                                      ? Colors.white70
                                                                      : Colors.black54,
                                                                  fontStyle: FontStyle.italic,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      if (msg.type == MessageType.audio)
                                                        AudioMessageWidget(
                                                          audioUrl: msg.message ?? '',
                                                          isReading: msg.isRead,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                            if (msg.type == MessageType.text)
                                              Text(
                                                msg.isDeleted
                                                    ? 'تم حذف الرسالة'
                                                    : (msg.message ?? ''),
                                                style: AppTextStyle.text16MSecond(context).copyWith(
                                                  color: msg.isDeleted
                                                      ? Colors.grey
                                                      : (isMe ? Colors.white : Colors.black),
                                                  fontStyle: msg.isDeleted
                                                      ? FontStyle.italic
                                                      : FontStyle.normal,
                                                ),
                                              ),

                                            if (msg.type == MessageType.image)
                                              msg.isDeleted
                                                  ? Text(
                                                      'تم حذف الصورة',
                                                      style: AppTextStyle.text16MSecond(context)
                                                          .copyWith(
                                                            color: Colors.grey,
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                    )
                                                  : CustomNetworkImage(
                                                      imageUrl: msg.message ?? '',
                                                      width: 200,
                                                      height: 200,
                                                      fit: BoxFit.cover,
                                                    ),

                                            if (msg.type == MessageType.file)
                                              msg.isDeleted
                                                  ? Text(
                                                      'تم حذف الملف',
                                                      style: AppTextStyle.text16MSecond(context)
                                                          .copyWith(
                                                            color: Colors.grey,
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                    )
                                                  : InkWell(
                                                      onTap: () async {
                                                        final url = msg.message ?? '';
                                                        if (url.isEmpty) return;
                                                        // تحميل الملف مؤقتاً لو هو على الإنترنت
                                                        final fileName = url.split('/').last;
                                                        final tempDir =
                                                            await getTemporaryDirectory();
                                                        final file = File(
                                                          '${tempDir.path}/$fileName',
                                                        );

                                                        if (!await file.exists()) {
                                                          final response = await HttpClient()
                                                              .getUrl(Uri.parse(url));
                                                          final result = await response.close();
                                                          final bytes =
                                                              await consolidateHttpClientResponseBytes(
                                                                result,
                                                              );
                                                          await file.writeAsBytes(bytes);
                                                        }
                                                        await OpenFilex.open(file.path);
                                                      },
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                            Icons.insert_drive_file,
                                                            size: 24,
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Flexible(
                                                            child: Text(
                                                              msg.fileName ?? 'ملف',
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: AppTextStyle.text16MSecond(
                                                                context,
                                                                color: isMe
                                                                    ? Colors.white
                                                                    : Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            if (msg.type == MessageType.audio)
                                              msg.isDeleted
                                                  ? Text(
                                                      'تم حذف الصوت',
                                                      style: AppTextStyle.text16MSecond(context)
                                                          .copyWith(
                                                            color: Colors.grey,
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                    )
                                                  : AudioMessageWidget(
                                                      audioUrl: msg.message ?? '',
                                                      isReading: msg.isRead,
                                                    ),

                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (msg.isEdited && !msg.isDeleted)
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                      left: 6,
                                                      right: 4,
                                                    ),
                                                    child: Text(
                                                      context.locale.languageCode == 'ar'
                                                          ? 'تم التعديل'
                                                          : 'Edited',
                                                      style: AppTextStyle.text14RGrey(context)
                                                          .copyWith(
                                                            color: msg.isDeleted
                                                                ? Colors.grey
                                                                : (isMe
                                                                      ? Colors.white70
                                                                      : Colors.black54),
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                    ),
                                                  ),
                                                Text(
                                                  DateFormat('HH:mm a ', 'en').format(msgDate),
                                                  style: AppTextStyle.text14RGrey(context).copyWith(
                                                    color: msg.isDeleted
                                                        ? Colors.grey
                                                        : (isMe ? Colors.white70 : Colors.black54),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: const EdgeInsets.only(left: 4.0),
                                                  child: isMe
                                                      ? Icon(
                                                          msg.isRead ? Icons.done_all : Icons.check,
                                                          size: 16,
                                                          color: msg.isRead
                                                              ? Colors.blue
                                                              : Colors.white,
                                                        )
                                                      : const SizedBox.shrink(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  if (repliedMessage != null)
                    Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Container(width: 3, height: 40, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  repliedMessage!.senderId == widget.currentUserId
                                      ? context.locale.languageCode == 'ar'
                                            ? 'انت'
                                            : 'You'
                                      : widget.otherUserName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (repliedMessage!.type == MessageType.text)
                                  Text(
                                    repliedMessage!.repliedText ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                if (repliedMessage!.type == MessageType.image)
                                  CustomNetworkImage(
                                    imageUrl: repliedMessage!.message ?? '',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                if (repliedMessage!.type == MessageType.file)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.insert_drive_file, size: 20),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          repliedMessage!.message ?? 'ملف',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => repliedMessage = null),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (otherUserIsTyping)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(left: 8, top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                context.locale.languageCode == 'ar' ? 'يكتب الآن...' : 'Typing...',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        if (_showRecordingWidget)
                          RecordingWidget(
                            onSend: (file) async {
                              await _uploadAndSendFile(file, MessageType.audio, cubit);
                              setState(() => _showRecordingWidget = false);
                            },
                          ),

                        Directionality(
                          textDirection: context.locale.languageCode == 'ar'
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  children: [
                                    if (_isRecording)
                                      InkWell(
                                        onTap: () {
                                          setState(() => _isRecording = false);
                                        },
                                        child: const Icon(Icons.delete, color: Colors.red),
                                      )
                                    else ...[
                                      InkWell(
                                        child: const Icon(Icons.image),
                                        onTap: () => _sendImage(cubit),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        child: const Icon(Icons.attach_file),
                                        onTap: () => _sendFile(cubit),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.emoji_emotions_outlined,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showEmojiPicker = !_showEmojiPicker;
                                            FocusScope.of(context).unfocus();
                                          });
                                        },
                                      ),
                                    ],

                                    // حقل النص
                                    Expanded(
                                      child: _isRecording
                                          ? RecordingWidget(
                                              onSend: (file) async {
                                                await _uploadAndSendFile(
                                                  file,
                                                  MessageType.audio,
                                                  cubit,
                                                );
                                                setState(() => _isRecording = false);
                                              },
                                              onCancel: () => setState(() => _isRecording = false),
                                            )
                                          : TextFormField(
                                              controller: _controller,
                                              onTap: () {
                                                if (_showEmojiPicker)
                                                  setState(() => _showEmojiPicker = false);
                                              },
                                              decoration: InputDecoration(
                                                hintText: context.locale.languageCode == 'ar'
                                                    ? 'اكتب رسالتك هنا'
                                                    : 'Write your message here',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                                  borderSide: BorderSide.none,
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                              ),
                                              onChanged: (_) => _startTyping(),
                                            ),
                                    ),

                                    const SizedBox(width: 8),

                                    // زر الإرسال أو الميكروفون
                                    _isRecording
                                        ? const SizedBox.shrink()
                                        : (_controller.text.trim().isEmpty
                                              ? InkWell(
                                                  onTap: () async {
                                                    setState(() => _isRecording = true);
                                                    await _startRecording();
                                                  },
                                                  child: const Icon(Icons.mic, color: Colors.black),
                                                )
                                              : IconButton(
                                                  icon: const Icon(Icons.send, color: Colors.blue),
                                                  onPressed: () => _sendMessage(cubit),
                                                )),
                                  ],
                                ),
                              ),

                              // لوحة الإيموجي
                              if (_showEmojiPicker)
                                Offstage(
                                  offstage: !_showEmojiPicker,
                                  child: Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: EmojiPicker(
                                      textEditingController: _controller,
                                      scrollController: _scrollController,
                                      config: Config(
                                        checkPlatformCompatibility: true,
                                        viewOrderConfig: const ViewOrderConfig(),
                                        emojiViewConfig: EmojiViewConfig(
                                          backgroundColor: Colors.grey[200]!,
                                          emojiSizeMax:
                                              28 *
                                              (foundation.defaultTargetPlatform ==
                                                      TargetPlatform.iOS
                                                  ? 1.2
                                                  : 1.0),
                                          columns: 8,
                                        ),
                                        skinToneConfig: const SkinToneConfig(),
                                        categoryViewConfig: const CategoryViewConfig(),
                                        bottomActionBarConfig: const BottomActionBarConfig(
                                          buttonIconColor: Colors.black,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        searchViewConfig: const SearchViewConfig(
                                          buttonIconColor: Colors.black,
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ------------------- مؤشر "يكتب الآن..." -------------------
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUploading)
            Container(
              color: Colors.black54, // خلفية نصف شفافة
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CustomLoading(color: AppColor.primaryColor(context)),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        context.locale.languageCode == 'ar' ? 'جاري التحميل...' : 'Loading...',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------- صفحة إعادة التوجيه -------------------
class SelectUserScreen extends StatefulWidget {
  final ChatMessage message;
  final int currentUserId;

  const SelectUserScreen({super.key, required this.message, required this.currentUserId});

  @override
  State<SelectUserScreen> createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  String searchText = '';
  final Set<int> selectedUserIds = {};
  final TextEditingController _commentController = TextEditingController();
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    final users = context.read<ServicesCubit>().state.employeesStatus.data ?? [];
    final filteredUsers = users.where((user) {
      if (user.empCode == widget.currentUserId) return false;
      if (searchText.isEmpty) return true;
      return (user.empName ?? '').toLowerCase().contains(searchText.toLowerCase());
    }).toList();
    final selectedUsers = users.where((u) => selectedUserIds.contains(u.empCode)).toList();

    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: isSearching
            ? SizedBox(
                height: 40,
                child: TextField(
                  autofocus: true,
                  onChanged: (val) => setState(() => searchText = val),
                  decoration: InputDecoration(
                    hintText: AppLocalKay.search.tr(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              )
            : Text(
                context.locale.languageCode == 'ar' ? 'اعادة توجيه الي.......' : 'Reply to.......',
                style: AppTextStyle.text18MSecond(context),
              ),
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    searchText = '';
                  });
                },
              )
            : const BackButton(),
        centerTitle: false,
        actions: [
          if (!isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
              icon: const Icon(Icons.search),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (_, index) {
                  final user = filteredUsers[index];
                  final isSelected = selectedUserIds.contains(user.empCode);
                  return CheckboxListTile(
                    value: isSelected,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    activeColor: AppColor.primaryColor(context),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedUserIds.add(user.empCode ?? 0);
                        } else {
                          selectedUserIds.remove(user.empCode ?? 0);
                        }
                      });
                    },
                    title: Text(
                      context.locale.languageCode == 'ar'
                          ? user.empName ?? ''
                          : user.empNameE ?? '',
                    ),
                    secondary: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: Text(
                        (() {
                          final name = user.empNameE ?? '';
                          final match = RegExp(r'[A-Za-z]').firstMatch(name);
                          return match?.group(0)?.toUpperCase() ?? 'A';
                        })(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFormField(
                    controller: _commentController,
                    hintText: context.locale.languageCode == 'ar' ? 'اضف رساله' : 'Add message',
                  ),
                  const SizedBox(height: 8),
                  if (selectedUsers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: selectedUsers.map((u) {
                                  final name = context.locale.languageCode == 'ar'
                                      ? u.empName ?? ''
                                      : u.empNameE ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: Text(
                                      '${name}  , ',
                                      style: AppTextStyle.text14MPrimary(
                                        context,
                                        color: AppColor.blackColor(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Gap(5.w),
                          if (selectedUserIds.isNotEmpty)
                            InkWell(
                              onTap: () async {
                                final messageText =
                                    widget.message.message ??
                                    (_commentController.text.isNotEmpty
                                        ? '\n\n${_commentController.text}'
                                        : '');
                                final chatCubit = context.read<ChatCubit>();
                                for (final userId in selectedUserIds) {
                                  await chatCubit.sendMessageToUser(userId, messageText);
                                }

                                final firstUser = users.firstWhere(
                                  (u) => u.empCode == selectedUserIds.first,
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      currentUserId: widget.currentUserId,
                                      otherUserId: firstUser.empCode ?? 0,
                                      otherUserName: firstUser.empName ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.send,
                                  size: 30,
                                  color: AppColor.whiteColor(context),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
