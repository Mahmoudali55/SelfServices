import 'package:equatable/equatable.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/data/model/group_model.dart';

abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupCreated extends GroupState {
  final String groupId;
  const GroupCreated(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class GroupError extends GroupState {
  final String message;
  const GroupError(this.message);

  @override
  List<Object?> get props => [message];
}

/// ← نسخة محسّنة لدعم الرسائل لكل مجموعة
class GroupLoaded extends GroupState {
  final List<GroupModel> groups;
  final Map<String, List<ChatMessage>> groupMessages;

  const GroupLoaded(this.groups, {this.groupMessages = const {}});

  @override
  List<Object?> get props => [groups, groupMessages];
}
