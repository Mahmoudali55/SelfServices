import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/request_ListView.dart';

class RequestsTabView extends StatelessWidget {
  final int empCode;
  final List<dynamic> underReview;
  final List<dynamic> approved;
  final List<dynamic> rejected;

  const RequestsTabView({
    super.key,
    required this.empCode,
    required this.underReview,
    required this.approved,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              isScrollable: true,
              automaticIndicatorColorAdjustment: false,
              physics: const NeverScrollableScrollPhysics(),
              indicator: BoxDecoration(
                color: AppColor.primaryColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: AppColor.whiteColor(context),
              unselectedLabelColor: AppColor.blackColor(context),
              labelStyle: AppTextStyle.text16MSecond(context).copyWith(fontSize: 14.sp),
              tabs: [
                _buildTab(context, AppLocalKay.under_review.tr(), underReview.length),
                _buildTab(context, AppLocalKay.approved.tr(), approved.length),
                _buildTab(context, AppLocalKay.rejected.tr(), rejected.length),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              children: [
                RequestListView(requests: underReview, empCode: empCode),
                RequestListView(requests: approved, empCode: empCode),
                RequestListView(requests: rejected, empCode: empCode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String text, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, overflow: TextOverflow.ellipsis),
          SizedBox(width: 2.w),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: AppColor.whiteColor(context), shape: BoxShape.circle),
            child: Text(
              textAlign: TextAlign.center,
              '$count',
              style: AppTextStyle.text14MPrimary(
                context,
                color: AppColor.blackColor(context),
              ).copyWith(fontWeight: FontWeight.bold, fontSize: 10.sp),
            ),
          ),
        ],
      ),
    );
  }
}
