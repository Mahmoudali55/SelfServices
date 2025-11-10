import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_loading/custom_shimmer.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/auth/presentation/view/screen/widget/custom_name_and_job_widget.dart';
import 'package:my_template/features/profile/presentation/cubit/prefile_cubit.dart';
import 'package:my_template/features/profile/presentation/cubit/profile_state.dart';
import 'package:my_template/features/profile/presentation/view/screen/widget/custom_tittel_and_subTittel_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showMore = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor(context),
      appBar: CustomAppBar(
        appBarColor: AppColor.whiteColor(context),
        leading: const BackButton(),
        context,
        title: Text(AppLocalKay.viewprofile.tr(), style: AppTextStyle.text18MSecond(context)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<PrefileCubit, ProfileState>(
          builder: (context, state) {
            if (state.profileStatus.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CustomShimmer(height: 100, width: 100, radius: 60),
                        Gap(8),
                        CustomShimmer(height: 25, width: 200),
                        Gap(8),
                        CustomShimmer(height: 25, width: 150),
                        Gap(24),
                        CustomShimmer(height: 500),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (state.profileStatus.isFailure) {
              return Center(child: Text(state.profileStatus.message ?? ''));
            }
            final profile = state.profileStatus.data ?? [];
            return ListView.builder(
              itemCount: profile.length,
              itemBuilder: (context, index) {
                final item = profile[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomNameAndJobWidget(item: item),
                      const Gap(24),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              CustomTittelAndSubTittelWidget(
                                icon: Icons.email,
                                title: AppLocalKay.email.tr(),
                                value: item.emailAddress ?? '',
                              ),
                              const Divider(),
                              CustomTittelAndSubTittelWidget(
                                icon: Icons.credit_card,
                                title: AppLocalKay.idNumber.tr(),
                                value: item.cardNumber,
                              ),
                              const Divider(),
                              CustomTittelAndSubTittelWidget(
                                icon: Icons.flag,
                                title: AppLocalKay.nationality.tr(),
                                value: context.locale.languageCode == 'ar'
                                    ? item.natName
                                    : item.natNameEng,
                              ),
                              const Divider(),
                              CustomTittelAndSubTittelWidget(
                                icon: Icons.date_range,
                                title: AppLocalKay.hireDate.tr(),
                                value: item.empHireDate,
                              ),
                              const Divider(),
                              CustomTittelAndSubTittelWidget(
                                icon: Icons.manage_accounts,
                                title: AppLocalKay.management.tr(),
                                value: context.locale.languageCode == 'ar'
                                    ? item.dName
                                    : item.dNameE,
                              ),
                              if (_showMore) ...[
                                const Divider(),
                                CustomTittelAndSubTittelWidget(
                                  icon: Icons.flight,
                                  title: AppLocalKay.passportNumber.tr(),
                                  value: item.passNo,
                                ),
                                const Divider(),
                                CustomTittelAndSubTittelWidget(
                                  icon: Icons.date_range,
                                  title: AppLocalKay.passportExpiry.tr(),
                                  value: item.passEndDate,
                                ),
                                const Divider(),
                                CustomTittelAndSubTittelWidget(
                                  icon: Icons.calendar_month,
                                  title: AppLocalKay.residencyExpiry.tr(),
                                  value: item.idEDate,
                                ),
                                const Divider(),
                                CustomTittelAndSubTittelWidget(
                                  icon: Icons.date_range,
                                  title: AppLocalKay.annualLeaveDays.tr(),
                                  value: item.holiday.toString(),
                                ),
                                const Divider(),
                                CustomTittelAndSubTittelWidget(
                                  icon: Icons.business,
                                  title: AppLocalKay.project.tr(),
                                  value: item.projectName,
                                ),
                                const Divider(),
                                CustomTittelAndSubTittelWidget(
                                  icon: Icons.account_balance,
                                  title: AppLocalKay.bank.tr(),
                                  value: item.bName,
                                ),
                                const Divider(),
                                CustomTittelAndSubTittelWidget(
                                  icon: Icons.date_range,
                                  title: AppLocalKay.lastVacationReturn.tr(),
                                  value: item.lastVacationEndDate,
                                ),
                              ],
                              const Gap(12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showMore = !_showMore;
                                  });
                                },
                                child: Text(
                                  _showMore ? AppLocalKay.showLess.tr() : AppLocalKay.showMore.tr(),
                                  style: AppTextStyle.text16MSecond(
                                    context,
                                    color: AppColor.primaryColor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(24),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
