import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_state.dart';
import 'package:my_template/features/chat/presentation/screen/widget/chat_app_bar.dart';
import 'package:my_template/features/chat/presentation/screen/widget/chat_input_field.dart';
import 'package:my_template/features/chat/presentation/screen/widget/cloudinary_service.dart';
import 'package:my_template/features/chat/presentation/screen/widget/message_list.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
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
  bool _isRecording = false;
  late CloudinaryService _cloudinaryService;
  Timer? _typingTimer;
  bool otherUserIsTyping = false;

  bool _showEmojiPicker = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final cubit = context.read<ChatCubit>();
    cubit.setOtherUserId(widget.otherUserId);

    _cloudinaryService = CloudinaryService();

    cubit.setMyOnlineStatus(true);

    _listenToOtherUserTyping();
    _controller.addListener(() {
      setState(() {});
    });
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
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
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
    // This is now handled within RecordingWidget
    // We just need to request permission if not already granted
    await Permission.microphone.request();
    setState(() => _isRecording = true);
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
      appBar: ChatAppBar(
        context: context,
        otherUserName: widget.otherUserName,
        userStatusStream: cubit.getUserStatusStream(widget.otherUserId),
        otherUserIsTyping: otherUserIsTyping,
        isSelectionMode: selectedMessageId != null,
        onCloseSelection: () => setState(() => selectedMessageId = null),
        onDeleteMessages: () {
          if (selectedMessageId != null) {
            final msg = cubit.state.chatMessages.firstWhere((m) => m.id == selectedMessageId);
            cubit.deleteMessage(msg);
            setState(() => selectedMessageId = null);
          }
        },
        onBack: () => Navigator.pop(context),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (selectedMessageId != null) {
            setState(() {
              selectedMessageId = null;
            });
          }
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFFE5DDD5)),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: BlocConsumer<ChatCubit, ChatState>(
                      listener: (context, state) {
                        if (_scrollController.hasClients && _scrollController.offset < 100) {
                          _scrollToBottom();
                        }
                      },
                      builder: (context, state) {
                        return MessageList(
                          messages: state.chatMessages.reversed.toList(),
                          currentUserId: widget.currentUserId,
                          otherUserName: widget.otherUserName,
                          scrollController: _scrollController,
                          selectedMessageId: selectedMessageId,
                          highlightedMessageId: highlightedMessageId,
                          onLongPress: (msg) {
                            setState(() => selectedMessageId = msg.id);
                            _showOptionsDialog(msg, cubit);
                          },
                          onReplyTap: (repliedId) {
                            _scrollToMessageById(repliedId, state.chatMessages);
                          },
                        );
                      },
                    ),
                  ),
                  ChatInputField(
                    controller: _controller,
                    isRecording: _isRecording,
                    showEmojiPicker: _showEmojiPicker,
                    isUploading: isUploading,
                    repliedMessage: repliedMessage,
                    repliedMessageSenderName: repliedMessage != null
                        ? (repliedMessage!.senderId == widget.currentUserId
                              ? (context.locale.languageCode == 'ar' ? 'أنت' : 'You')
                              : widget.otherUserName)
                        : null,
                    otherUserName: widget.otherUserName,
                    onToggleEmoji: () {
                      setState(() {
                        _showEmojiPicker = !_showEmojiPicker;
                        if (_showEmojiPicker) FocusScope.of(context).unfocus();
                      });
                    },
                    onSend: () => _sendMessage(cubit),
                    onPickImage: () => _sendImage(cubit),
                    onPickFile: () => _sendFile(cubit),
                    onStartRecording: () async {
                      await _startRecording();
                    },
                    onRecordingComplete: (file) async {
                      await _uploadAndSendFile(file, MessageType.audio, cubit);
                      setState(() => _isRecording = false);
                    },
                    onCancelRecording: () => setState(() => _isRecording = false),
                    onCancelReply: () => setState(() => repliedMessage = null),
                    onTyping: (text) {
                      _startTyping();
                    },
                  ),
                ],
              ),
              if (isUploading) _buildUploadOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog(ChatMessage msg, ChatCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.reply, color: Colors.blue),
              title: Text(AppLocalKay.reply.tr()),
              onTap: () {
                Navigator.pop(context);
                setState(() => repliedMessage = msg);
              },
            ),
            if (msg.senderId == widget.currentUserId && !msg.isDeleted)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.orange),
                title: Text(AppLocalKay.editmessage.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _controller.text = msg.message ?? '';
                  editingMessageId = msg.id;
                },
              ),
            if (!msg.isDeleted)
              ListTile(
                leading: const Icon(Icons.forward, color: Colors.green),
                title: Text(AppLocalKay.forward.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _forwardMessage(msg);
                },
              ),
            if (msg.senderId == widget.currentUserId)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(AppLocalKay.deletemessage.tr()),
                onTap: () {
                  Navigator.pop(context);
                  cubit.deleteMessage(msg);
                  setState(() => selectedMessageId = null);
                },
              ),
            if (msg.message != null && msg.message!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.grey),
                title: Text(context.locale.languageCode == 'ar' ? 'نسخ الرسالة' : 'Copy message'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: msg.message!));
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.locale.languageCode == 'ar' ? 'تم نسخ الرسالة' : 'Message copied',
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomLoading(color: AppColor.primaryColor(context)),
              const SizedBox(width: 16),
              Text(context.locale.languageCode == 'ar' ? 'جاري التحميل...' : 'Loading...'),
            ],
          ),
        ),
      ),
    );
  }
}

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
