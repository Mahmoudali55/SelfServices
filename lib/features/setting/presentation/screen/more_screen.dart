import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/services/notification_service.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/setting/presentation/screen/rate_app_screen.dart';
import 'package:my_template/features/setting/presentation/screen/suggestions_screen.dart';
import 'package:my_template/features/setting/presentation/screen/widget/show_change_password_sheet_widget.dart';
import 'package:my_template/features/setting/presentation/screen/widget/show_language_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool isNotificationOn = true;
  bool isEmailOn = false;
  String appVersion = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      appVersion = info.version;
      buildNumber = info.buildNumber;
    });
  }

  Future<void> loadVacationAdditionalPrivilages() async {
    final homeCubit = context.read<HomeCubit>();
    final empId = HiveMethods.getEmpCode();
    await homeCubit.loadVacationAdditionalPrivilages(
      pageID: 14,
      empId: int.tryParse(empId.toString()) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColor.whiteColor(context) : AppColor.blackColor(context);

    final homeCubit = context.watch<HomeCubit>();
    final privilegeData = homeCubit.state.vacationStatus.data;
    final pagePrivID = (privilegeData != null) ? privilegeData.pagePrivID : 0;

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Gap(40.h),

          // Account Section
          _sectionTitle(AppLocalKay.account.tr(), textColor),
          _settingCard([
            _listTile(
              icon: Icons.lock_outline,
              color: Colors.orange,
              title: AppLocalKay.changePassword.tr(),
              onTap: () => showChangePasswordSheet(context),
            ),
            _listTile(
              icon: Icons.library_add,
              color: AppColor.primaryColor(context),
              title: AppLocalKay.salaryvocabulary.tr(),
              onTap: () => NavigatorMethods.pushNamed(context, RoutesName.salaryvocabulary),
            ),
            _listTile(
              icon: Icons.timeline,
              color: Colors.teal,
              title: AppLocalKay.timesheet.tr(),
              onTap: () => NavigatorMethods.pushNamed(context, RoutesName.timeSheetScreen),
            ),
            // pagePrivID == 1 || pagePrivID == 2
            //     ? _listTile(
            //         icon: Icons.fingerprint,
            //         color: Colors.teal,
            //         title: 'تسجيل وجوه الموظفين',
            //         onTap: () => NavigatorMethods.pushNamed(
            //           context,
            //           RoutesName.studentFaceRegistrationScreen,
            //         ),
            //       )
            //     : Container(),
            pagePrivID == 1 || pagePrivID == 2
                ? _listTile(
                    icon: Icons.fingerprint,
                    color: Colors.teal,
                    title: AppLocalKay.register_attendance_and_resignation.tr(),
                    onTap: () => NavigatorMethods.pushNamed(
                      context,
                      RoutesName.faceRecognitionAttendanceScreen,
                    ),
                  )
                : Container(),
          ]),

          // Language Section
          _sectionTitle(AppLocalKay.language.tr(), textColor),
          _settingCard([
            _listTile(
              icon: Icons.language,
              color: Colors.deepPurple,
              title: AppLocalKay.changeLanguage.tr(),
              onTap: () => showLanguageSheet(context),
            ),
          ]),

          // Privacy Section
          _sectionTitle(AppLocalKay.privacy.tr(), textColor),
          _settingCard([
            _listTile(
              icon: Icons.privacy_tip_outlined,
              color: Colors.indigo,
              title: AppLocalKay.privacyPolicy.tr(),
              onTap: () => NavigatorMethods.pushNamed(context, RoutesName.privacyScreen),
            ),
          ]),

          // Support Section
          _sectionTitle(AppLocalKay.support.tr(), textColor),
          _settingCard([
            _listTile(
              icon: Icons.help_outline,
              color: Colors.blueGrey,
              title: AppLocalKay.helpCenter.tr(),
              onTap: () => NavigatorMethods.pushNamed(context, RoutesName.helpCenterScreen),
            ),
            _listTile(
              icon: Icons.chat_bubble_outline,
              color: Colors.teal,
              title: AppLocalKay.inquiries.tr(),
              onTap: () => NavigatorMethods.pushNamed(context, RoutesName.chatBotScreen),
            ),
            _listTile(
              icon: Icons.star_border_outlined,
              color: Colors.yellow,
              title: AppLocalKay.rate_app.tr(),
              onTap: () => showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: AppColor.whiteColor(context, listen: false),
                elevation: 0,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                context: context,
                builder: (context) => SizedBox(height: 400.h, child: const RateAppScreen()),
              ),
            ),
            _listTile(
              icon: Icons.question_answer_outlined,
              color: Colors.purple,
              title: AppLocalKay.suggestions.tr(),
              onTap: () => showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: AppColor.whiteColor(context, listen: false),
                elevation: 0,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                context: context,
                builder: (context) => SizedBox(height: 400.h, child: const SuggestionsScreen()),
              ),
            ),
          ]),

          // App Info Section
          _sectionTitle(AppLocalKay.AppInfo.tr(), textColor),
          _settingCard([
            ListTile(
              leading: _circleIcon(Icons.info_outline, Colors.blue),
              title: Text(
                AppLocalKay.AppVersion.tr(),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(appVersion),
            ),
            ListTile(
              leading: _circleIcon(Icons.copyright, Colors.grey),
              title: Text(
                AppLocalKay.copyright.tr(),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              ),
            ),
          ]),

          Gap(20.h),

          // Logout Section
          _settingCard([
            _listTile(
              icon: Icons.logout,
              color: Colors.redAccent,
              title: AppLocalKay.logout.tr(),
              textColor: Colors.red,
              onTap: () => _logoutDialog(context),
            ),
          ]),

          Gap(MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(title, style: AppTextStyle.text16MSecond(context).copyWith(color: textColor)),
  );

  Widget _settingCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: AppColor.whiteColor(context),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
      ],
    ),
    child: Column(children: children),
  );

  Widget _listTile({
    required IconData icon,
    required Color color,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: _circleIcon(icon, color),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColor.blackColor(context),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _circleIcon(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
    child: Icon(icon, color: color, size: 20),
  );

  Future<void> _logoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalKay.logout.tr()),
        content: Text(AppLocalKay.areYouSureToLogout.tr()),
        actions: [
          TextButton(
            child: Text(AppLocalKay.cancel.tr()),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalKay.logout.tr()),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    // Get empCode before clearing data
    final empCodeStr = HiveMethods.getEmpCode();
    if (empCodeStr != null) {
      final empCode = int.tryParse(empCodeStr);
      if (empCode != null) {
        // Remove FCM token from Firestore
        await NotificationService.removeTokenFromFirestore(empCode);
      }
    }

    // Clear all user data (token, names, password, device info, etc.)
    await HiveMethods.clearAllUserData();
    await NotificationService.stopListening();

    if (!context.mounted) return;

    CommonMethods.showToast(
      message: AppLocalKay.logout_successful_message.tr(),
      type: ToastType.success,
    );

    Navigator.of(context).pushNamedAndRemoveUntil(RoutesName.loginScreen, (route) => false);
  }
}
