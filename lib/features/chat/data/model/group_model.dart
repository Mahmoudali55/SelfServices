import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final int adminId;
  final List<Map<String, dynamic>> members;
  final List<int> memberIds;
  final DateTime? createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.adminId,
    required this.members,
    required this.memberIds,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'adminId': adminId,
      'members': members,
      'memberIds': memberIds,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map, String id) {
    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      adminId: map['adminId'] ?? 0,
      members: List<Map<String, dynamic>>.from(map['members'] ?? []),
      memberIds: List<int>.from(map['memberIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  GroupModel copyWith({
    String? name,
    int? adminId,
    List<Map<String, dynamic>>? members,
    List<int>? memberIds,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id,
      name: name ?? this.name,
      adminId: adminId ?? this.adminId,
      members: members ?? this.members,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
