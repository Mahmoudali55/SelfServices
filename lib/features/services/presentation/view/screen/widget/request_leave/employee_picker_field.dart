import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/employee_search_bottom_sheet.dart';

class EmployeePickerField extends StatelessWidget {
  final String title;
  final TextEditingController idController;
  final TextEditingController nameController;
  final Function(dynamic emp) onEmployeeSelected;
  final int? pagePrivID;
  final int? empCode;
  final String? Function(String?)? validator;

  const EmployeePickerField({
    super.key,
    required this.title,
    required this.idController,
    required this.nameController,
    required this.onEmployeeSelected,
    this.validator,
    this.pagePrivID,
    this.empCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              flex: 1,
              child: CustomFormField(
                controller: idController,
                readOnly: true,
                hintText: 'ID ',
                validator: validator,
              ),
            ),
            Expanded(
              flex: 4,
              child: CustomFormField(
                controller: nameController,
                readOnly: true,
                hintText: AppLocalKay.employeeName.tr(),
                validator: validator,
              ),
            ),
            GestureDetector(
              onTap: () => _openEmployeeSearch(context),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.search, color: AppColor.whiteColor(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openEmployeeSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final cubit = context.read<ServicesCubit>();

        cubit.getEmployees(empcode: empCode ?? 0, privid: pagePrivID ?? 0, refresh: true);

        return BlocProvider.value(
          value: cubit,
          child: SizedBox(
            height: 600,
            child: EmployeeSearchBottomSheetLight(onEmployeeSelected: onEmployeeSelected),
          ),
        );
      },
    );
  }
}
