import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/home/data/model/get_news_model.dart';

class NewsTicker extends StatefulWidget {
  final List<GetNewsModel> newsList;
  const NewsTicker({super.key, required this.newsList});

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    _controller.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_controller.value * _scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.newsList.length,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        separatorBuilder: (_, __) => SizedBox(width: 40.w),
        itemBuilder: (context, index) {
          final news = widget.newsList[index];
          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
                    left: 20.w,
                    right: 20.w,
                    top: 10.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                          const Spacer(),
                          Text(
                            AppLocalKay.newdetails.tr(),
                            style: AppTextStyle.text18MSecond(
                              context,
                              color: AppColor.primaryColor(context),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      Gap(20.h),
                      Text(
                        news.newsTitle,
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      Gap(10.h),
                      Text(
                        news.miniNewsSubject,
                        style: AppTextStyle.text14MPrimary(
                          context,
                          color: AppColor.blackColor(context),
                        ),
                      ),
                      Gap(20.h),
                    ],
                  ),
                ),
              );
            },
            child: Text(
              news.newsTitle,
              style: AppTextStyle.text16MSecond(context, color: AppColor.greenColor(context)),
            ),
          );
        },
      ),
    );
  }
}
