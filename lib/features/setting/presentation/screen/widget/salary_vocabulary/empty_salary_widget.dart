import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class EmptySalaryWidget extends StatelessWidget {
  const EmptySalaryWidget({super.key});

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
              height: 120.h,
              width: 120.w,
              color: AppColor.primaryColor(context),
            ),
            Gap(16.h),
            Text(
              AppLocalKay.noResults.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
            ),
            Gap(8.h),
            Text(
              AppLocalKay.checkBackLater.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyle.text14RGrey(context, color: AppColor.blackColor(context)),
            ),
          ],
        ),
      ),
    );
  }
}
