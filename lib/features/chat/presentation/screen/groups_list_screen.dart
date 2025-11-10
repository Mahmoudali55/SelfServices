import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/chat/presentation/cubit/group_cubit.dart';
import 'package:my_template/features/chat/presentation/cubit/group_state.dart';
import 'package:my_template/features/chat/presentation/screen/group_chat_screen.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});
  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<GroupCubit>();
    cubit.listenToGroups();
    cubit.stream.listen((state) {
      if (state is GroupLoaded) {
        for (var group in state.groups) {
          cubit.listenToGroupMessages(group.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(AppLocalKay.groups.tr(), style: const TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) {
          if (state is GroupLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GroupLoaded) {
            final groups = state.groups;
            if (groups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group, size: 100, color: Colors.grey),
                    Text(AppLocalKay.no_groups.tr(), style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final messages = state.groupMessages[group.id] ?? [];
                final lastMessage = messages.isNotEmpty ? messages.last : null;
                String subtitleText = AppLocalKay.no_messages.tr();
                String timeText = '';
                if (lastMessage != null) {
                  final sender = group.members.firstWhere(
                    (m) => m['id'] == lastMessage.senderId,
                    orElse: () => {'name': '${AppLocalKay.user.tr()} ${lastMessage.senderId}'},
                  );
                  final senderName =
                      lastMessage.senderId == context.read<GroupCubit>().currentUserId
                      ? AppLocalKay.me.tr()
                      : sender['name'];
                  subtitleText = '$senderName: ${lastMessage.message ?? ''}';
                  timeText =
                      "${lastMessage.timestamp.hour.toString().padLeft(2, '0')}:${lastMessage.timestamp.minute.toString().padLeft(2, '0')}";
                }
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.group)),
                  title: Text(group.name),
                  subtitle: lastMessage != null
                      ? RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    lastMessage.senderId == context.read<GroupCubit>().currentUserId
                                    ? '${AppLocalKay.me.tr()}: '
                                    : '${group.members.firstWhere((m) => m['id'] == lastMessage.senderId, orElse: () => {'name': '${AppLocalKay.user.tr()} ${lastMessage.senderId}'})['name']}: ',
                                style: AppTextStyle.text16MSecond(
                                  context,
                                  color: AppColor.primaryColor(context),
                                ),
                              ),
                              TextSpan(
                                text: lastMessage.message ?? '',
                                style: AppTextStyle.text14RGrey(context),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          AppLocalKay.no_messages.tr(),
                          style: AppTextStyle.text14RGrey(context),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text(timeText, style: AppTextStyle.text14RGrey(context))],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupChatScreen(groupId: group.id, groupName: group.name),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is GroupError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
