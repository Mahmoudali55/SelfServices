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
import 'package:my_template/features/services/data/model/request_leave/employee_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class EmployeeSearchBottomSheetTransfer extends StatefulWidget {
  final Function(EmployeeModel emp) onEmployeeSelected;
  final int currentEmpCode;
  const EmployeeSearchBottomSheetTransfer({
    super.key,
    required this.onEmployeeSelected,
    required this.currentEmpCode,
  });

  @override
  State<EmployeeSearchBottomSheetTransfer> createState() =>
      _EmployeeSearchBottomSheetTransferState();
}

class _EmployeeSearchBottomSheetTransferState extends State<EmployeeSearchBottomSheetTransfer> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        if (state.employeesStatus.isFailure) {
          return Center(child: Text(state.employeesStatus.error ?? 'حدث خطأ'));
        }

        final employees = (state.employeesStatus.data ?? [])
            .where((emp) => emp.empCode == widget.currentEmpCode)
            .toList();

        final filtered = employees.where((emp) {
          final name = (emp.empName ?? '').toLowerCase();
          final code = emp.empCode.toString().toLowerCase();
          return searchQuery.isEmpty ||
              name.contains(searchQuery.toLowerCase()) ||
              code.contains(searchQuery.toLowerCase());
        }).toList();

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // 🔹 العنوان
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    const Spacer(),
                    Text(
                      AppLocalKay.selectEmployee.tr(),
                      style: AppTextStyle.text18MSecond(
                        context,
                        color: AppColor.primaryColor(context),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // 🔹 حقل البحث
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: CustomFormField(
                  prefixIcon: const Icon(Icons.search),
                  hintText: context.locale.languageCode == 'ar'
                      ? 'ابحث بالاسم أو الرقم الوظيفي...'
                      : 'Search by name or employee code...',
                  onChanged: (val) => setState(() => searchQuery = val),
                ),
              ),
              const Gap(10),

              // 🔹 رؤوس الأعمدة
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

              // 🔹 قائمة الموظفين
              Expanded(
                child: state.employeesStatus.data == null
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppImages.assetsGlobalIconEmptyFolderIcon,
                              height: 120,
                              width: 120,
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
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final emp = filtered[index];
                          final displayName = context.locale.languageCode == 'ar'
                              ? emp.empName?.replaceFirst(RegExp(r'^[0-9]+\s*'), '') ?? ''
                              : emp.empNameE?.replaceFirst(RegExp(r'^[0-9]+\s*'), '') ?? '';

                          return ListTile(
                            title: Text(emp.empCode.toString()),
                            trailing: Text(displayName),
                            onTap: () {
                              widget.onEmployeeSelected(emp);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
