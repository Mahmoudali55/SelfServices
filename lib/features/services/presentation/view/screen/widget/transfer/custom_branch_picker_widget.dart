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
import 'package:my_template/features/services/data/model/transfer/branch_data_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class CustomBranchPickerWidget extends StatelessWidget {
  const CustomBranchPickerWidget({
    super.key,
    required this.context,
    required this.branchIdController,
    required this.branchNameController,
    this.onBranchSelected,
  });

  final BuildContext context;
  final TextEditingController branchIdController;
  final TextEditingController branchNameController;
  final void Function(BranchDataModel)? onBranchSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ServicesCubit>(),
      child: SizedBox(
        height: 600,
        child: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            if (state.branchStatus.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.branchStatus.isFailure) {
              return Center(child: Text(state.branchStatus.error ?? 'حدث خطأ'));
            }

            final branches = state.branchStatus.data ?? <BranchDataModel>[];
            String searchQuery = '';

            return StatefulBuilder(
              builder: (context, setState) {
                final filtered = branches.where((branch) {
                  final name = branch.bName.toLowerCase();
                  final code = branch.bCode.toString();
                  return searchQuery.isEmpty ||
                      name.contains(searchQuery.toLowerCase()) ||
                      code.contains(searchQuery);
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
                              AppLocalKay.selectBranch.tr(),
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
                    // ======= مربع البحث =======
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CustomFormField(
                        prefixIcon: const Icon(Icons.search),
                        hintText: AppLocalKay.search_by_branch_name_or_code.tr(),
                        onChanged: (val) => setState(() => searchQuery = val),
                      ),
                    ),
                    const Gap(10),
                    // ======= عناوين الأعمدة =======
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Text(
                            AppLocalKay.branchId.tr(),
                            style: AppTextStyle.text16MSecond(
                              context,
                              color: AppColor.blackColor(context),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppLocalKay.branchName.tr(),
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
                    // ======= القائمة =======
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
                                final branch = filtered[index];
                                return ListTile(
                                  title: Text(branch.bCode.toString()),
                                  trailing: Text(
                                    context.locale.languageCode == 'en'
                                        ? branch.bName
                                        : branch.bNameE ?? '',
                                    style: AppTextStyle.text16MSecond(
                                      context,
                                      color: AppColor.blackColor(context),
                                    ),
                                  ),
                                  onTap: () {
                                    branchIdController.text = branch.bCode.toString();
                                    branchNameController.text = context.locale.languageCode == 'en'
                                        ? branch.bName
                                        : branch.bNameE ?? '';

                                    if (onBranchSelected != null) {
                                      onBranchSelected!(branch);
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
