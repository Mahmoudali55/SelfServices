import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class CustomBottomNavButtonWidget extends StatelessWidget {
  const CustomBottomNavButtonWidget({
    super.key,
    this.save,
    this.newrequest,
    this.isLoading = false,
    this.title,
    this.color,
  });
  final void Function()? save;
  final void Function()? newrequest;
  final bool? isLoading;
  final String? title;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isLoading == true ? null : save,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: color ?? AppColor.primaryColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isLoading == true
                      ? CupertinoActivityIndicator(color: AppColor.whiteColor(context))
                      : Text(
                          title ?? AppLocalKay.save.tr(),
                          style: AppTextStyle.text16MSecond(
                            context,
                            color: AppColor.whiteColor(context),
                          ),
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: newrequest,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.transparent,
                  border: Border.all(color: AppColor.primaryColor(context)),
                ),
                child: Center(
                  child: Text(
                    AppLocalKay.newrequest.tr(),
                    style: AppTextStyle.text16MSecond(
                      context,
                      color: AppColor.primaryColor(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
