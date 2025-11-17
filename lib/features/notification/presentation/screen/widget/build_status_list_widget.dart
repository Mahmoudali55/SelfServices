import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/features/notification/data/model/employee_requests_notify_model.dart';

class ModernNotificationScreen extends StatefulWidget {
  final List<RequestItem> data;
  const ModernNotificationScreen({super.key, required this.data});

  @override
  State<ModernNotificationScreen> createState() => _ModernNotificationScreenState();
}

class _ModernNotificationScreenState extends State<ModernNotificationScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<RequestItem> latestItems;
  late List<RequestItem> olderItems;

  @override
  void initState() {
    super.initState();

    final sortedData = sortByDate(widget.data);

    final takeCount = sortedData.length >= 3 ? 3 : sortedData.length;
    latestItems = sortedData.take(takeCount).toList();

    olderItems = sortedData.length > takeCount ? sortedData.sublist(takeCount) : <RequestItem>[];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertItems();
    });
  }

  Future<void> _insertItems() async {
    int index = 0;
    for (var item in latestItems + olderItems) {
      await Future.delayed(const Duration(milliseconds: 100));
      _listKey.currentState?.insertItem(index);
      index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = [...latestItems, ...olderItems];
    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.all(12),
      initialItemCount: 0,
      itemBuilder: (context, index, animation) {
        final item = allItems[index];
        final isLatest = index < latestItems.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0 && isLatest)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  context.locale.languageCode == 'ar' ? 'الأحدث' : 'Latest',
                  style: AppTextStyle.text16MSecond(context).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            if (index == latestItems.length && olderItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  context.locale.languageCode == 'ar' ? 'الأقدم' : 'Older',
                  style: AppTextStyle.text16MSecond(context).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: FadeTransition(
                opacity: animation,
                child: buildModernNotificationItem(context, item),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget buildModernNotificationItem(BuildContext context, RequestItem item) {
  IconData iconData;
  Color iconColor;
  Color iconBgColor;

  switch (item.reqDecideState) {
    case 1:
      iconData = Icons.check_circle_rounded;
      iconColor = AppColor.greenColor(context);
      iconBgColor = const Color(0xFFA9DFBF);
      break;
    case 2:
      iconData = Icons.cancel_rounded;
      iconColor = const Color(0xFFC0392B);
      iconBgColor = const Color(0xFFF5B7B1);
      break;
    default:
      iconData = Icons.autorenew_rounded;
      iconColor = const Color(0xFFE67E22);
      iconBgColor = const Color(0xFFFAD7A0);
  }

  final requestTypeName = 'request_type.${item.reqtype}'.tr();

  String dateText = '-';
  if (item.vacRequestDate != null) {
    final date = parseDate(item.vacRequestDate!);
    final dayName = DateFormat('EEE, dd MMM yyyy', context.locale.languageCode).format(date);
    dateText = dayName;
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: AppColor.whiteColor(context),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: iconBgColor.withOpacity(0.15),
        child: Icon(iconData, color: iconColor, size: 28),
      ),
      title: Text(
        requestTypeName,
        style: AppTextStyle.text16MSecond(context).copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(item.requestDesc, style: AppTextStyle.text14RGrey(context)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(dateText, style: AppTextStyle.text14RGrey(context).copyWith(color: Colors.grey)),
            ],
          ),
        ],
      ),
    ),
  );
}

DateTime parseDate(String date) {
  try {
    final parts = date.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  } catch (e) {
    return DateTime(1900);
  }
}

List<RequestItem> sortByDate(List<RequestItem> items) {
  final sortedList = List<RequestItem>.from(items);
  sortedList.sort((a, b) {
    final dateA = a.vacRequestDate != null ? parseDate(a.vacRequestDate!) : DateTime(1900);
    final dateB = b.vacRequestDate != null ? parseDate(b.vacRequestDate!) : DateTime(1900);
    return dateB.compareTo(dateA);
  });
  return sortedList;
}
