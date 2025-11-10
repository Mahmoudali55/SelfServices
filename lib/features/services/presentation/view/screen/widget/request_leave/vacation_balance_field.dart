import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/data/model/request_leave/Employee_bal_model.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_vacation_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class VacationBalanceField extends StatelessWidget {
  final TextEditingController controller;
  final bool isBall;
  final String? Function(String?)? validator;

  const VacationBalanceField({
    super.key,
    required this.controller,
    required this.isBall,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicesCubit, ServicesState>(
      listenWhen: (previous, current) {
        if (isBall) {
          return previous.employeeBalStatus != current.employeeBalStatus;
        } else {
          return previous.employeeVacationsStatus != current.employeeVacationsStatus;
        }
      },
      listener: (context, state) {
        if (isBall && state.employeeBalStatus.isSuccess && state.employeeBalStatus.data != null) {
          final List<EmployeeBalModel> data = state.employeeBalStatus.data!;
          final total = data.fold<double>(0.0, (sum, e) => sum + (e.column1 ?? 0));
          controller.text = total.toString();
        } else if (!isBall &&
            state.employeeVacationsStatus.isSuccess &&
            state.employeeVacationsStatus.data != null) {
          final List<EmployeeVacationModel> data = state.employeeVacationsStatus.data!;
          final total = data.fold<double>(0.0, (sum, e) => sum + (e.empVacBal ?? 0));
          controller.text = total.toString();
        }
      },
      child: CustomFormField(
        validator: validator,
        readOnly: true,
        controller: controller,
        title: isBall ? AppLocalKay.leaveAmount.tr() : AppLocalKay.balance.tr(),
        hintText: '-',
      ),
    );
  }
}
