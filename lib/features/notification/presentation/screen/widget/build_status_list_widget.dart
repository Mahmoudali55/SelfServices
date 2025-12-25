import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/notification/data/model/employee_requests_notify_model.dart';
import 'package:my_template/features/notification/presentation/screen/widget/notification_request_type_mapper.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';

class ModernNotificationScreen extends StatefulWidget {
  final List<RequestItem> data;
  const ModernNotificationScreen({super.key, required this.data});

  @override
  State<ModernNotificationScreen> createState() => _ModernNotificationScreenState();
}

class _ModernNotificationScreenState extends State<ModernNotificationScreen> {
  int? selectedStatus; // null = All, 0 = In Progress, 1 = Accepted, 2 = Rejected, 3 = Holding

  List<RequestItem> get filteredData {
    if (selectedStatus == null) return widget.data;
    return widget.data.where((item) => item.reqDecideState == selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sortedData = sortByDate(filteredData);
    final takeCount = sortedData.length >= 3 ? 3 : sortedData.length;
    final latestItems = sortedData.take(takeCount).toList();
    final olderItems = sortedData.length > takeCount
        ? sortedData.sublist(takeCount)
        : <RequestItem>[];

    final allItems = [...latestItems, ...olderItems];

    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: allItems.isEmpty
              ? Center(
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
                        style: AppTextStyle.text16MSecond(context),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: allItems.length,
                  itemBuilder: (context, index) {
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
                              style: AppTextStyle.text16MSecond(
                                context,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (index == latestItems.length && olderItems.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              context.locale.languageCode == 'ar' ? 'الأقدم' : 'Older',
                              style: AppTextStyle.text16MSecond(
                                context,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        BuildModernNotificationItem(item: item),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': context.locale.languageCode == 'ar' ? 'الكل' : 'All', 'value': null},
      {'label': context.locale.languageCode == 'ar' ? 'تحت الإجراء' : 'In Progress', 'value': 0},
      {'label': context.locale.languageCode == 'ar' ? 'تحت السحب' : 'Holding', 'value': 3},
      {'label': context.locale.languageCode == 'ar' ? 'مقبول' : 'Accepted', 'value': 1},
      {'label': context.locale.languageCode == 'ar' ? 'مرفوض' : 'Rejected', 'value': 2},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedStatus == filter['value'];
          return ChoiceChip(
            label: Text(
              filter['label'] as String,
              style: AppTextStyle.text14MPrimary(
                context,
                color: isSelected ? Colors.white : AppColor.blackColor(context),
              ),
            ),
            selected: isSelected,
            selectedColor: AppColor.primaryColor(context),
            backgroundColor: Colors.grey.shade200,
            onSelected: (selected) {
              setState(() {
                selectedStatus = filter['value'] as int?;
              });
            },
          );
        },
      ),
    );
  }
}

class BuildModernNotificationItem extends StatelessWidget {
  final RequestItem item;
  const BuildModernNotificationItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
      case 3:
      case 4:
        iconData = Icons.access_time_filled_rounded;
        iconColor = const Color(0xFF3498DB); // Blue for holding
        iconBgColor = const Color(0xFFAED6F1);
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
    final initialType = mapReqTypeToInitialType(item.reqtype);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await _handleNotificationTap(context, item, initialType);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColor.whiteColor(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
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
                  Text(
                    dateText,
                    style: AppTextStyle.text14RGrey(context).copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    RequestItem item,
    String initialType,
  ) async {
    final repo = context.read<VacationRequestsCubit>().vacationRequestsRepo;
    final empCode = item.empCode;
    final requestId = item.vacRequestId;

    // Show loading
    BotToast.showLoading();

    try {
      // 1. Vacation Request (reqtype == 1)
      if (item.reqtype == 1) {
        final result = await repo.vacationRequests(empcode: empCode, requestId: requestId);
        result.fold((failure) => _showErrorAndFallback(context, failure.errMessage, initialType), (
          requests,
        ) {
          BotToast.closeAllLoading();
          if (requests.isNotEmpty) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.requestHistoryDetilesScreen,
              arguments: requests.first,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 2. Back From Vacation (reqtype == 18)
      else if (item.reqtype == 18) {
        final result = await repo.getRequestVacationBack(empCode: empCode);
        result.fold((failure) => _showErrorAndFallback(context, failure.errMessage, initialType), (
          list,
        ) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.vacRequestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.backFromVacationDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 3. Solfa (reqtype == 4)
      else if (item.reqtype == 4) {
        final result = await repo.getSolfaRequests(empCode: empCode);
        result.fold((failure) => _showErrorAndFallback(context, failure.errMessage, initialType), (
          list,
        ) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(context, RoutesName.solfaDetailsScreen, arguments: target);
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 4. Housing Allowance (reqtype == 8)
      else if (item.reqtype == 8) {
        final result = await repo.getAllHousingAllowance(empCode: empCode);
        result.fold((failure) => _showErrorAndFallback(context, failure.errMessage, initialType), (
          list,
        ) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.housingAllowanceDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 5. Cars (reqtype == 9)
      else if (item.reqtype == 9) {
        final result = await repo.getAllCars(empcode: empCode);
        result.fold((failure) => _showErrorAndFallback(context, failure.errMessage, initialType), (
          list,
        ) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(context, RoutesName.carDetailsScreen, arguments: target);
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 6. Resignation (reqtype == 5)
      else if (item.reqtype == 5) {
        final result = await repo.getAllResignation(empCode: empCode);
        result.fold((failure) => _showErrorAndFallback(context, failure.errMessage, initialType), (
          list,
        ) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.resignationDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 7. Transfer (reqtype == 19)
      else if (item.reqtype == 19) {
        final result = await repo.getAllTransfer(empcode: empCode);
        result.fold((failure) => _showErrorAndFallback(context, failure.errMessage, initialType), (
          list,
        ) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.transferDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 8. Tickets (reqtype == 7)
      else if (item.reqtype == 7) {
        final result = await repo.getAllTickets(empcode: empCode);
        result.fold((failure) => _showErrorAndFallback(context, failure.errMessage, initialType), (
          list,
        ) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestID == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(context, RoutesName.ticketDetailsScreen, arguments: target);
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // 9. General Requests and others (reqtype: 2, 3, 15, 16, 17)
      else if ([2, 3, 15, 16, 17].contains(item.reqtype)) {
        final result = await repo.getDynamicOrder(empcode: empCode, requesttypeid: item.reqtype);
        result.fold((failure) => _showErrorAndFallback(context, failure.errMessage, initialType), (
          list,
        ) {
          BotToast.closeAllLoading();
          final target = list.where((e) => e.requestId == requestId).firstOrNull;
          if (target != null) {
            NavigatorMethods.pushNamed(
              context,
              RoutesName.generalRequestDetailsScreen,
              arguments: target,
            );
          } else {
            _fallback(context, initialType);
          }
        });
      }
      // Fallback for unhandled types
      else {
        BotToast.closeAllLoading();
        _fallback(context, initialType);
      }
    } catch (e) {
      BotToast.closeAllLoading();
      _fallback(context, initialType);
    }
  }

  void _showErrorAndFallback(BuildContext context, String error, String initialType) {
    BotToast.closeAllLoading();
    // Optional: show error toast here if desired, or just fallback silently
    // BotToast.showText(text: error);
    _fallback(context, initialType);
  }

  void _fallback(BuildContext context, String initialType) {
    NavigatorMethods.pushNamedAndRemoveUntil(
      context,
      RoutesName.layoutScreen,
      arguments: {'restoreIndex': 1, 'initialType': initialType},
    );
  }
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
