import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/data/model/transfer/department_data_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class CustomDepartmentPickerWidget extends StatelessWidget {
  const CustomDepartmentPickerWidget({
    super.key,
    required this.context,
    required this.departmentIdController,
    required this.departmentNameController,
    this.onDepartmentSelected,
  });

  final BuildContext context;
  final TextEditingController departmentIdController;
  final TextEditingController departmentNameController;
  final void Function(DepartmentModel)? onDepartmentSelected; // ✅ callback

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ServicesCubit>();
    // تحميل البيانات فقط إذا كانت القائمة فارغة
    if (cubit.state.departmentStatus.data?.isEmpty ?? true) {
      cubit.getDepartmentData();
    }

    return BlocProvider.value(
      value: cubit,
      child: SizedBox(
        height: 600,
        child: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            if (state.departmentStatus.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.departmentStatus.isFailure) {
              return Center(child: Text(state.departmentStatus.error ?? 'حدث خطأ'));
            }

            final departments = state.departmentStatus.data ?? <DepartmentModel>[];
            String searchQuery = '';

            return StatefulBuilder(
              builder: (context, setState) {
                final filtered = departments.where((dep) {
                  final name = dep.dName.toLowerCase();
                  final nameE = (dep.dNameE ?? '').toLowerCase();
                  return searchQuery.isEmpty ||
                      name.contains(searchQuery.toLowerCase()) ||
                      nameE.contains(searchQuery.toLowerCase());
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                          const Spacer(),
                          Center(
                            child: Text(
                              AppLocalKay.selectDepartment.tr(),
                              style: AppTextStyle.text18MSecond(
                                context,
                                color: AppColor.primaryColor(context),
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CustomFormField(
                        prefixIcon: const Icon(Icons.search),
                        hintText: AppLocalKay.search_by_department_name.tr(),
                        onChanged: (val) => setState(() => searchQuery = val),
                      ),
                    ),
                    const Gap(10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Text(
                            AppLocalKay.departmentCode.tr(),
                            style: AppTextStyle.text16MSecond(
                              context,
                              color: AppColor.blackColor(context),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppLocalKay.departmentName.tr(),
                            style: AppTextStyle.text16MSecond(
                              context,
                              color: AppColor.blackColor(context),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AppImages.assetsGlobalIconEmptyFolderIcon,
                                    height: 100,
                                    width: 100,
                                    color: AppColor.primaryColor(context),
                                  ),
                                  const Gap(20),
                                  Text(
                                    AppLocalKay.noResults.tr(),
                                    style: AppTextStyle.text16MSecond(
                                      context,
                                      color: AppColor.blackColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final dep = filtered[index];
                                final displayName = context.locale.languageCode == 'en'
                                    ? dep.dName
                                    : (dep.dNameE ?? dep.dName);
                                return ListTile(
                                  title: Text(dep.dCode.toString()),
                                  trailing: Text(
                                    displayName,
                                    style: AppTextStyle.text16MSecond(
                                      context,
                                      color: AppColor.blackColor(context),
                                    ),
                                  ),
                                  onTap: () {
                                    departmentIdController.text = dep.dCode.toString();
                                    departmentNameController.text = displayName;

                                    if (onDepartmentSelected != null) {
                                      onDepartmentSelected!(dep);
                                    }

                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
