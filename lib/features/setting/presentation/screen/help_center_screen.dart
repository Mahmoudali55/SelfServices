import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/url_launcher_methods%20.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final Map<int, bool> _expanded = {};

  final List<Map<String, String>> _helpOptions = [];

  @override
  void initState() {
    super.initState();
    _helpOptions.addAll([
      {'title': AppLocalKay.helpCenter.tr(), 'content': AppLocalKay.helpdetails.tr()},
      {'title': AppLocalKay.frequentQuestions.tr(), 'content': AppLocalKay.faqdetails.tr()},
      {'title': AppLocalKay.contactUs.tr(), 'content': AppLocalKay.contactSupport.tr()},
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        leading: const BackButton(),
        title: Text(AppLocalKay.helpCenter.tr(), style: AppTextStyle.text18MSecond(context)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: _helpOptions.length,
        itemBuilder: (context, index) {
          final item = _helpOptions[index];
          final isExpanded = _expanded[index] ?? false;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.help_outline, color: AppColor.primaryColor(context)),
                  title: Text(item['title']!, style: AppTextStyle.text16MSecond(context)),
                  trailing: Icon(
                    isExpanded ? Icons.expand_less : Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {
                    setState(() {
                      _expanded[index] = !isExpanded;
                    });
                  },
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: index == _helpOptions.length - 1
                        ? Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.email_outlined),
                                title: const Text('support@myapp.com'),
                                onTap: () =>
                                    UrlLauncherMethods.makeMailMessage('support@myapp.com'),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.phone),
                                title: const Text('+966 50 000 0000'),
                                onTap: () => UrlLauncherMethods.makePhoneCall('+966 50 000 0000'),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.chat),
                                title: Text(AppLocalKay.supportwhatsapp.tr()),
                                onTap: () => UrlLauncherMethods.launchWhatsApp('+966 50 000 0000'),
                              ),
                            ],
                          )
                        : Text(item['content']!, style: AppTextStyle.text16MSecond(context)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
