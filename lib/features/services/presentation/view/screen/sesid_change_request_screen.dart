import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';

class SesidChangeRequestScreen extends StatefulWidget {
  const SesidChangeRequestScreen({super.key});

  @override
  State<SesidChangeRequestScreen> createState() => _SesidChangeRequestScreenState();
}

class _SesidChangeRequestScreenState extends State<SesidChangeRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeId = TextEditingController();
  final _newSesid = TextEditingController();
  final _dateController = TextEditingController();
  final _reason = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    String empCode = HiveMethods.getEmpCode() ?? '0';
    _employeeId.text = empCode;
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);

    // جلب معرف الجهاز وملء حقل SESID الجديد
    _getDeviceId().then((id) {
      setState(() {
        _newSesid.text = id;
      });
    });
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? '';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }
    return '';
  }

  void dispose() {
    _employeeId.dispose();
    _newSesid.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarServicesWidget(
        context,
        title: AppLocalKay.changeDevice.tr(),
        helpText: AppLocalKay.sesid_change_help.tr(),
      ),
      bottomNavigationBar: const CustomBottomNavButtonWidget(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomFormField(
                  controller: _employeeId,
                  title: AppLocalKay.empCode.tr(),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'رقم الموظف مطلوب' : null,
                  readOnly: true,
                ),
                CustomFormField(
                  controller: _dateController,
                  readOnly: true,

                  title: AppLocalKay.requestDate.tr(),
                ),
                const SizedBox(height: 16),

                CustomFormField(
                  controller: _newSesid,
                  title: AppLocalKay.newDevice.tr(),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'الـ SESID مطلوب' : null,
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                CustomFormField(
                  controller: _reason,
                  title: AppLocalKay.reason.tr(),
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'السبب مطلوب' : null,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
