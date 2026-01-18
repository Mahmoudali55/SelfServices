import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class CustomSolfeAllEmployeeWidgetLight extends StatelessWidget {
  const CustomSolfeAllEmployeeWidgetLight({
    super.key,
    required this.context,
    required this.empIdController,
    required this.empNameController,
  });

  final BuildContext context;
  final TextEditingController empIdController;
  final TextEditingController empNameController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ServicesCubit>(),
      child: SizedBox(
        height: 600,
        child: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            if (state.employeeListStatus.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.employeeListStatus.isFailure) {
              return Center(
                child: Text(state.employeeListStatus.error ?? AppLocalKay.generic_error.tr()),
              );
            }

            final employees = state.employeeListStatus.data ?? [];
            String searchQuery = '';

            return StatefulBuilder(
              builder: (context, setState) {
                final filtered = employees.where((emp) {
                  final name = (emp.empName).toLowerCase();
                  return searchQuery.isEmpty || name.contains(searchQuery.toLowerCase());
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
                              AppLocalKay.selectcollateral.tr(),
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
                        hintText: context.locale.languageCode == 'en'
                            ? AppLocalKay.search_by_name.tr()
                            : AppLocalKay.search_by_name.tr(),
                        onChanged: (val) => setState(() => searchQuery = val),
                      ),
                    ),
                    const Gap(10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Text(
                            AppLocalKay.empCode.tr(),
                            style: AppTextStyle.text16MSecond(
                              context,
                              color: AppColor.blackColor(context),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppLocalKay.employeeName.tr(),
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
                              child: Text(
                                AppLocalKay.noResults.tr(),
                                style: AppTextStyle.text16MSecond(
                                  context,
                                  color: AppColor.blackColor(context),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final emp = filtered[index];
                                final displayName = context.locale.languageCode == 'en'
                                    ? emp.empName.replaceFirst(RegExp(r'^[0-9]+\s*'), '')
                                    : emp.empNameE.replaceFirst(RegExp(r'^[0-9]+\s*'), '');
                                return ListTile(
                                  trailing: Text(displayName),
                                  title: Text(emp.empCode.toString()),
                                  onTap: () {
                                    empIdController.text = emp.empCode.toString();
                                    empNameController.text = displayName;
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
