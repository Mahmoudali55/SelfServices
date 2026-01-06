import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/data/model/solfa_request/solfa_request_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class SolfaSelectorDropdown extends StatelessWidget {
  final TextEditingController controller;

  const SolfaSelectorDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        final cubit = context.read<ServicesCubit>();
        final status = state.solfaStatus;

        if (status.isFailure) {
          return Center(child: Text(status.error ?? AppLocalKay.generic_error.tr()));
        }

        final lones = status.data ?? [];
        SolfaTypeModel? selectedLone;

        if (controller.text.isNotEmpty) {
          final match = lones.where((item) => item.paCode.toString() == controller.text);
          if (match.isNotEmpty) {
            selectedLone = match.first;
          }
        }

        // لو ما فيش حاجة متسجلة في الكونترولر
        selectedLone ??= cubit.selectedSolfaType ?? (lones.isNotEmpty ? lones.first : null);

        // 👇 هنا نضمن دايمًا ان الكونترولر يحتوي الـ paCode
        if (selectedLone != null && controller.text != selectedLone.paCode.toString()) {
          controller.text = selectedLone.paCode.toString();
        }

        return DropdownButtonFormField<SolfaTypeModel>(
          initialValue: selectedLone,
          isDense: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: lones
              .map(
                (item) => DropdownMenuItem<SolfaTypeModel>(
                  value: item,
                  child: Text(
                    context.locale.languageCode == 'en' ? item.paNameE ?? item.paName : item.paName,
                    style: AppTextStyle.text14MPrimary(
                      context,
                      color: AppColor.blackColor(context),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (item) {
            if (item != null) {
              cubit.selectSolfaType(item);
              controller.text = item.paCode.toString(); // دايمًا نخزن الـ id
            }
          },
        );
      },
    );
  }
}
