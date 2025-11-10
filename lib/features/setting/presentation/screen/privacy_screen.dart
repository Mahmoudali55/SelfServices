import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final List<Map<String, dynamic>> _sections = [
    {
      'keyTitle': AppLocalKay.dataCollection.tr(),
      'keyContent': AppLocalKay.dataCollectionDesc.tr(),
      'icon': Icons.data_usage,
      'color': Colors.blue,
    },
    {
      'keyTitle': AppLocalKay.userRights.tr(),
      'keyContent': AppLocalKay.userRightsDesc.tr(),
      'icon': Icons.person,
      'color': Colors.orange,
    },
    {
      'keyTitle': AppLocalKay.contactPrivacy.tr(),
      'keyContent': AppLocalKay.contactPrivacyDesc.tr(),
      'icon': Icons.contact_mail,
      'color': Colors.green,
    },
    {
      'keyTitle': AppLocalKay.security.tr(),
      'keyContent': AppLocalKay.securityDesc.tr(),
      'icon': Icons.lock,
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.blackColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalKay.privacy.tr(), style: AppTextStyle.text18MSecond(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalKay.privacyIntro.tr(),
              style: AppTextStyle.text16MSecond(context).copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
            ..._sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Colors.grey.withOpacity(0.3),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: section['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(section['icon'], color: section['color']),
                    ),
                    title: Text(section['keyTitle'], style: AppTextStyle.text16MSecond(context)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          section['keyContent'],
                          style: AppTextStyle.text16MSecond(
                            context,
                          ).copyWith(color: Colors.grey[700], height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
