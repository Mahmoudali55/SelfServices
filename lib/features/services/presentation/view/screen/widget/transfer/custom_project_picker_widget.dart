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
import 'package:my_template/features/services/data/model/transfer/projects_data_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class CustomProjectPickerWidget extends StatelessWidget {
  const CustomProjectPickerWidget({
    super.key,
    required this.context,
    required this.projectIdController,
    required this.projectNameController,
    this.onProjectSelected,
  });

  final BuildContext context;
  final TextEditingController projectIdController;
  final TextEditingController projectNameController;
  final void Function(ProjectsDataModel)? onProjectSelected;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ServicesCubit>();
    // تحميل البيانات فقط إذا كانت القائمة فارغة
    if (cubit.state.projectStatus.data?.isEmpty ?? true) {
      cubit.getProjectData();
    }

    return BlocProvider.value(
      value: cubit,
      child: SizedBox(
        height: 600,
        child: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            if (state.projectStatus.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.projectStatus.isFailure) {
              return Center(child: Text(state.projectStatus.error ?? 'حدث خطأ'));
            }

            final projects = state.projectStatus.data ?? <ProjectsDataModel>[];
            String searchQuery = '';

            return StatefulBuilder(
              builder: (context, setState) {
                final filtered = projects.where((proj) {
                  final name = proj.projectName.toLowerCase();
                  final nameEng = (proj.projectNameEng ?? '').toLowerCase();
                  return searchQuery.isEmpty ||
                      name.contains(searchQuery.toLowerCase()) ||
                      nameEng.contains(searchQuery.toLowerCase());
                }).toList();

                return Column(
                  children: [
                    // ======= العنوان =======
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
                              AppLocalKay.selectProject.tr(),
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
                        hintText: AppLocalKay.search_by_project_name.tr(),
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
                            AppLocalKay.projectId.tr(),
                            style: AppTextStyle.text16MSecond(
                              context,
                              color: AppColor.blackColor(context),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppLocalKay.projectName.tr(),
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
                                final proj = filtered[index];
                                final displayName = context.locale.languageCode == 'en'
                                    ? proj.projectName
                                    : (proj.projectNameEng ?? '-');
                                return ListTile(
                                  title: Text(proj.projectId.toString()),
                                  trailing: Text(
                                    displayName,
                                    style: AppTextStyle.text16MSecond(
                                      context,
                                      color: AppColor.blackColor(context),
                                    ),
                                  ),
                                  onTap: () {
                                    projectIdController.text = proj.projectId.toString();
                                    projectNameController.text = displayName;

                                    if (onProjectSelected != null) {
                                      onProjectSelected!(proj);
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
