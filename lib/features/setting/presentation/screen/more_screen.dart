import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/setting/presentation/screen/rate_app_screen.dart';
import 'package:my_template/features/setting/presentation/screen/suggestions_screen.dart';
import 'package:my_template/features/setting/presentation/screen/widget/show_change_password_sheet_widget.dart';
import 'package:my_template/features/setting/presentation/screen/widget/show_language_sheet.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool isNotificationOn = true;
  bool isEmailOn = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColor.whiteColor(context) : AppColor.blackColor(context);

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Gap(40.h),

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
          ]),
          _sectionTitle(AppLocalKay.language.tr(), textColor),
          _settingCard([
            _listTile(
              icon: Icons.language,
              color: Colors.deepPurple,
              title: AppLocalKay.changeLanguage.tr(),
              onTap: () => showLanguageSheet(context),
            ),
          ]),
          _sectionTitle(AppLocalKay.privacy.tr(), textColor),
          _settingCard([
            _listTile(
              icon: Icons.privacy_tip_outlined,
              color: Colors.indigo,
              title: AppLocalKay.privacyPolicy.tr(),
              onTap: () => NavigatorMethods.pushNamed(context, RoutesName.privacyScreen),
            ),
          ]),

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
                elevation: 5,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),

                context: context,
                builder: (context) => const RateAppScreen(),
              ),
            ),

            _listTile(
              icon: Icons.question_answer_outlined,
              color: Colors.purple,
              title: AppLocalKay.suggestions.tr(),
              onTap: () => showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: AppColor.whiteColor(context, listen: false),
                elevation: 5,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                context: context,
                builder: (context) => const SuggestionsScreen(),
              ),
            ),
          ]),
          Gap(20.h),
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
      color: Colors.white,
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

  Widget _switchTile({
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: _circleIcon(icon, color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
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

    if (shouldLogout ?? false) {
      await HiveMethods.deleteEmpCode();
      await HiveMethods.deleteToken();
      final empId = HiveMethods.getEmpCode();
      await HiveMethods.deleteBoxFromDisk('chat_messages_$empId');
      if (!context.mounted) return;

      CommonMethods.showToast(
        message: context.locale.languageCode == 'ar'
            ? 'تم تسجيل الخروج بنجاح'
            : 'Logout successful',
        type: ToastType.success,
      );

      Navigator.of(context).pushNamedAndRemoveUntil(RoutesName.loginScreen, (route) => false);
    }
  }
}
