import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class SalarySectionWidget extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final Color accentColor;

  const SalarySectionWidget({
    super.key,
    required this.title,
    required this.items,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    double total = items.fold(0.0, (sum, item) => sum + (item.varVal1 ?? 0.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.text16MSecond(
            context,
          ).copyWith(color: AppColor.blackColor(context), fontWeight: FontWeight.bold),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final item = items[index];
            final displayName = context.locale.languageCode == 'ar'
                ? item.paName ?? '-'
                : item.paNameE ?? '-';
            final displayValue =
                '${item.varVal1?.toStringAsFixed(2) ?? '0.00'} ${AppLocalKay.currency.tr()}';

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border(
                  left: BorderSide(color: accentColor, width: 4.w),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.blackColor(context).withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: Text(displayName, style: AppTextStyle.text14MPrimary(context))),
                  Text(displayValue, style: AppTextStyle.text14MPrimary(context)),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppLocalKay.total.tr()} $title',
                    style: AppTextStyle.text14MPrimary(
                      context,
                    ).copyWith(color: AppColor.blackColor(context)),
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} ${AppLocalKay.currency.tr()}',
                  style: AppTextStyle.text14MPrimary(
                    context,
                  ).copyWith(color: AppColor.blackColor(context)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
