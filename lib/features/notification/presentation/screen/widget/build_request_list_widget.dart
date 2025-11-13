import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/notification/data/model/req_count_response.dart';
import 'package:my_template/features/notification/data/model/request_dynamic_count_model.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_cubit.dart';

class CombinedRequest {
  final ReqCountItem? staticItem;
  final RequestDynamicCountModel? dynamicItem;

  CombinedRequest.static(this.staticItem) : dynamicItem = null;
  CombinedRequest.dynamic(this.dynamicItem) : staticItem = null;

  bool get isStatic => staticItem != null;
  int get count => isStatic ? (staticItem!.reqCount) : (dynamicItem!.requestCount);

  String title(BuildContext context) {
    if (isStatic) {
      return RequestTypeHelper.name(staticItem!.type);
    } else {
      return AppLocalKay.requestgeneral.tr();
    }
  }
}

Widget buildRequestList(
  BuildContext context,
  List<ReqCountItem> requests, {
  List<RequestDynamicCountModel> dynamicRequests5007 = const [],
  List<RequestDynamicCountModel> dynamicRequests5008 = const [],
}) {
  final empId = int.tryParse(HiveMethods.getEmpCode() ?? '0') ?? 0;


  final allTiles = <Widget>[];

  // الطلبات الثابتة
  for (var r in requests) {
    allTiles.add(
      _buildTile(
        context: context,
        title: RequestTypeHelper.name(r.type),
        count: r.reqCount,
        onTap: () async {
          final shouldRefresh = await Navigator.pushNamed(
            context,
            RoutesName.pendingRequests,
            arguments: {'type': r.type},
          );
          if (shouldRefresh == true) {
            context.read<NotifictionCubit>().getReqCount(empId: empId);
          }
        },
      ),
    );
  }

  // الطلب العام (5007)
  for (var d in dynamicRequests5007) {
    allTiles.add(
      _buildTile(
        context: context,
        title: AppLocalKay.requestgeneral.tr(),
        count: d.requestCount,
        onTap: () async {
          final shouldRefresh = await Navigator.pushNamed(
            context,
            RoutesName.pendingRequests,
            arguments: {'type': RequestType.dynamicRequest},
          );
          if (shouldRefresh == true) {
            context.read<NotifictionCubit>().getDynamicRequestToDecideModel(
              empId: empId,
              requestType: 5007,
            );
            context.read<NotifictionCubit>().getReqCount(empId: empId);
          }
        },
      ),
    );
  }

  // طلب تغيير جهاز الموظف (5008)
  for (var d in dynamicRequests5008) {
    allTiles.add(
      _buildTile(
        context: context,
        title: AppLocalKay.requestchangePhone.tr(),
        count: d.requestCount,
        onTap: () async {
          final shouldRefresh = await Navigator.pushNamed(
            context,
            RoutesName.pendingRequests,
            arguments: {'type': RequestType.changeIdPhoneRequest},
          );
          if (shouldRefresh == true) {
            context.read<NotifictionCubit>().getDynamicRequestToDecideModel(
              empId: empId,
              requestType: 5008,
            );
            context.read<NotifictionCubit>().getReqCount(empId: empId);
          }
        },
      ),
    );
  }

  if (allTiles.isEmpty) {
    return Center(
      child: Text(AppLocalKay.no_requests.tr(), style: AppTextStyle.text16MSecond(context)),
    );
  }

  return ListView.separated(
    padding: const EdgeInsets.all(12),
    itemCount: allTiles.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (context, index) => allTiles[index],
  );
}

Widget _buildTile({
  required BuildContext context,
  required String title,
  required int count,
  required VoidCallback onTap,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(colors: [AppColor.whiteColor(context), Colors.grey.shade100]),
      boxShadow: [
        BoxShadow(
          color: AppColor.blackColor(context).withOpacity(0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.blackColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active, color: AppColor.blackColor(context), size: 28),
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: AppColor.whiteColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(title, style: AppTextStyle.text16MSecond(context)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    ),
  );
}
