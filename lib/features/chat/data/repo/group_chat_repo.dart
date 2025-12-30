import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/data/model/group_model.dart';
import 'package:my_template/features/chat/data/repo/chat_repository.dart';

extension GroupChat on ChatRepository {
  Future<String> createGroup({
    required String name,
    required int adminId,
    required List<Map<String, dynamic>> members,
  }) async {
    final memberIds = members.map((m) => m['id']).toList();

    final doc = await firestore.collection('groups').add({
      'name': name,
      'adminId': adminId,
      'members': members,
      'memberIds': memberIds,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> sendGroupMessage(String groupId, ChatMessage message) async {
    await firestore.collection('groups').doc(groupId).collection('messages').add(message.toMap());
  }

  Future<void> updateGroupMessage(String groupId, ChatMessage message) async {
    if (message.id == null) return;
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(message.id)
        .update(message.toMap());
  }

  Future<void> deleteGroupMessage(String groupId, String messageId) async {
    if (messageId.isEmpty) return;
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Stream<List<ChatMessage>> getGroupMessages(String groupId, {int limit = 20}) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.data(), id: doc.id))
              .toList()
              .reversed
              .toList(),
        );
  }

  Future<List<ChatMessage>> fetchHistoryGroupMessages({
    required String groupId,
    required DateTime beforeTimestamp,
    int limit = 20,
  }) async {
    final snapshot = await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .where('timestamp', isLessThan: beforeTimestamp)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ChatMessage.fromMap(doc.data(), id: doc.id))
        .toList()
        .reversed
        .toList();
  }

  Stream<List<GroupModel>> getUserGroups(int userId) {
    return firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => GroupModel.fromMap(doc.data(), doc.id)).toList(),
        );
  }

  Future<void> addMemberToGroup(String groupId, int empId, String name) async {
    final groupDoc = firestore.collection('groups').doc(groupId);

    await groupDoc.update({
      'members': FieldValue.arrayUnion([
        {'id': empId, 'name': name},
      ]),
      'memberIds': FieldValue.arrayUnion([empId]),
    });
  }

  Future<void> removeMemberFromGroup(String groupId, int userId) async {
    final groupDoc = firestore.collection('groups').doc(groupId);

    final snapshot = await groupDoc.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final List members = data['members'] ?? [];
    final List memberIds = data['memberIds'] ?? [];

    final updatedMembers = members.where((m) => m['id'].toString() != userId.toString()).toList();
    final updatedMemberIds = memberIds.where((id) => id.toString() != userId.toString()).toList();

    await groupDoc.update({'members': updatedMembers, 'memberIds': updatedMemberIds});
  }
}
