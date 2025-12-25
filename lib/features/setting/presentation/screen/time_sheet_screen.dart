import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_loading/custom_shimmer_list.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/setting/presentation/cubit/setting_state.dart';
import 'package:my_template/features/setting/presentation/cubit/settting_cubit.dart';
import 'package:my_template/features/setting/presentation/screen/widget/time_sheet_card.dart';
import 'package:my_template/features/setting/presentation/screen/widget/time_sheet_date_selector.dart';
import 'package:my_template/features/setting/presentation/screen/widget/time_sheet_empty_state.dart';

class TimeSheetScreen extends StatefulWidget {
  const TimeSheetScreen({super.key});

  @override
  State<TimeSheetScreen> createState() => _TimeSheetScreenState();
}

class _TimeSheetScreenState extends State<TimeSheetScreen> {
  late DateTime currentDate;
  late int empCode;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    empCode = int.tryParse(HiveMethods.getEmpCode() ?? '0') ?? 0;
    _fetchTimeSheet(currentDate);
  }

  void _fetchTimeSheet(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd', 'en').format(date);
    context.read<SettingCubit>().getTimeSheet(formattedDate, empCode);
  }

  List<DateTime> get visibleDays => List.generate(5, (i) => currentDate.add(Duration(days: i - 2)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor(context),
      appBar: CustomAppBar(
        context,
        leading: BackButton(color: AppColor.whiteColor(context)),
        centerTitle: true,
        appBarColor: AppColor.primaryColor(context),
        title: Text(
          AppLocalKay.timesheet.tr(),
          style: AppTextStyle.text18MSecond(context, color: AppColor.whiteColor(context)),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.print, color: AppColor.whiteColor(context)),
        //     onPressed: () {
        //       final state = context.read<SettingCubit>().state;
        //       final timeSheets = state.timeSheetListStatus.data ?? [];

        //       if (timeSheets.isNotEmpty) {
        //         printTimeSheet(timeSheets, currentDate);
        //       }
        //     },
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          Container(color: AppColor.primaryColor(context)),
          _buildContent(context),
          TimeSheetDateSelector(
            currentDate: currentDate,
            visibleDays: visibleDays,
            onDaySelected: (day) {
              setState(() => currentDate = day);
              _fetchTimeSheet(day);
            },
            onPrevDay: () {
              setState(() => currentDate = currentDate.subtract(const Duration(days: 1)));
              _fetchTimeSheet(currentDate);
            },
            onNextDay: () {
              setState(() => currentDate = currentDate.add(const Duration(days: 1)));
              _fetchTimeSheet(currentDate);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Positioned(
      top: 50.h,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColor.whiteColor(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchTimeSheet(currentDate);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(100.h),
                BlocBuilder<SettingCubit, SettingState>(
                  builder: (context, state) {
                    final status = state.timeSheetListStatus;

                    if (status.isLoading) {
                      return const Center(child: CustomShimmerList());
                    }
                    if (status.isFailure) {
                      return Center(child: Text(status.error ?? 'Error'));
                    }
                    if (status.isSuccess) {
                      final timeSheets = status.data ?? [];
                      if (timeSheets.isEmpty) {
                        return const TimeSheetEmptyState();
                      }

                      return Column(
                        children: timeSheets
                            .map(
                              (model) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: TimeSheetCard(model: model, currentDate: currentDate),
                              ),
                            )
                            .toList(),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
