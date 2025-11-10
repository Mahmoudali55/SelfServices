import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class CustomTabBarWidget extends StatelessWidget {
  const CustomTabBarWidget({
    super.key,
    required this.totalRequestsCount,
    required this.totalStatusesCount,
  });

  final int totalRequestsCount;
  final int totalStatusesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        physics: const NeverScrollableScrollPhysics(),

        isScrollable: true,
        indicator: BoxDecoration(
          color: AppColor.primaryColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppColor.whiteColor(context),
        unselectedLabelColor: AppColor.blackColor(context),
        labelStyle: AppTextStyle.text16MSecond(context),
        unselectedLabelStyle: AppTextStyle.text16MSecond(context),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(AppLocalKay.pendingRequests.tr(), overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColor.whiteColor(context),
                  child: Text(
                    totalRequestsCount.toString(),
                    style: AppTextStyle.text14MPrimary(
                      context,
                    ).copyWith(color: AppColor.blackColor(context), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(AppLocalKay.requestStatuses.tr(), overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColor.whiteColor(context),
                  child: Text(
                    totalStatusesCount.toString(),
                    style: AppTextStyle.text14MPrimary(context).copyWith(
                      color: AppColor.blackColor(context),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
