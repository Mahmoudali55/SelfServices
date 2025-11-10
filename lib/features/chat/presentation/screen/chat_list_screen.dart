import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart'
    show CustomFormField;
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/chat/data/model/chat_model.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_state.dart';
import 'package:my_template/features/chat/presentation/screen/chat_screen.dart';
import 'package:my_template/features/chat/presentation/screen/create_group_screen.dart';
import 'package:my_template/features/chat/presentation/screen/groups_list_screen.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class UnifiedEmployeesPage extends StatefulWidget {
  final int currentUserId;
  final int empCode;
  final int pagePrivID;

  const UnifiedEmployeesPage({
    super.key,
    required this.currentUserId,
    required this.empCode,
    required this.pagePrivID,
  });

  @override
  State<UnifiedEmployeesPage> createState() => _UnifiedEmployeesPageState();
}

class _UnifiedEmployeesPageState extends State<UnifiedEmployeesPage> {
  bool isSearching = false;
  String searchText = '';
  TextEditingController searchController = TextEditingController();
  final Set<int> selectedEmployees = {};

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().listenToLastMessages();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = widget.currentUserId;
    final chatCubit = context.read<ChatCubit>();

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90, right: 20),
        child: FloatingActionButton(
          backgroundColor: AppColor.primaryColor(context),
          onPressed: () {
            final serviceState = context.read<ServicesCubit>().state;
            if (serviceState.employeesStatus.isSuccess) {
              final allEmployees = (serviceState.employeesStatus.data ?? [])
                  .where((emp) => emp.empCode != widget.currentUserId)
                  .toList();

              // الموظفين الذين لم يتم محادثتهم
              final chatState = context.read<ChatCubit>().state;
              final nonChattedEmployees = allEmployees
                  .where(
                    (emp) => !chatState.lastMessages.any(
                      (msg) => msg.senderId == emp.empCode || msg.receiverId == emp.empCode,
                    ),
                  )
                  .toList();
              if (nonChattedEmployees.isNotEmpty) {
                _showAllEmployeesBottomSheet(nonChattedEmployees);
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('لا يوجد موظفين لعرضهم')));
              }
            }
          },
          child: const Icon(Icons.add),
        ),
      ),

      appBar: CustomAppBar(
        context,
        title: isSearching
            ? SizedBox(
                height: 40,
                child: TextField(
                  autofocus: true,
                  controller: searchController,
                  onChanged: (val) => setState(() => searchText = val),
                  decoration: InputDecoration(
                    hintText: AppLocalKay.search.tr(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              )
            : Text(
                selectedEmployees.isEmpty
                    ? AppLocalKay.chat.tr()
                    : 'تم تحديد ${selectedEmployees.length}',
                style: AppTextStyle.text18MSecond(context),
              ),
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    searchText = '';
                    searchController.clear();
                  });
                },
              )
            : selectedEmployees.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    selectedEmployees.clear();
                  });
                },
              )
            : const SizedBox(), // بدل null

        actions: [
          if (!isSearching && selectedEmployees.isEmpty) ...[
            IconButton(icon: const Icon(Icons.group), onPressed: _openGroupsPage),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => isSearching = true),
            ),
          ],
          if (selectedEmployees.isNotEmpty)
            IconButton(icon: const Icon(Icons.group_add), onPressed: _onCreateGroup),
        ],
        centerTitle: true,
      ),
      body: BlocBuilder<ServicesCubit, ServicesState>(
        builder: (context, serviceState) {
          if (serviceState.employeesStatus.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (serviceState.employeesStatus.isFailure) {
            return Center(child: Text(serviceState.employeesStatus.error ?? 'حدث خطأ'));
          } else if (serviceState.employeesStatus.isSuccess) {
            final allEmployees = (serviceState.employeesStatus.data ?? [])
                .where((emp) => emp.empCode != widget.currentUserId)
                .toList();

            return BlocBuilder<ChatCubit, ChatState>(
              builder: (context, chatState) {
                // آخر رسالة لكل موظف
                final lastMessageMap = <int, ChatMessage>{};
                for (var msg in chatState.lastMessages) {
                  int otherId = msg.senderId == currentUserId ? msg.receiverId : msg.senderId;
                  if (!lastMessageMap.containsKey(otherId) ||
                      lastMessageMap[otherId]!.timestamp.isBefore(msg.timestamp)) {
                    lastMessageMap[otherId] = msg;
                  }
                }

                final filteredEmployees = allEmployees.where((emp) {
                  return (emp.empName ?? '').toLowerCase().contains(searchText.toLowerCase());
                }).toList();

                // فصل الموظفين اللي لديهم محادثة
                final chattedEmployees = filteredEmployees
                    .where((emp) => lastMessageMap.containsKey(emp.empCode))
                    .toList();
                final nonChattedEmployees = filteredEmployees
                    .where((emp) => !lastMessageMap.containsKey(emp.empCode))
                    .toList();

                return Column(
                  children: [
                    if (nonChattedEmployees.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppImages.assetsGlobalIconEmptyFolderIcon,
                              height: 200,
                              width: 200,
                              color: AppColor.primaryColor(context),
                            ),
                            const Gap(10),
                            Text(AppLocalKay.no_requests.tr()),
                          ],
                        ),
                      ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: chattedEmployees.length,
                        itemBuilder: (context, index) {
                          final emp = chattedEmployees[index];
                          final lastMsg = lastMessageMap[emp.empCode];
                          final isSelected = selectedEmployees.contains(emp.empCode);
                          final unreadCount = chatState.chatMessages
                              .where(
                                (msg) =>
                                    !msg.isRead &&
                                    msg.receiverId == currentUserId &&
                                    msg.senderId == emp.empCode,
                              )
                              .length;

                          return _employeeItem(emp, lastMsg, unreadCount, isSelected);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _employeeItem(dynamic emp, ChatMessage? lastMsg, int unreadCount, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (selectedEmployees.isNotEmpty) {
          _toggleSelect(emp.empCode ?? 0);
        } else {
          context.read<ChatCubit>().setOtherUserId(emp.empCode ?? 0);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                currentUserId: widget.currentUserId,
                otherUserId: emp.empCode ?? 0,
                otherUserName: _cleanName(
                  context.locale == const Locale('ar')
                      ? emp.empName ?? 'الموظف'
                      : emp.empNameE ?? 'الموظف',
                ),
              ),
            ),
          );
        }
      },
      onLongPress: () => _toggleSelect(emp.empCode ?? 0),
      child: Card(
        color: isSelected ? AppColor.primaryColor(context).withOpacity(0.2) : Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColor.primaryColor(context),
                    child: Text(
                      _getInitials(
                        context.locale == const Locale('ar')
                            ? emp.empName ?? 'الموظف'
                            : emp.empNameE ?? '',
                      ),
                      style: AppTextStyle.text16MSecond(context, color: Colors.white),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          '$unreadCount',
                          style: AppTextStyle.text14RGrey(
                            context,
                            color: Colors.white,
                          ).copyWith(fontSize: 12),
                        ),
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check, size: 14, color: AppColor.whiteColor(context)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cleanName(
                        context.locale == const Locale('ar')
                            ? emp.empName ?? 'الموظف'
                            : emp.empNameE ?? 'الموظف',
                      ),
                      style: AppTextStyle.text16MSecond(context),
                    ),
                    if (lastMsg != null)
                      Text(
                        _getLastMessageText(lastMsg),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.text14MPrimary(context),
                      ),
                  ],
                ),
              ),
              if (lastMsg != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    DateFormat('hh:mm a').format(lastMsg.timestamp),
                    style: AppTextStyle.text14RGrey(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSelect(int empCode) {
    setState(() {
      if (selectedEmployees.contains(empCode)) {
        selectedEmployees.remove(empCode);
      } else {
        selectedEmployees.add(empCode);
      }
    });
  }

  void _onCreateGroup() {
    final serviceState = context.read<ServicesCubit>().state;
    if (!serviceState.employeesStatus.isSuccess) return;
    final allEmployees = serviceState.employeesStatus.data ?? [];
    String cleanName(String rawName) {
      return rawName.replaceFirst(RegExp(r'^\d+\s*'), '').trim();
    }

    final List<Map<String, dynamic>> membersWithNames = selectedEmployees.map((id) {
      final emp = allEmployees.firstWhere((e) => e.empCode == id);
      return <String, dynamic>{
        'id': id,
        'name': cleanName(
          context.locale.languageCode == 'ar'
              ? emp.empName ?? 'الموظف'
              : emp.empNameE ?? 'Employee',
        ),
      };
    }).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateGroupScreen(members: membersWithNames.cast<Map<String, dynamic>>()),
      ),
    ).then((_) => setState(() => selectedEmployees.clear()));
  }

  void _openGroupsPage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupsListScreen()));
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'A';
    final words = name.trim().split(' ');
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[1][0]).toUpperCase();
  }

  String _getLastMessageText(ChatMessage msg) {
    if (msg.isDeleted) return AppLocalKay.message_deleted_success.tr();
    switch (msg.type) {
      case MessageType.text:
        return msg.message ?? '';
      case MessageType.image:
        return '${AppLocalKay.image.tr()} 📷';
      case MessageType.file:
        return '${AppLocalKay.file.tr()} 📎 ${msg.fileName ?? ''}';
      case MessageType.audio:
        return '${AppLocalKay.voice.tr()} 🎵 ${msg.fileName ?? ''}';
    }
  }

  String _cleanName(String name) {
    // إزالة أي أرقام في البداية ومسافات زائدة
    return name.replaceFirst(RegExp(r'^\d+\s*'), '').trim();
  }

  String _getInitialss(String name) {
    final cleanName = _cleanName(name);
    if (cleanName.isEmpty) return 'A';
    final words = cleanName.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'A';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  void _showAllEmployeesBottomSheet(List<EmployeeModel> allEmployees) {
    // ترتيب الموظفين حسب EMP_CODE تصاعديًا
    final sortedEmployees = List<EmployeeModel>.from(allEmployees)
      ..sort((a, b) => a.empCode.compareTo(b.empCode));

    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<List<EmployeeModel>> filteredEmployeesNotifier =
        ValueNotifier<List<EmployeeModel>>(List<EmployeeModel>.from(sortedEmployees));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.95,
            initialChildSize: 0.8,
            minChildSize: 0.4,
            builder: (context, scrollController) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    context.locale == const Locale('ar') ? 'قائمة الموظفين' : 'Employee List',
                    style: AppTextStyle.text16MSecond(context),
                  ),
                  const SizedBox(height: 10),
                  CustomFormField(
                    controller: searchController,
                    hintText: context.locale == const Locale('ar')
                        ? 'ابحث عن موظف'
                        : 'Search Employee',
                    onChanged: (val) {
                      final query = val.toLowerCase().trim();
                      filteredEmployeesNotifier.value = sortedEmployees.where((emp) {
                        final empName = _cleanName(emp.empName ?? '').toLowerCase();
                        final empCodeStr = emp.empCode.toString();
                        return empName.contains(query) || empCodeStr.contains(query);
                      }).toList();
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ValueListenableBuilder<List<EmployeeModel>>(
                      valueListenable: filteredEmployeesNotifier,
                      builder: (context, filteredEmployees, _) {
                        if (filteredEmployees.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  AppImages.assetsGlobalIconEmptyFolderIcon,
                                  height: 120.h,
                                  width: 120.w,
                                  color: AppColor.primaryColor(context),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  AppLocalKay.no_results.tr(),
                                  style: AppTextStyle.text16MSecond(context),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final emp = filteredEmployees[index];
                            final empName = _cleanName(emp.empName ?? '');
                            final empNameE = _cleanName(emp.empNameE ?? '');
                            final initials = _getInitialss(
                              context.locale.languageCode == 'ar' ? empName : empNameE ?? '',
                            );

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColor.primaryColor(context),
                                radius: 30,
                                child: Text(initials, style: AppTextStyle.text16MSecond(context, color: AppColor.whiteColor(context))),
                              ),
                              title: Text(
                                context.locale.languageCode == 'ar' ? empName : empNameE,
                                style: AppTextStyle.text16MSecond(context),
                              ),
                              onTap: () {
                                final selectedEmpCode = emp.empCode;
                                final selectedEmpName = empName;

                                Navigator.pop(context);

                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  context.read<ChatCubit>().setOtherUserId(selectedEmpCode);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        currentUserId: widget.currentUserId,
                                        otherUserId: selectedEmpCode,
                                        otherUserName: selectedEmpName,
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
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
  }
}
