import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.blackColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalKay.security.tr(), style: AppTextStyle.text18MSecond(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalKay.securityIntro.tr(),
            style: AppTextStyle.text16MSecond(context).copyWith(height: 1.5),
          ),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: SwitchListTile(
              title: Text(AppLocalKay.twoFactorAuth.tr()),
              subtitle: Text(AppLocalKay.twoFactorAuthDesc.tr()),
              value: true,
              onChanged: (val) {},
              secondary: const Icon(Icons.verified_user, color: Colors.purple),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.devices, color: Colors.blue),
              title: Text(AppLocalKay.manageDevices.tr()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                AppLocalKay.logoutAllDevices.tr(),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
