import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class HousingAllowanceForm extends StatelessWidget {
  const HousingAllowanceForm({
    super.key,
    required this.formKey,
    required this.dateController,
    required this.noteController,
    required this.amountController,
    required this.requestIdController,
    required this.travelPlaceValues,
    required this.selectedPlace,
    required this.onPlaceChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController dateController;
  final TextEditingController noteController;
  final TextEditingController amountController;
  final TextEditingController requestIdController;
  final Map<String, int> travelPlaceValues;
  final String? selectedPlace;
  final ValueChanged<String?> onPlaceChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: CustomFormField(
                  hintText: context.locale.languageCode == 'ar' ? 'تلقائي' : 'Auto',
                  title: AppLocalKay.requestNumber.tr(),
                  readOnly: true,
                  controller: requestIdController,
                ),
              ),
              Expanded(child: _buildDateField(context)),
            ],
          ),
          CustomFormField(
            title: AppLocalKay.vacationAmount.tr(),
            controller: amountController,
            validator: (value) => value!.isEmpty ? AppLocalKay.pleaseEnterAmount.tr() : null,
          ),
          Text(
            AppLocalKay.vacationPeriod.tr(),
            style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
          ),
          Row(
            children: travelPlaceValues.keys.map((place) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(place, textAlign: TextAlign.center),
                  value: place,
                  groupValue: selectedPlace,
                  activeColor: AppColor.primaryColor(context),
                  onChanged: onPlaceChanged,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
          CustomFormField(title: AppLocalKay.reason.tr(), controller: noteController),
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
