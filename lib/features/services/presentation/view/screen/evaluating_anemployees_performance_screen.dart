import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';

class EvaluatingAnemployeesPerformanceScreen extends StatefulWidget {
  const EvaluatingAnemployeesPerformanceScreen({super.key});

  @override
  State<EvaluatingAnemployeesPerformanceScreen> createState() =>
      _EvaluatingAnemployeesPerformanceScreenState();
}

class _EvaluatingAnemployeesPerformanceScreenState
    extends State<EvaluatingAnemployeesPerformanceScreen> {
  @override
  final TextEditingController _dateController = TextEditingController();

  final TextEditingController _performanceEvaluationFromDateController = TextEditingController();
  final TextEditingController _performanceEvaluationToDateController = TextEditingController();
  DateTime? __performanceEvaluationfromtoDate;
  DateTime? _performanceEvaluationtoDate;

  String? selectedPlace;
  final List<String> travelPlaces = [
    AppLocalKay.employeesName.tr(),
    AppLocalKay.traineesName.tr(),
    AppLocalKay.trialName.tr(),
  ];

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
      appBar: CustomAppBarServicesWidget(context, title: AppLocalKay.performanceEvaluation.tr()),
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
              Row(
                children: [
                  Expanded(
                    child: CustomFormField(
                      controller: _performanceEvaluationFromDateController,
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
                            __performanceEvaluationfromtoDate = selectedDate;
                            _performanceEvaluationFromDateController.text = DateFormat(
                              'yyyy-MM-dd',
                              'en',
                            ).format(selectedDate);
                          });
                        }
                      },
                      title: AppLocalKay.performanceEvaluationFrom.tr(),
                      suffixIcon: Icon(Icons.calendar_month, color: AppColor.primaryColor(context)),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: CustomFormField(
                      controller: _performanceEvaluationToDateController,
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
                            _performanceEvaluationtoDate = selectedDate;
                            _performanceEvaluationToDateController.text = DateFormat(
                              'yyyy-MM-dd',
                              'en',
                            ).format(selectedDate);
                          });
                        }
                      },
                      title: AppLocalKay.performanceEvaluationTo.tr(),
                      suffixIcon: Icon(Icons.calendar_month, color: AppColor.primaryColor(context)),
                    ),
                  ),
                ],
              ),
              Text(
                AppLocalKay.type.tr(),
                style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 5),
                  ...travelPlaces.map((place) {
                    return Flexible(
                      child: RadioListTile<String>(
                        title: Text(place),
                        value: place,
                        groupValue: selectedPlace,
                        activeColor: AppColor.primaryColor(context),
                        onChanged: (value) {
                          setState(() {
                            selectedPlace = value;
                          });
                        },
                        contentPadding: const EdgeInsets.all(0),
                      ),
                    );
                  }),
                ],
              ),
              CustomFormField(title: AppLocalKay.performanceEvaluationDescription.tr()),
              CustomFormField(title: AppLocalKay.management.tr()),
              CustomFormField(title: AppLocalKay.department.tr()),
              CustomFormField(title: AppLocalKay.job.tr()),
              CustomFormField(title: AppLocalKay.assignmentDate.tr()),
              CustomFormField(title: AppLocalKay.performanceEvaluationItems.tr()),
              Row(
                children: [
                  Expanded(child: CustomFormField(title: AppLocalKay.finalDegree.tr())),
                  const Gap(10),
                  Expanded(child: CustomFormField(title: AppLocalKay.evaluationDegree.tr())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
