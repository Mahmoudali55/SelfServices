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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();

    _controller.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(_controller.value * maxScroll);
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
    final lang = context.locale.languageCode;
    return Container(
      height: 35.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.newsList.length,
        separatorBuilder: (_, __) => SizedBox(width: 30.w),
        itemBuilder: (context, index) {
          final news = widget.newsList[index];

          return GestureDetector(
            onTap: () => _showNewsDetails(context, news),
            child: Row(
              children: [
                Icon(Icons.fiber_new, color: AppColor.greenColor(context), size: 18.sp),
                SizedBox(width: 5.w),
                Text(
                  news.title(lang),
                  style: AppTextStyle.text14MPrimary(context, color: AppColor.greenColor(context)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showNewsDetails(BuildContext context, GetNewsModel news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        builder: (context, scrollController) {
          final lang = context.locale.languageCode;
          return Container(
            decoration: BoxDecoration(
              color: AppColor.whiteColor(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -4)),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 5.h,
                  margin: EdgeInsets.only(bottom: 15.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.black),
                            ),
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
                      Gap(15.h),
                      Text(
                        news.subject(lang),
                        style: AppTextStyle.text14MPrimary(
                          context,
                          color: AppColor.greenColor(context),
                        ),
                      ),
                      Gap(10.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
