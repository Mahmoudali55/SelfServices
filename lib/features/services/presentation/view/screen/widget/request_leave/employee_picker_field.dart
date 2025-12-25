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
  final int? excludeEmpCode;
  const EmployeePickerField({
    super.key,
    required this.title,
    required this.idController,
    required this.nameController,
    required this.onEmployeeSelected,
    this.validator,
    this.pagePrivID,
    this.empCode,
    this.excludeEmpCode,
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
                validator: (value) => value!.isEmpty ? 'id' : null,
              ),
            ),
            Expanded(
              flex: 4,
              child: CustomFormField(
                controller: nameController,
                readOnly: true,
                hintText: AppLocalKay.employeeName.tr(),
                validator: (value) => value!.isEmpty ? 'id' : null,
                onTap: () => _openEmployeeSearch(context),
                suffixIcon: Icon(Icons.arrow_drop_down),
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

        // تحميل البيانات فقط إذا كانت القائمة فارغة
        if (cubit.state.employeesStatus.data?.isEmpty ?? true) {
          cubit.getEmployees(empcode: empCode ?? 0, privid: pagePrivID ?? 0, refresh: true);
        }

        return BlocProvider.value(
          value: cubit,
          child: SizedBox(
            height: 600,
            child: EmployeeSearchBottomSheetLight(
              onEmployeeSelected: onEmployeeSelected,
              excludeEmpCode: excludeEmpCode,
            ),
          ),
        );
      },
    );
  }
}
