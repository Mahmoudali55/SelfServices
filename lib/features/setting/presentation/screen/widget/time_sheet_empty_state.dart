import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class TimeSheetEmptyState extends StatelessWidget {
  const TimeSheetEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 90.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppImages.assetsGlobalIconEmptyFolderIcon,
              height: 180.h,
              width: 180.w,
              color: AppColor.primaryColor(context),
            ),
            Gap(16.h),
            Text(
              AppLocalKay.noTimesheet.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.blackColor(context),
              ),
            ),
            Gap(8.h),
            Text(
              AppLocalKay.checkBackLater.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColor.blackColor(context)),
            ),
          ],
        ),
      ),
    );
  }
}
