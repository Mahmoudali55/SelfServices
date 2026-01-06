import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class ResignationForm extends StatelessWidget {
  const ResignationForm({
    super.key,
    required this.formKey,
    required this.dateController,
    required this.lastWorkController,
    required this.notesController,
    required this.requestIdController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController dateController;
  final TextEditingController lastWorkController;
  final TextEditingController notesController;
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
              Gap(10.w),
              Expanded(
                child: _buildDateField(
                  context,
                  dateController,
                  AppLocalKay.requestDate.tr(),
                  (value) => value!.isEmpty ? AppLocalKay.requestDate.tr() : null,
                ),
              ),
            ],
          ),
          _buildDateField(context, lastWorkController, AppLocalKay.trainingDay.tr(), (value) {
            if (value == null || value.isEmpty) {
              return AppLocalKay.trainingDay.tr();
            }

            if (dateController.text.isEmpty) {
              return AppLocalKay.select_request_date_first.tr();
            }

            final requestDate = DateTime.tryParse(dateController.text);
            final lastWorkDate = DateTime.tryParse(value);

            // ❌ لو تاريخ آخر يوم أقل من تاريخ الطلب
            if (lastWorkDate?.isBefore(requestDate ?? DateTime.now()) ?? false) {
              return AppLocalKay.last_work_day_error.tr();
            }

            // ✅ نفس اليوم أو بعده
            return null;
          }),

          CustomFormField(title: AppLocalKay.resignationReason.tr(), controller: notesController),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    TextEditingController controller,
    String title,
    String? Function(String?)? validator,
  ) {
    return CustomFormField(
      title: title,
      controller: controller,
      validator: validator,
      readOnly: true,
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          controller.text = DateFormat('yyyy-MM-dd', 'en').format(selectedDate);
        }
      },
      suffixIcon: Icon(Icons.calendar_month, color: AppColor.primaryColor(context)),
    );
  }
}
