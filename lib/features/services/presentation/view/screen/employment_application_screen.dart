import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';

class EmploymentApplicationScreen extends StatefulWidget {
  const EmploymentApplicationScreen({super.key});

  @override
  State<EmploymentApplicationScreen> createState() => _EmploymentApplicationScreenState();
}

class _EmploymentApplicationScreenState extends State<EmploymentApplicationScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  DateTime? _startDate;
  String? selectedPlace;
  final List<String> travelPlaces = [AppLocalKay.jobDescription.tr(), AppLocalKay.remoteJob.tr()];

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
      appBar: CustomAppBarServicesWidget(context, title: AppLocalKay.employmentApplication.tr()),
      body: SingleChildScrollView(
        child: Padding(
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

             
             
              CustomFormField(title: AppLocalKay.nunmberemployees.tr()),
              CustomFormField(
                controller: _startDateController,
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
                      _startDate = selectedDate;
                      _startDateController.text = DateFormat(
                        'yyyy-MM-dd',
                        'en',
                      ).format(selectedDate);
                    });
                  }
                },
                title: AppLocalKay.employmentDate.tr(),
                suffixIcon: Icon(Icons.calendar_month, color: AppColor.primaryColor(context)),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      AppLocalKay.requestType.tr(),
                      style: AppTextStyle.formTitleStyle(
                        context,
                        color: AppColor.blackColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ...travelPlaces.map((place) {
                    return Flexible(
                      child: RadioListTile<String>(
                        title: Text(place, textAlign: TextAlign.center),
                        value: place,
                        groupValue: selectedPlace,
                        activeColor: AppColor.primaryColor(context),
                        onChanged: (value) {
                          setState(() {
                            selectedPlace = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  }),
                ],
              ),

              CustomFormField(title: AppLocalKay.reason.tr()),
              CustomFormField(title: AppLocalKay.employmentReason.tr()),
              CustomFormField(title: AppLocalKay.notes.tr()),
            ],
          ),
        ),
      ),
    );
  }
}
