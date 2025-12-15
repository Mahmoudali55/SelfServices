import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/services/services_locator.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/chat/data/repo/chat_repository.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:my_template/features/chat/presentation/screen/chat_list_screen.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/home/presentation/view/screen/home_screen.dart';
import 'package:my_template/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/screen/request_history_screen.dart';
import 'package:my_template/features/setting/presentation/screen/attendance_screen.dart';
import 'package:my_template/features/setting/presentation/screen/more_screen.dart';

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key, this.restoreIndex = 0, this.emd, this.initialType});
  final int? emd;
  final int restoreIndex;
  final String? initialType;

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final String empName = lang == 'ar'
        ? HiveMethods.getEmpNameAR() ?? ''
        : HiveMethods.getEmpNameEn() ?? '';
    final String empCode = HiveMethods.getEmpCode() ?? '0';

    final List<Widget> screens = [
      HomeScreen(name: empName, empId: int.tryParse(empCode) ?? 0),
      RequestHistoryScreen(empCode: int.tryParse(empCode) ?? 0, initialType: initialType),
      BlocProvider(
        create: (_) =>
            ChatCubit(repository: sl<ChatRepository>(), currentUserId: int.tryParse(empCode) ?? 0),
        child: UnifiedEmployeesPage(
          currentUserId: int.tryParse(empCode) ?? 0,
          empCode: int.tryParse(empCode) ?? 0,
          pagePrivID: 1,
        ),
      ),
      const AttendanceScreen(),
      const MoreScreen(),
    ];

    return BlocProvider(
      create: (_) => LayoutCubit()..changePage(restoreIndex),
      child: BlocBuilder<LayoutCubit, LayoutState>(
        builder: (context, state) {
          final cubit = context.read<LayoutCubit>();
          return WillPopScope(
            onWillPop: () async {
              if (cubit.state.currentIndex != 0) {
                cubit.changePage(0);
                return false;
              }

              final shouldExit = await _showExitDialog(context);
              return shouldExit;
            },
            child: Scaffold(
              extendBody: true,
              body: IndexedStack(index: state.currentIndex, children: screens),
              bottomNavigationBar: ConvexAppBar(
                height: 55.h,
                style: TabStyle.react,
                backgroundColor: Colors.white,
                activeColor: AppColor.primaryColor(context),
                color: AppColor.greyColor(context),
                items: [
                  TabItem(icon: Icons.home, title: AppLocalKay.home.tr()),
                  TabItem(icon: Icons.request_quote, title: AppLocalKay.orderhistory.tr()),
                  TabItem(icon: Icons.message, title: AppLocalKay.chat.tr()),
                  TabItem(icon: Icons.fingerprint, title: AppLocalKay.fingerprint.tr()),
                  TabItem(icon: Icons.grid_view, title: AppLocalKay.more.tr()),
                ],
                initialActiveIndex: state.currentIndex,
                onTap: (index) {
                  if (index == cubit.state.currentIndex) {
                    if (index == 0) {
                      context.read<HomeCubit>().loadHomeData();
                    } else if (index == 1) {
                      context.read<VacationRequestsCubit>().getVacationRequests(
                        empcode: int.tryParse(empCode) ?? 0,
                      );
                    }
                  } else {
                    cubit.changePage(index);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(AppLocalKay.exitAppTitle.tr(), style: AppTextStyle.text16MSecond(context)),
            content: Text(
              AppLocalKay.exitAppMessage.tr(),
              style: AppTextStyle.text14RGrey(context),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalKay.no.tr(), style: AppTextStyle.text14RGrey(context)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  AppLocalKay.yes.tr(),
                  style: AppTextStyle.text14RGrey(context, color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
