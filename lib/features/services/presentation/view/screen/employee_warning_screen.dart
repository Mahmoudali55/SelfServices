import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';

class EmployeeWarningScreen extends StatefulWidget {
  const EmployeeWarningScreen({super.key});

  @override
  State<EmployeeWarningScreen> createState() => _EmployeeWarningScreenState();
}

class _EmployeeWarningScreenState extends State<EmployeeWarningScreen> {
  @override
  final TextEditingController _dateController = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavButtonWidget(),
      appBar: CustomAppBarServicesWidget(context, title: AppLocalKay.employeewarning.tr()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: CustomFormField(title: AppLocalKay.requestNumber.tr(), readOnly: true),
                ),
                Expanded(
                  child: CustomFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _dateController.text = DateFormat(
                            'yyyy-MM-dd',
                            'en',
                          ).format(selectedDate);
                        });
                      }
                    },
                    title: AppLocalKay.requestDate.tr(),
                    suffixIcon: Icon(Icons.calendar_month, color: AppColor.primaryColor(context)),
                  ),
                ),
              ],
            ),
            CustomFormField(title: AppLocalKay.employee.tr()),
            CustomFormField(title: AppLocalKay.employeewarningreason.tr()),
            CustomFormField(title: AppLocalKay.employeewarningdescription.tr()),
            CustomFormField(title: AppLocalKay.notes.tr()),
          ],
        ),
      ),
    );
  }
}
