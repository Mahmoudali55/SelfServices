import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/cars/car_type_selector_dropdown_widget.dart';

class CarRequestForm extends StatelessWidget {
  const CarRequestForm({
    super.key,
    required this.formKey,
    required this.dateController,
    required this.carTypeController,
    required this.reasonController,
    required this.noteController,
    required this.requestIdController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController dateController;
  final TextEditingController carTypeController;
  final TextEditingController reasonController;
  final TextEditingController noteController;
  final TextEditingController requestIdController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomFormField(
                  hintText: AppLocalKay.auto.tr(),
                  title: AppLocalKay.requestNumber.tr(),
                  readOnly: true,
                  controller: requestIdController,
                ),
              ),
              const Gap(10),
              Expanded(child: _buildDateField(context)),
            ],
          ),
          Text(
            AppLocalKay.carType.tr(),
            style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
          ),
          CarTypeSelectorDropdown(controller: carTypeController),
          CustomFormField(
            title: AppLocalKay.reason.tr(),
            controller: reasonController,
            validator: (p0) {
              if (p0!.isEmpty) {
                return AppLocalKay.reason.tr();
              }
              return null;
            },
          ),
          CustomFormField(
            title: AppLocalKay.notes.tr(),
            controller: noteController,
            validator: (p0) {
              if (p0!.isEmpty) {
                return AppLocalKay.notes.tr();
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return CustomFormField(
      title: AppLocalKay.requestDate.tr(),
      controller: dateController,
      readOnly: true,
      onTap: () async {
        final today = DateTime.now();
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(today.year, today.month, today.day),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        }
      },
      suffixIcon: Icon(Icons.calendar_month, color: AppColor.primaryColor(context)),
    );
  }
}
