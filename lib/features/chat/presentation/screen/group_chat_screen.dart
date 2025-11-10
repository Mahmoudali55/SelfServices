import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/data/model/group_model.dart';
import 'package:my_template/features/chat/presentation/cubit/group_cubit.dart';
import 'package:my_template/features/chat/presentation/cubit/group_state.dart';
import 'package:my_template/features/chat/presentation/screen/widget/audio_message_widget.dart';
import 'package:my_template/features/chat/presentation/screen/widget/cloudinary_service.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<ChatUser>? members;

  const GroupChatScreen({super.key, required this.groupId, required this.groupName, this.members});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String? _recordedFilePath;
  late CloudinaryService _cloudinaryService;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool isUploading = false;

  ChatMessage? repliedMessage;
  String? editingMessageId;
  String? selectedMessageId;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _cloudinaryService = CloudinaryService();
    _audioRecorder = FlutterSoundRecorder();
    _initRecorder();
    context.read<GroupCubit>().listenToGroupMessages(widget.groupId);
    _controller.addListener(() => setState(() {}));
  }

  Future<void> _initRecorder() async {
    await _audioRecorder!.openRecorder();
    await Permission.microphone.request();
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

  String getUserNameById(int userId) {
    if (userId == context.read<GroupCubit>().currentUserId) return AppLocalKay.me.tr();
    final user = widget.members?.firstWhere(
      (element) => element.id == userId,
      orElse: () => ChatUser(id: userId, name: '${AppLocalKay.user.tr()} $userId'),
    );
    return user?.name ?? '${AppLocalKay.user.tr()} $userId';
  }

  void _showMessageOptions(ChatMessage msg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(AppLocalKay.edit.tr(), style: AppTextStyle.text16MSecond(context)),
              onTap: () {
                Navigator.pop(context);
                if (!msg.isDeleted && msg.senderId == context.read<GroupCubit>().currentUserId) {
                  _controller.text = msg.message ?? '';
                  editingMessageId = msg.id;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(AppLocalKay.delete.tr(), style: AppTextStyle.text16MSecond(context)),
              onTap: () {
                Navigator.pop(context);
                context.read<GroupCubit>().deleteMessage(widget.groupId, msg);
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply, color: Colors.blue),
              title: Text(AppLocalKay.reply.tr(), style: AppTextStyle.text16MSecond(context)),
              onTap: () {
                Navigator.pop(context);
                setState(() => repliedMessage = msg);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final cubit = context.read<GroupCubit>();
    final text = _controller.text.trim();

    if (text.isEmpty && repliedMessage == null && _recordedFilePath == null) return;

    if (editingMessageId != null) {
      final state = cubit.state;
      if (state is GroupLoaded && state.groupMessages.containsKey(widget.groupId)) {
        final msg = state.groupMessages[widget.groupId]!.firstWhere(
          (m) => m.id == editingMessageId,
        );
        await cubit.updateMessage(widget.groupId, msg, text);
        editingMessageId = null;
      }
    } else {
      final msg = ChatMessage(
        senderId: cubit.currentUserId,
        receiverId: 0,
        message: text,
        conversationId: widget.groupId,
        repliedTo: repliedMessage?.id,
        repliedText: repliedMessage?.message,
        repliedSenderId: repliedMessage?.senderId,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      cubit.sendGroupMessage(widget.groupId, msg);
    }

    _controller.clear();
    repliedMessage = null;
    selectedMessageId = null;
    _scrollToBottom();
  }

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

  Future<void> _stopRecording() async {
    final path = await _audioRecorder!.stopRecorder();
    _recordingTimer?.cancel();
    _recordingSeconds = 0;
    setState(() => _isRecording = false);
    _recordedFilePath = path;

    if (_recordedFilePath != null) {
      final file = File(_recordedFilePath!);
      await _uploadAndSendFile(file, MessageType.audio);
    }
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    await _uploadAndSendFile(file, MessageType.image);
  }

  Future<void> _sendFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final file = File(result.files.first.path!);
    await _uploadAndSendFile(file, MessageType.file);
  }

  Future<void> _uploadAndSendFile(File file, MessageType type) async {
    final cubit = context.read<GroupCubit>();
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
        final msg = ChatMessage(
          senderId: cubit.currentUserId,
          receiverId: 0,
          message: url,
          conversationId: widget.groupId,
          type: type,
          fileName: file.path.split('/').last,
          repliedTo: repliedMessage?.id,
          repliedText: repliedMessage?.message,
          repliedSenderId: repliedMessage?.senderId,
          timestamp: DateTime.now(),
        );
        cubit.sendGroupMessage(widget.groupId, msg);
        _scrollToBottom();
      }
    } catch (e) {
      CommonMethods.showToast(message: e.toString(), type: ToastType.error);
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  void _addMemberToGroup(String groupId) {
    final cubit = context.read<GroupCubit>();

    final serviceState = context.read<ServicesCubit>().state;
    if (!serviceState.employeesStatus.isSuccess) return;

    final employees = serviceState.employeesStatus.data ?? [];

    List<dynamic> filteredEmployees = List.from(employees);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            void _filterEmployees(String query) {
              final lowerQuery = query.toLowerCase();
              setState(() {
                filteredEmployees = employees.where((emp) {
                  final nameAr = emp.empName?.toLowerCase() ?? '';
                  final nameEn = emp.empNameE?.toLowerCase() ?? '';
                  return nameAr.contains(lowerQuery) || nameEn.contains(lowerQuery);
                }).toList();
              });
            }

            return SizedBox(
              height: 600,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalKay.selectEmployee.tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      CustomFormField(
                        controller: searchController,
                        hintText: context.locale.languageCode == 'ar'
                            ? 'ابحث عن الموظف'
                            : 'Search for employee',
                        onChanged: _filterEmployees,
                      ),
                      const SizedBox(height: 10),

                      Expanded(
                        child: filteredEmployees.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      AppImages.assetsGlobalIconEmptyFolderIcon,
                                      height: 100,
                                      width: 100,
                                      color: Colors.blue,
                                    ),
                                    const Gap(30),
                                    Text(
                                      AppLocalKay.noResults.tr(),
                                      style: AppTextStyle.text16MSecond(context),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredEmployees.length,
                                itemBuilder: (context, index) {
                                  String _cleanName(String name) {
                                    return name.replaceFirst(RegExp(r'^\d+\s*'), '').trim();
                                  }

                                  final emp = filteredEmployees[index];
                                  final empName = context.locale.languageCode == 'ar'
                                      ? emp.empName ?? 'الموظف'
                                      : emp.empNameE ?? 'الموظف';

                                  return ListTile(
                                    leading: CircleAvatar(child: Text(empName[0])),
                                    title: Text(_cleanName(empName)),
                                    onTap: () async {
                                      try {
                                        final state = cubit.state;
                                        if (state is GroupLoaded) {
                                          final group = state.groups.firstWhere(
                                            (g) => g.id == groupId,
                                          );

                                          final exists = group.members.any(
                                            (m) => m['id'] == emp.empCode,
                                          );
                                          if (exists) {
                                            CommonMethods.showToast(
                                              message: AppLocalKay.employee_already_in_group.tr(),
                                              seconds: 3,
                                              type: ToastType.error,
                                            );
                                          } else {
                                            await cubit.addMemberToGroup(
                                              groupId,
                                              emp.empCode,
                                              empName,
                                            );

                                            CommonMethods.showToast(
                                              message: AppLocalKay.employee_added_success.tr(),
                                              seconds: 3,
                                              type: ToastType.success,
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        CommonMethods.showToast(
                                          message: e.toString(),
                                          seconds: 3,
                                          type: ToastType.error,
                                        );
                                      }
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool get isAdmin {
    final cubit = context.read<GroupCubit>();
    final state = cubit.state;
    if (state is GroupLoaded) {
      final group = state.groups.firstWhere(
        (g) => g.id == widget.groupId,
        orElse: () => GroupModel(id: '', name: '', members: [], adminId: 0, memberIds: []),
      );

      return group.adminId == cubit.currentUserId;
    }
    return false;
  }

  @override
  void dispose() {
    _audioRecorder?.closeRecorder();
    _audioRecorder = null;
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GroupCubit>();
    final state = cubit.state;
    GroupModel? groupData;

    if (state is GroupLoaded && state.groups.any((g) => g.id == widget.groupId)) {
      groupData = state.groups.firstWhere((g) => g.id == widget.groupId);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.groupName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              BlocBuilder<GroupCubit, GroupState>(
                builder: (context, state) {
                  if (state is! GroupLoaded) return const SizedBox.shrink();
                  final group = state.groups.firstWhere(
                    (g) => g.id == widget.groupId,
                    orElse: () =>
                        GroupModel(id: '', name: '', members: [], adminId: 0, memberIds: []),
                  );
                  if (group.members.isEmpty) return const SizedBox.shrink();

                  return SizedBox(
                    height: 30,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: group.members.length,
                      itemBuilder: (context, index) {
                        final member = group.members[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            member['name'],
                            style: const TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) async {
                final cubit = context.read<GroupCubit>(); // read بدون listen
                final state = cubit.state;
                final groupData = (state is GroupLoaded)
                    ? state.groups.firstWhere((g) => g.id == widget.groupId)
                    : null;
                final isAdmin = cubit.currentUserId == groupData?.adminId;

                switch (value) {
                  case 'add_member':
                    if (groupData != null) _addMemberToGroup(groupData.id);
                    break;

                  case 'leave_group':
                    if (groupData == null) return;
                    bool confirmLeave = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(AppLocalKay.leave_group.tr()),
                        content: Text(AppLocalKay.leave_group_confirmation.tr()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalKay.cancel.tr()),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(AppLocalKay.leave_group.tr()),
                          ),
                        ],
                      ),
                    );
                    if (confirmLeave) {
                      cubit.leaveGroup(widget.groupId);
                      CommonMethods.showToast(
                        message: AppLocalKay.leave_group_confirmation.tr(),
                        seconds: 3,
                        type: ToastType.success,
                      );
                      Navigator.pop(context);
                    }
                    break;

                  case 'delete_group':
                    if (!isAdmin || groupData == null) return;
                    bool confirmDelete = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(AppLocalKay.delete_group.tr()),
                        content: Text(AppLocalKay.delete_group_confirmation.tr()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalKay.cancel.tr()),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(AppLocalKay.delete.tr()),
                          ),
                        ],
                      ),
                    );
                    if (confirmDelete) {
                      await cubit.deleteGroup(widget.groupId);
                      CommonMethods.showToast(
                        message: AppLocalKay.group_deleted_success.tr(),
                        seconds: 3,
                        type: ToastType.success,
                      );
                      Navigator.pop(context);
                    }
                    break;

                  case 'remove_member':
                    if (!isAdmin || groupData == null) return;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return ListView(
                          shrinkWrap: true,
                          children: groupData.members
                              .where((m) => m['id'] != cubit.currentUserId)
                              .map((member) {
                                String _cleanName(String name) {
                                  return name.replaceFirst(RegExp(r'^\d+\s*'), '').trim();
                                }

                                return ListTile(
                                  title: Text(_cleanName(member['name'])),
                                  trailing: Text(
                                    AppLocalKay.delete.tr(),
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () async {
                                    await cubit.removeMemberFromGroup(widget.groupId, member['id']);
                                    Navigator.pop(context);
                                    CommonMethods.showToast(
                                      message: 'تم حذف العضو ${member['name']} بنجاح',
                                      seconds: 3,
                                      type: ToastType.success,
                                    );
                                  },
                                );
                              })
                              .toList(),
                        );
                      },
                    );
                    break;
                }
              },
              itemBuilder: (context) {
                final cubit = context.read<GroupCubit>();
                final state = cubit.state;
                final groupData = (state is GroupLoaded)
                    ? state.groups.firstWhere((g) => g.id == widget.groupId)
                    : null;
                final isAdmin = cubit.currentUserId == groupData?.adminId;

                return [
                  PopupMenuItem(value: 'add_member', child: Text(AppLocalKay.add_member.tr())),
                  PopupMenuItem(
                    value: 'leave_group',
                    child: Text(AppLocalKay.leave_group_menu.tr()),
                  ),
                  if (isAdmin)
                    PopupMenuItem(
                      value: 'remove_member',
                      child: Text(AppLocalKay.remove_member.tr()),
                    ),
                  if (isAdmin)
                    PopupMenuItem(
                      value: 'delete_group',
                      child: Text(AppLocalKay.delete_group_menu.tr()),
                    ),
                ];
              },
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<GroupCubit, GroupState>(
                builder: (context, state) {
                  List<ChatMessage> messages =
                      state is GroupLoaded && state.groupMessages.containsKey(widget.groupId)
                      ? state.groupMessages[widget.groupId]!
                      : [];

                  if (messages.isEmpty)
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message, size: 100, color: AppColor.primaryColor(context)),
                          Text(
                            AppLocalKay.start_chat.tr(),
                            style: AppTextStyle.text16MSecond(context),
                          ),
                        ],
                      ),
                    );

                  DateTime? previousDate;

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == cubit.currentUserId;
                      final msgDate = msg.timestamp;
                      final isSelected = msg.id == selectedMessageId;

                      if (!isMe && !msg.isRead) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          cubit.markMessageAsRead(widget.groupId, msg);
                        });
                      }

                      String dateLabel;
                      final now = DateTime.now();
                      if (msgDate.year == now.year &&
                          msgDate.month == now.month &&
                          msgDate.day == now.day) {
                        dateLabel = context.locale.languageCode == 'ar' ? 'اليوم' : 'Today';
                      } else {
                        dateLabel = DateFormat('dd/MM/yyyy').format(msgDate);
                      }

                      bool showDate =
                          previousDate == null ||
                          previousDate?.year != msgDate.year ||
                          previousDate?.month != msgDate.month ||
                          previousDate?.day != msgDate.day;
                      previousDate = msgDate;

                      return SingleChildScrollView(
                        child: Column(
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
                              onTap: () {
                                setState(() {
                                  if (selectedMessageId == msg.id) {
                                    selectedMessageId = null;
                                  } else {
                                    selectedMessageId = msg.id;
                                  }
                                });
                              },
                              onLongPress: () {
                                _showMessageOptions(msg);
                                setState(() => selectedMessageId = msg.id);
                              },
                              child: Container(
                                key: ValueKey(msg.id),
                                color: isSelected
                                    ? Colors.greenAccent.withOpacity(0.3)
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Align(
                                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                                          ? Colors.grey.shade300
                                          : isMe
                                          ? const Color(0xFF056162)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (msg.repliedText != null)
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 4),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${getUserNameById(msg.repliedSenderId ?? 0)}: ${msg.repliedText}',
                                              style: AppTextStyle.text16MSecond(
                                                context,
                                                color: isMe ? Colors.white70 : Colors.black54,
                                              ),
                                            ),
                                          ),
                                        if (msg.type == MessageType.text)
                                          Text(
                                            msg.isDeleted ? 'تم الحذف' : msg.message ?? '',
                                            style: AppTextStyle.text16MSecond(
                                              context,
                                              color: isMe ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        if (msg.type == MessageType.image && msg.message != null)
                                          CustomNetworkImage(imageUrl: msg.message!),
                                        if (msg.type == MessageType.audio && msg.message != null)
                                          AudioMessageWidget(
                                            audioUrl: msg.message!,
                                            isReading: !isMe,
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                DateFormat('hh:mm a').format(msg.timestamp),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: isMe ? Colors.white70 : Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              if (isMe)
                                                Icon(
                                                  msg.isRead ? Icons.done_all : Icons.check,
                                                  size: 18,
                                                  color: msg.isRead ? Colors.blue : Colors.white70,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (repliedMessage != null)
              Container(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: Text('${AppLocalKay.reply.tr()} : ${repliedMessage!.message}')),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => repliedMessage = null),
                    ),
                  ],
                ),
              ),
            if (isUploading) const LinearProgressIndicator(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              color: Colors.white,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.emoji_emotions),
                    ),
                  ),
                  InkWell(
                    onTap: _sendFile,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.attach_file),
                    ),
                  ),
                  InkWell(
                    onTap: _sendImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.image),
                    ),
                  ),

                  Expanded(
                    child: CustomFormField(
                      controller: _controller,
                      hintText: AppLocalKay.message_placeholder.tr(),
                    ),
                  ),

                  _controller.text.isEmpty
                      ? IconButton(
                          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                          onPressed: _isRecording ? _stopRecording : _startRecording,
                        )
                      : IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
                ],
              ),
            ),

            if (_showEmojiPicker)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _controller.text += emoji.emoji;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
