import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_type_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class LeaveSelectorDropdown extends StatelessWidget {
  final TextEditingController controller;

  const LeaveSelectorDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        final cubit = context.read<ServicesCubit>();
        final status = state.leavesStatus;

        if (status.isFailure) {
          return Center(child: Text(status.error ?? 'حدث خطأ'));
        }

        final leaves = status.data ?? [];
        VacationTypeModel? selectedLeave;

        // تحديد القيمة الافتراضية
        if (controller.text.isEmpty && leaves.isNotEmpty) {
          // حاول نلاقي العنصر اللي codeGpf == 1
          selectedLeave = leaves.firstWhere(
            (leave) => leave.codeGpf == 1,
            orElse: () => leaves.first,
          );

          // تعيين القيمة الافتراضية للـ controller
          controller.text = selectedLeave.codeGpf.toString();
          cubit.selectLeave(selectedLeave);
        } else {
          // لو في قيمة مسبقة في الـ controller
          final match = leaves.where((leave) => leave.codeGpf.toString() == controller.text);
          if (match.isNotEmpty) {
            selectedLeave = match.first;
          } else if (cubit.selectedLeave != null && leaves.contains(cubit.selectedLeave)) {
            selectedLeave = cubit.selectedLeave;
          } else if (leaves.isNotEmpty) {
            selectedLeave = leaves.first;
            controller.text = selectedLeave.codeGpf.toString();
            cubit.selectLeave(selectedLeave);
          }
        }

        return DropdownButtonFormField<VacationTypeModel>(
          initialValue: selectedLeave,
          isDense: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: leaves
              .map(
                (leave) => DropdownMenuItem<VacationTypeModel>(
                  value: leave,
                  child: Text(
                    context.locale.languageCode == 'en'
                        ? leave.nameGpf ?? ''
                        : leave.nameGpfE ?? '',
                    style: AppTextStyle.text14MPrimary(
                      context,
                      color: AppColor.blackColor(context),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (leave) {
            if (leave != null) {
              cubit.selectLeave(leave);
              controller.text = leave.codeGpf.toString();
            }
          },
        );
      },
    );
  }
}
