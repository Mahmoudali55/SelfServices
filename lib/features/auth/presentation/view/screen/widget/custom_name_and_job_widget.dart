import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/features/profile/data/model/profile_model.dart';
import 'package:my_template/features/profile/presentation/view/screen/widget/local_profile_screen.dart';

class CustomNameAndJobWidget extends StatelessWidget {
  const CustomNameAndJobWidget({super.key, required this.item});

  final ProfileModel item;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 12.h),
          const UploadProfileWidget(),
          SizedBox(height: 12.h),
          Text(
            textAlign: TextAlign.center,
            context.locale.languageCode == 'ar' ? item.empName : item.empNameE,
            style: AppTextStyle.text18MSecond(
              context,
            ).copyWith(color: AppColor.blackColor(context)),
          ),
          Text(
            textAlign: TextAlign.center,
            context.locale.languageCode == 'ar' ? item.jobName ?? '' : item.jobEName ?? '',
            style: AppTextStyle.text16MSecond(context, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
