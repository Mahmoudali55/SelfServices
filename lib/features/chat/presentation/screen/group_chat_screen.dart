import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_loading/custom_loading.dart';
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
import 'package:my_template/features/chat/presentation/screen/widget/chat_app_bar.dart';
import 'package:my_template/features/chat/presentation/screen/widget/chat_input_field.dart';
import 'package:my_template/features/chat/presentation/screen/widget/cloudinary_service.dart';
import 'package:my_template/features/chat/presentation/screen/widget/message_list.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<ChatUser>? members;

  const GroupChatScreen({super.key, required this.groupId, required this.groupName, this.members});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isRecording = false;
  late final CloudinaryService _cloudinaryService;
  bool isUploading = false;

  ChatMessage? repliedMessage;
  String? editingMessageId;
  String? selectedMessageId;
  String? highlightedMessageId;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cloudinaryService = CloudinaryService();

    context.read<GroupCubit>().listenToGroupMessages(widget.groupId);

    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _scrollToMessageById(String messageId, List<ChatMessage> messages) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final offset = index * 120.0;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      setState(() {
        highlightedMessageId = messageId;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            highlightedMessageId = null;
          });
        }
      });
    }
  }

  void _markAsReadIfNeeded(List<ChatMessage> messages, GroupCubit cubit) {
    for (var msg in messages) {
      if (!msg.isRead && msg.senderId != cubit.currentUserId) {
        cubit.markMessageAsRead(widget.groupId, msg);
      }
    }
  }

  String getUserNameById(int userId) {
    final cubit = context.read<GroupCubit>();
    if (userId == cubit.currentUserId) return AppLocalKay.me.tr();

    final state = cubit.state;
    if (state is GroupLoaded) {
      try {
        final group = state.groups.firstWhere((g) => g.id == widget.groupId);
        final member = group.members.firstWhere(
          (m) => m['id'] == userId,
          orElse: () => <String, dynamic>{},
        );
        if (member.isNotEmpty) return member['name'];
      } catch (_) {}
    }

    final user = widget.members?.firstWhere(
      (element) => element.id == userId,
      orElse: () => ChatUser(id: userId, name: '${AppLocalKay.user.tr()} $userId'),
    );
    return user?.name ?? '${AppLocalKay.user.tr()} $userId';
  }

  Future<void> _sendMessage() async {
    final cubit = context.read<GroupCubit>();
    final text = _controller.text.trim();

    if (text.isEmpty && repliedMessage == null) return;

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
        message: text.isEmpty ? null : text,
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
    await Permission.microphone.request();
    setState(() => _isRecording = true);
  }

  Future<void> _sendImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final file = File(picked.path);
      await _uploadAndSendFile(file, MessageType.image);
    } catch (e) {
      CommonMethods.showToast(message: e.toString(), type: ToastType.error);
    }
  }

  Future<void> _sendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;
      final file = File(result.files.first.path!);
      await _uploadAndSendFile(file, MessageType.file);
    } catch (e) {
      CommonMethods.showToast(message: e.toString(), type: ToastType.error);
    }
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
            if (!msg.isDeleted && msg.senderId == context.read<GroupCubit>().currentUserId)
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppLocalKay.edit.tr(), style: AppTextStyle.text16MSecond(context)),
                onTap: () {
                  Navigator.pop(context);
                  _controller.text = msg.message ?? '';
                  editingMessageId = msg.id;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
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
                                  String _cleanName(String name) =>
                                      name.replaceFirst(RegExp(r'^\d+\s*'), '').trim();
                                  final emp = filteredEmployees[index];
                                  final empName = context.locale.languageCode == 'ar'
                                      ? _cleanName(emp.empName ?? 'الموظف')
                                      : _cleanName(emp.empNameE ?? 'Employee');
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(empName.isNotEmpty ? empName[0] : '?'),
                                    ),
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GroupCubit>();

    return Scaffold(
      appBar: ChatAppBar(
        context: context,
        otherUserName: widget.groupName,
        isSelectionMode: selectedMessageId != null,
        onCloseSelection: () => setState(() => selectedMessageId = null),
        onDeleteMessages: () {
          if (selectedMessageId != null) {
            final state = cubit.state;
            if (state is GroupLoaded && state.groupMessages.containsKey(widget.groupId)) {
              final msg = state.groupMessages[widget.groupId]!.firstWhere(
                (m) => m.id == selectedMessageId,
              );
              cubit.deleteMessage(widget.groupId, msg);
              setState(() => selectedMessageId = null);
            }
          }
        },
        onBack: () => Navigator.pop(context),
        subtitle: BlocBuilder<GroupCubit, GroupState>(
          builder: (context, state) {
            if (state is! GroupLoaded) return const SizedBox.shrink();
            final group = state.groups.firstWhere(
              (g) => g.id == widget.groupId,
              orElse: () => GroupModel(id: '', name: '', members: [], adminId: 0, memberIds: []),
            );
            if (group.members.isEmpty) return const SizedBox.shrink();

            final membersNames = group.members.map((m) => m['name']).join(', ');

            return Text(
              membersNames,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) async {
              final state = cubit.state;
              final groupData = (state is GroupLoaded)
                  ? state.groups.firstWhere((g) => g.id == widget.groupId)
                  : null;
              final isAdminLocal = cubit.currentUserId == groupData?.adminId;

              switch (value) {
                case 'add_member':
                  if (groupData != null) _addMemberToGroup(groupData.id);
                  break;
                case 'leave_group':
                  if (groupData == null) return;
                  final confirmLeave = await showDialog<bool>(
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
                  if (confirmLeave == true) {
                    cubit.leaveGroup(widget.groupId);
                    Navigator.pop(context);
                  }
                  break;
                case 'delete_group':
                  if (!isAdminLocal || groupData == null) return;
                  final confirmDelete = await showDialog<bool>(
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
                  if (confirmDelete == true) {
                    await cubit.deleteGroup(widget.groupId);
                    Navigator.pop(context);
                  }
                  break;
                case 'remove_member':
                  if (!isAdminLocal || groupData == null) return;
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
                              return ListTile(
                                title: Text(member['name']),
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
              final state = cubit.state;
              final groupData = (state is GroupLoaded)
                  ? state.groups.firstWhere((g) => g.id == widget.groupId)
                  : null;
              final isAdminLocal = cubit.currentUserId == groupData?.adminId;
              return [
                PopupMenuItem(value: 'add_member', child: Text(AppLocalKay.add_member.tr())),
                PopupMenuItem(value: 'leave_group', child: Text(AppLocalKay.leave_group_menu.tr())),
                if (isAdminLocal)
                  PopupMenuItem(
                    value: 'remove_member',
                    child: Text(AppLocalKay.remove_member.tr()),
                  ),
                if (isAdminLocal)
                  PopupMenuItem(
                    value: 'delete_group',
                    child: Text(AppLocalKay.delete_group_menu.tr()),
                  ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFE5DDD5)),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: BlocConsumer<GroupCubit, GroupState>(
                    listener: (context, state) {
                      if (state is GroupLoaded && state.groupMessages.containsKey(widget.groupId)) {
                        final messages = state.groupMessages[widget.groupId]!;
                        _markAsReadIfNeeded(messages, cubit);
                        if (_scrollController.hasClients && _scrollController.offset < 100) {
                          _scrollToBottom();
                        }
                      }
                    },
                    builder: (context, state) {
                      final messages =
                          state is GroupLoaded && state.groupMessages.containsKey(widget.groupId)
                          ? state.groupMessages[widget.groupId]!
                          : <ChatMessage>[];

                      return MessageList(
                        messages: messages.reversed.toList(),
                        currentUserId: cubit.currentUserId,
                        scrollController: _scrollController,
                        selectedMessageId: selectedMessageId,
                        highlightedMessageId: highlightedMessageId,
                        getSenderName: (userId) => getUserNameById(userId),
                        onLongPress: (msg) {
                          setState(() => selectedMessageId = msg.id);
                          _showMessageOptions(msg);
                        },
                        onReplyTap: (repliedId) {
                          _scrollToMessageById(repliedId, messages);
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
                      ? getUserNameById(repliedMessage!.senderId)
                      : null,
                  onToggleEmoji: () {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                      if (_showEmojiPicker) FocusScope.of(context).unfocus();
                    });
                  },
                  onSend: _sendMessage,
                  onPickImage: _sendImage,
                  onPickFile: _sendFile,
                  onStartRecording: _startRecording,
                  onRecordingComplete: (file) async {
                    await _uploadAndSendFile(file, MessageType.audio);
                    setState(() => _isRecording = false);
                  },
                  onCancelRecording: () => setState(() => _isRecording = false),
                  onCancelReply: () => setState(() => repliedMessage = null),
                  onTyping: (text) {
                    setState(() {});
                  },
                ),
              ],
            ),
            if (isUploading) _buildUploadOverlay(),
          ],
        ),
      ),
    );
  }
}
