import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/chat/presentation/cubit/group_cubit.dart';
import 'package:my_template/features/chat/presentation/cubit/group_state.dart';

class CreateGroupScreen extends StatefulWidget {
  final List<Map<String, dynamic>> members; // id + name

  const CreateGroupScreen({super.key, required this.members});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    context.read<GroupCubit>().listenToGroups();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(AppLocalKay.create_group.tr(), style: AppTextStyle.text18MSecond(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<GroupCubit, GroupState>(
          listener: (context, state) {
            if (state is GroupCreated) {
              Navigator.pop(context, state.groupId);
            } else if (state is GroupError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final isLoading = state is GroupLoading;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomFormField(controller: _controller, hintText: AppLocalKay.group_name.tr()),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final name = _controller.text.trim();
                          if (name.isEmpty) return;

                          context.read<GroupCubit>().createGroup(
                            name: name,
                            members: widget.members,
                            adminname: context.locale.languageCode == 'en'
                                ? HiveMethods.getEmpNameEn() ?? ''
                                : HiveMethods.getEmpNameAR() ?? '',
                          );
                        },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          AppLocalKay.create.tr(),
                          style: AppTextStyle.text18MSecond(context, color: Colors.white),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
