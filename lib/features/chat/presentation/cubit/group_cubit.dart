import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/data/model/group_model.dart';
import 'package:my_template/features/chat/data/repo/chat_repository.dart';
import 'package:my_template/features/chat/data/repo/group_chat_repo.dart';
import 'package:my_template/features/chat/presentation/cubit/group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  final ChatRepository repository;
  final int currentUserId;

  List<GroupModel> groups = [];
  Map<String, List<ChatMessage>> groupMessages = {};
  Map<String, StreamSubscription<List<ChatMessage>>> _messagesSubscriptions = {};

  /// 🟦 مجموعة لتخزين الرسائل المحددة (بواسطة ID)
  final Set<String> _selectedMessageIds = {};

  GroupCubit(this.repository, this.currentUserId) : super(GroupInitial());

  /// الاستماع للمجموعات
  void listenToGroups() {
    repository.getUserGroups(currentUserId).listen((groupList) {
      groups = groupList;
      emit(GroupLoaded(groups, groupMessages: groupMessages));
    });
  }

  void listenToGroupss() {
    repository.getUserGroups(currentUserId).listen((groupList) {
      groups = groupList;
      // استمع لكل مجموعة للحصول على آخر رسالة
      for (var group in groups) {
        listenToGroupMessages(group.id);
      }
      emit(GroupLoaded(groups, groupMessages: groupMessages));
    });
  }

  /// إنشاء مجموعة جديدة
  Future<void> createGroup({
    required String name,
    required String adminname,
    required List<Map<String, dynamic>> members, // id + name
  }) async {
    emit(GroupLoading());
    try {
      final adminId = HiveMethods.getEmpCode(); // جلب ID المستخدم الحالي

      // أضف admin إلى القائمة إذا لم يكن موجود
      if (!members.any((m) => m['id'] == int.parse(adminId ?? ''))) {
        members.add({'id': int.parse(adminId ?? ''), 'name': adminname});
      }

      final groupId = await repository.createGroup(
        name: name,
        adminId: int.parse(adminId ?? ''),
        members: members,
      );

      emit(GroupCreated(groupId));
      listenToGroups();
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  /// الاستماع للرسائل في مجموعة محددة
  void listenToGroupMessages(String groupId) {
    _messagesSubscriptions[groupId]?.cancel();
    _messagesSubscriptions[groupId] = repository.getGroupMessages(groupId).listen((messages) {
      final currentState = state;
      if (currentState is GroupLoaded) {
        final updatedMessages = Map<String, List<ChatMessage>>.from(currentState.groupMessages);
        updatedMessages[groupId] = messages;
        emit(GroupLoaded(currentState.groups, groupMessages: updatedMessages));
      }
    });
  }

  /// إرسال رسالة
  Future<void> sendGroupMessage(String groupId, ChatMessage message) async {
    try {
      await repository.sendGroupMessage(groupId, message);
      // ❌ لا تضيف الرسالة يدوياً، Stream سيحدث واجهة المستخدم تلقائياً
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  /// تحديث رسالة موجودة
  Future<void> updateMessage(String groupId, ChatMessage oldMessage, String newText) async {
    try {
      final updated = oldMessage.copyWith(message: newText);
      await repository.updateGroupMessage(groupId, updated);
      final updatedMessages = groupMessages[groupId]
          ?.map((msg) => msg.id == updated.id ? updated : msg)
          .toList();
      if (updatedMessages != null) {
        groupMessages[groupId] = updatedMessages;
        emit(GroupLoaded(groups, groupMessages: groupMessages));
      }
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  /// حذف رسالة واحدة
  Future<void> deleteMessage(String groupId, ChatMessage message) async {
    try {
      await repository.deleteGroupMessage(groupId, message.id!);
      final updatedMessages = groupMessages[groupId]?.where((msg) => msg.id != message.id).toList();
      if (updatedMessages != null) {
        groupMessages[groupId] = updatedMessages;
        emit(GroupLoaded(groups, groupMessages: groupMessages));
      }
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  /// 🔁 إعادة توجيه رسالة
  Future<void> forwardMessage(ChatMessage message, String targetGroupId) async {
    final forwarded = message.copyWith(timestamp: DateTime.now(), id: null);
    await sendGroupMessage(targetGroupId, forwarded);
  }

  // 🟩-------------------------
  // 🟩 تحديد الرسائل (Selection)
  // 🟩-------------------------

  /// تبديل حالة التحديد
  void toggleMessageSelection(String messageId) {
    if (_selectedMessageIds.contains(messageId)) {
      _selectedMessageIds.remove(messageId);
    } else {
      _selectedMessageIds.add(messageId);
    }

    _refreshSelectionUI();
  }

  /// التحقق من حالة التحديد
  bool isMessageSelected(String messageId) => _selectedMessageIds.contains(messageId);

  /// مسح كل التحديدات
  void clearSelection() {
    _selectedMessageIds.clear();
    _refreshSelectionUI();
  }

  /// حذف كل الرسائل المحددة
  Future<void> deleteSelectedMessages(String groupId) async {
    final selectedIds = _selectedMessageIds.toList();
    for (final id in selectedIds) {
      await repository.deleteGroupMessage(groupId, id);
    }
    _selectedMessageIds.clear();
    final updatedMessages = groupMessages[groupId]
        ?.where((msg) => !selectedIds.contains(msg.id))
        .toList();
    if (updatedMessages != null) {
      groupMessages[groupId] = updatedMessages;
      emit(GroupLoaded(groups, groupMessages: groupMessages));
    }
  }

  Future<void> addMemberToGroup(String groupId, int empId, String name) async {
    try {
      await repository.addMemberToGroup(groupId, empId, name);

      // بعد إضافة العضو، تحديث الحالة الحالية لإظهار التغيير فورًا
      final currentState = state;
      if (currentState is GroupLoaded) {
        final groups = List<GroupModel>.from(currentState.groups);
        final index = groups.indexWhere((g) => g.id == groupId);
        if (index != -1) {
          // إضافة العضو للمجموعة المحلية
          final members = List<Map<String, dynamic>>.from(groups[index].members);
          members.add({'id': empId, 'name': name}); // يمكنك تمرير الاسم الحقيقي
          groups[index] = groups[index].copyWith(members: members);
          emit(GroupLoaded(groups, groupMessages: currentState.groupMessages));
        }
      }
    } catch (e) {
      emit(GroupError('فشل إضافة العضو: $e'));
    }
  }

  /// تحديث واجهة المستخدم بعد التحديد
  void _refreshSelectionUI() {
    if (state is GroupLoaded) {
      final current = state as GroupLoaded;
      emit(GroupLoaded(current.groups, groupMessages: current.groupMessages)); // إعادة بناء الواجهة
    }
  }

  /// مغادرة المجموعة
  Future<void> leaveGroup(String groupId) async {
    try {
      final userId = currentUserId; // أو HiveMethods.getEmpCode() إذا تفضل

      // استدعاء repository لإزالة العضو من المجموعة
      await repository.removeMemberFromGroup(groupId, userId);

      // إزالة المستخدم محليًا إذا تريد تحديث UI فورًا
      groups = groups.map((g) {
        if (g.id == groupId) {
          final updatedMembers = g.members.where((member) => member['id'] != userId).toList();
          return g.copyWith(members: updatedMembers);
        }
        return g;
      }).toList();

      emit(GroupLoaded(groups, groupMessages: groupMessages));
    } catch (e) {
      emit(GroupError('فشل مغادرة المجموعة: $e'));
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMemberFromGroup(String groupId, int userId) async {
    await repository.removeMemberFromGroup(groupId, userId);

    final state = this.state;
    if (state is GroupLoaded) {
      final updatedGroups = state.groups.map((g) {
        if (g.id == groupId) {
          final updatedMembers = g.members.where((m) => m['id'] != userId).toList();
          final updatedMemberIds = g.memberIds.where((id) => id != userId).toList();
          return g.copyWith(members: updatedMembers, memberIds: updatedMemberIds);
        }
        return g;
      }).toList();

      emit(GroupLoaded(updatedGroups, groupMessages: state.groupMessages));
    }
  }

  Future<void> markMessageAsRead(String groupId, ChatMessage msg) async {
    if (msg.isRead) return;
    final updatedMsg = msg.copyWith(isRead: true);
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(msg.id)
        .update({'isRead': true});
  }

  int get selectedCount => _selectedMessageIds.length;

  @override
  Future<void> close() {
    for (var sub in _messagesSubscriptions.values) {
      sub.cancel();
    }
    return super.close();
  }
}
