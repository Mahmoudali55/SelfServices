import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class CustomAppBarAction extends StatelessWidget {
  const CustomAppBarAction({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(10.h),
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 20.h,
                    width: 20.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.whiteColor(context),
                      border: Border.all(color: AppColor.greyColor(context)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.close, color: AppColor.blackColor(context), size: 15)],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  AppLocalKay.page_details.tr(),
                  style: AppTextStyle.text18MSecond(context, color: AppColor.primaryColor(context)),
                ),
                const Spacer(),
              ],
            ),
            Gap(10.h),
            Text(title, style: AppTextStyle.text18MSecond(context)),
          ],
        ),
      ),
    );
  }
}
