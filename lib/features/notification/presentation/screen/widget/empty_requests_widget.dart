import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class EmptyRequestsWidget extends StatelessWidget {
  const EmptyRequestsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppImages.assetsGlobalIconEmptyFolderIcon,
            height: 200,
            width: 200,
            color: AppColor.primaryColor(context),
          ),
          const Gap(20),
          Text(
            AppLocalKay.no_requests.tr(),
            style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
          ),
        ],
      ),
    );
  }
}
