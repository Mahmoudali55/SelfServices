import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';

PreferredSizeWidget messengerAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: AppColor.whiteColor(context),
    elevation: 1,
    centerTitle: true,
    automaticallyImplyLeading: false,
    title: Text(
      title,
      style: AppTextStyle.text18MSecond(context, color: AppColor.blackColor(context)),
    ),
    actions: [
      IconButton(
        icon:  Icon(Icons.search, color: AppColor.blackColor(context)),
        onPressed: () {},
      ),

      const SizedBox(width: 8),
    ],
  );
}
