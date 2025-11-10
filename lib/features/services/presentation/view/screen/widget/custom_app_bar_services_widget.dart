import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar_action.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';

AppBar CustomAppBarServicesWidget(BuildContext context, {required String title, String? helpText}) {
  return AppBar(
    centerTitle: true,
    backgroundColor: AppColor.whiteColor(context, listen: false),
    title: Builder(
      builder: (innerContext) {
        return Text(
          title,
          style: AppTextStyle.text18MSecond(innerContext).copyWith(fontFamily: 'Cairo'),
        );
      },
    ),
    actions: [
      Builder(
        builder: (innerContext) {
          return InkWell(
            onTap: () {
              showModalBottomSheet(
                context: innerContext,
                backgroundColor: AppColor.whiteColor(innerContext, listen: false),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (modalContext) {
                  return CustomAppBarAction(title: helpText ?? '');
                },
              );
            },
            child: Icon(
              Icons.help_outline,
              color: AppColor.blackColor(innerContext, listen: false),
            ),
          );
        },
      ),
    ],
  );
}
