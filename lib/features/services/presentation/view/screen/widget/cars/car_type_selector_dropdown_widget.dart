import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/data/model/cars/car_type_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class CarTypeSelectorDropdown extends StatelessWidget {
  final TextEditingController controller;

  const CarTypeSelectorDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        final cubit = context.read<ServicesCubit>();
        final status = state.carTypeStatus;

        if (status.isFailure) {
          return Center(child: Text(status.error ?? 'حدث خطأ'));
        }

        final carTypes = status.data ?? [];
        CarTypeModel? selectedCar;

        // 🔹 لو فيه قيمة محفوظة في الـ controller
        if (controller.text.isNotEmpty) {
          final match = carTypes.where((item) => item.carTypeID.toString() == controller.text);
          if (match.isNotEmpty) {
            selectedCar = match.first;
          }
        }

        // 🔹 لو مفيش قيمة في الكونترولر نستخدم القيمة المختارة في الـCubit أو أول عنصر
        selectedCar ??= cubit.selectedCarType ?? (carTypes.isNotEmpty ? carTypes.first : null);

        // 🔹 نضمن دايمًا مزامنة الكونترولر مع الـ id
        if (selectedCar != null && controller.text != selectedCar.carTypeID.toString()) {
          controller.text = selectedCar.carTypeID.toString();
        }

        return DropdownButtonFormField<CarTypeModel>(
          validator: (value) {
            if (value == null) {
              return AppLocalKay.carType.tr();
            }
            return null;
          },
          initialValue: selectedCar,
          isDense: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: carTypes
              .map(
                (item) => DropdownMenuItem<CarTypeModel>(
                  value: item,
                  child: Text(
                    context.locale.languageCode == 'en' ? item.carTypeNameEng : item.carTypeName,
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
              cubit.selectCarType(item);
              controller.text = item.carTypeID.toString(); // نخزن الـ id
            }
          },
        );
      },
    );
  }
}
