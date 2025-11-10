import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_loading/custom_shimmer_list.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/setting/data/model/employee_salary_model.dart';
import 'package:my_template/features/setting/presentation/cubit/setting_state.dart';
import 'package:my_template/features/setting/presentation/cubit/settting_cubit.dart';
import 'package:my_template/features/setting/presentation/screen/widget/salary_vocabulary/empty_salary_widget.dart';
import 'package:my_template/features/setting/presentation/screen/widget/salary_vocabulary/month_selector_widget.dart';
import 'package:my_template/features/setting/presentation/screen/widget/salary_vocabulary/salary_list_widget.dart';

class SalaryVocabularyScreen extends StatefulWidget {
  const SalaryVocabularyScreen({super.key});

  @override
  State<SalaryVocabularyScreen> createState() => _SalaryVocabularyScreenState();
}

class _SalaryVocabularyScreenState extends State<SalaryVocabularyScreen> {
  late DateTime currentMonth;
  int empCode = int.parse(HiveMethods.getEmpCode() ?? '0');
  late ScrollController _monthScrollController;
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    _monthScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSalary();
      _scrollToCurrentMonth();
    });
  }

  void _fetchSalary() {
    context.read<SettingCubit>().employeeSalary(
      2016,
      empCode,
      12,
      context.locale.languageCode == 'ar' ? 'ar' : 'EN-GB',
    );
  }

  List<DateTime> getVisibleMonths() => List.generate(12, (i) => DateTime(currentMonth.year, i + 1));

  void _scrollToCurrentMonth() {
    final visibleMonths = getVisibleMonths();
    final index = visibleMonths.indexWhere((m) => m.month == currentMonth.month);
    if (index >= 0) {
      _monthScrollController.animateTo(
        index * 78.w,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleMonths = getVisibleMonths();

    return Scaffold(
      backgroundColor: AppColor.primaryColor(context),
      appBar: CustomAppBar(
        appBarColor: AppColor.primaryColor(context),
        context,
        centerTitle: true,
        leading: BackButton(color: AppColor.whiteColor(context)),
        title: Text(
          AppLocalKay.salaryvocabulary.tr(),
          style: AppTextStyle.text18MSecond(context, color: AppColor.whiteColor(context)),
        ),
      ),
      body: Stack(
        children: [
          Container(color: AppColor.primaryColor(context)),
          Positioned(
            top: 80.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 90.h, bottom: 40.h),
              decoration: BoxDecoration(
                color: AppColor.whiteColor(context),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: () {
                  _fetchSalary();
                  return Future.delayed(const Duration(milliseconds: 500));
                },
                child: BlocBuilder<SettingCubit, SettingState>(
                  builder: (context, state) {
                    final status = state.employeeSalaryStatus;

                    if (status.isLoading) return const Center(child: CustomShimmerList());
                    if (status.isFailure) return Center(child: Text(status.error ?? 'Error'));

                    if (status.isSuccess) {
                      final EmployeeSalaryModel? salaryData = status.data;
                      if (salaryData == null || salaryData.data.isEmpty) {
                        return const EmptySalaryWidget();
                      }
                      return SalaryListWidget(salaryData: salaryData);
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 20.h,
            left: 20.w,
            right: 20.w,
            child: MonthSelectorWidget(
              currentDate: currentDate,
              currentMonth: currentMonth,
              monthScrollController: _monthScrollController,
              visibleMonths: visibleMonths,
              onMonthChanged: (newDate) {
                setState(() {
                  currentDate = newDate;
                  currentMonth = newDate;
                });
                _fetchSalary();
                _scrollToCurrentMonth();
              },
            ),
          ),
        ],
      ),
    );
  }
}
