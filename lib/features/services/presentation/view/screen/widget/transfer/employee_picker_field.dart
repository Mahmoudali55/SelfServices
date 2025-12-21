import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/transfer/employee_search_bottom_sheet_light.dart';

class EmployeePickerTransferField extends StatelessWidget {
  final String title;
  final TextEditingController idController;
  final TextEditingController nameController;
  final Function(dynamic emp) onEmployeeSelected;
  final String? Function(String?)? validator;
  final int currentEmpCode;
  const EmployeePickerTransferField({
    super.key,
    required this.title,
    required this.idController,
    required this.nameController,
    required this.onEmployeeSelected,
    this.validator,
    required this.currentEmpCode,
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
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
            ),
            Expanded(
              flex: 4,
              child: CustomFormField(
                controller: nameController,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
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
        return BlocProvider.value(
          value: context.read<ServicesCubit>(),
          child: SizedBox(
            height: 600,
            child: EmployeeSearchBottomSheetTransfer(
              onEmployeeSelected: onEmployeeSelected,
              currentEmpCode: currentEmpCode,
            ),
          ),
        );
      },
    );
  }
}
