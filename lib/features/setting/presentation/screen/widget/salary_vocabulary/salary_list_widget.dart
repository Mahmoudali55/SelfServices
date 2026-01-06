import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/setting/data/model/employee_salary_model.dart';
import 'package:my_template/features/setting/presentation/screen/widget/salary_vocabulary/salary_section_widget.dart';

class SalaryListWidget extends StatelessWidget {
  final EmployeeSalaryModel salaryData;

  const SalaryListWidget({super.key, required this.salaryData});

  @override
  Widget build(BuildContext context) {
    final earnings = salaryData.data.where((e) => e.varType == '1').toList();
    final deductions = salaryData.data.where((e) => e.varType == '2').toList();
    final installments = salaryData.data.where((e) => e.varType == '3').toList();

    double totalSalary = salaryData.data.isNotEmpty ? salaryData.data.first.val1 ?? 0.0 : 0.0;
    String tafkeet = salaryData.data.isNotEmpty ? salaryData.data.first.tafkeet ?? '' : '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SalarySectionWidget(
            title: AppLocalKay.earnings.tr(),
            items: earnings,
            accentColor: Colors.green,
          ),
          SalarySectionWidget(
            title: AppLocalKay.deductions.tr(),
            items: deductions,
            accentColor: Colors.redAccent,
          ),
          SalarySectionWidget(
            title: AppLocalKay.installments.tr(),
            items: installments,
            accentColor: Colors.orangeAccent,
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColor.primaryColor(context),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalKay.totalSalary.tr(),
                      style: AppTextStyle.text18MSecond(context).copyWith(color: Colors.white),
                    ),
                    Text(
                      '${totalSalary.toStringAsFixed(2)} ${AppLocalKay.currency.tr()}',
                      style: AppTextStyle.text18MSecond(context).copyWith(color: Colors.white),
                    ),
                  ],
                ),
                if (tafkeet.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        tafkeet,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
