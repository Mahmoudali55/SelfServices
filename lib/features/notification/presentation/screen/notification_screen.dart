import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_loading/custom_shimmer_list.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_state.dart';
import 'package:my_template/features/notification/presentation/screen/widget/build_request_list_widget.dart';
import 'package:my_template/features/notification/presentation/screen/widget/build_status_list_widget.dart';
import 'package:my_template/features/notification/presentation/screen/widget/custom_tab_bar_widget.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key, required this.pagePrivID});
  final int pagePrivID;
  @override
  Widget build(BuildContext context) {
    if (pagePrivID != 1) {
      return BlocBuilder<NotificationsCubit, NotificationState>(
        builder: (context, state) {
          final status = state.reqCountStatus;
          final requestStatuses = state.employeeRequestsNotify;

          if (status.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: CustomShimmerList(height: 100, length: 10),
            );
          }

          if (status.isFailure) {
            return Center(
              child: Text(status.error ?? 'حدث خطأ', style: AppTextStyle.text16MSecond(context)),
            );
          }

          return Scaffold(
            appBar: CustomAppBar(
              context,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppColor.blackColor(context)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                AppLocalKay.notifications.tr(),
                style: AppTextStyle.text18MSecond(context),
              ),
            ),
            body: Column(
              children: [
                const Gap(20),
                Expanded(child: ModernNotificationScreen(data: requestStatuses.data?.data ?? [])),
              ],
            ),
          );
        },
      );
    } else {
      return DefaultTabController(
        length: 2,
        child: BlocBuilder<NotificationsCubit, NotificationState>(
          builder: (context, state) {
            final status = state.reqCountStatus;
            final requestStatuses = state.employeeRequestsNotify;
            return Scaffold(
              appBar: CustomAppBar(
                height: 120,
                context,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: AppColor.blackColor(context)),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  AppLocalKay.notifications.tr(),
                  style: AppTextStyle.text18MSecond(context),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: BlocBuilder<NotificationsCubit, NotificationState>(
                      builder: (context, state) {
                        final dataList = state.reqCountStatus.data?.data ?? [];
                        final dynamic5007 = state.requestDynamic5007.data ?? [];
                        final dynamic5008 = state.requestDynamic5008.data ?? [];

                        final totalRequestsCount = dataList.fold<int>(
                          0,
                          (sum, item) => sum + item.reqCount,
                        );
                        final totalDynamic5007 = dynamic5007.fold<int>(
                          0,
                          (sum, item) => sum + item.requestCount,
                        );
                        final totalDynamic5008 = dynamic5008.fold<int>(
                          0,
                          (sum, item) => sum + item.requestCount,
                        );

                        final totalDynamicCount = totalDynamic5007 + totalDynamic5008;
                        final totalStatusesCount =
                            state.employeeRequestsNotify.data?.data.length ?? 0;

                        return CustomTabBarWidget(
                          totalRequestsCount: totalRequestsCount + totalDynamicCount,
                          totalStatusesCount: totalStatusesCount,
                        );
                      },
                    ),
                  ),
                ),
              ),
              body: state.reqCountStatus.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CustomShimmerList(height: 100, length: 10),
                    )
                  : TabBarView(
                      children: [
                        buildRequestList(
                          context,
                          status.data?.data ?? [],
                          dynamicRequests5007: state.requestDynamic5007.data ?? [],
                          dynamicRequests5008: state.requestDynamic5008.data ?? [],
                        ),
                        ModernNotificationScreen(data: requestStatuses.data?.data ?? []),
                      ],
                    ),
            );
          },
        ),
      );
    }
  }
}
