import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_state.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';

class CustomHomeHeaderWidget extends StatefulWidget {
  const CustomHomeHeaderWidget({
    super.key,
    required this.name,
    required this.searchController,
    required this.child,
  });

  final String? name;
  final TextEditingController searchController;
  final Widget child;

  @override
  State<CustomHomeHeaderWidget> createState() => _CustomHomeHeaderWidgetState();
}

class _CustomHomeHeaderWidgetState extends State<CustomHomeHeaderWidget> {
  String? _cachedBase64Image;
  String? _imageBase64FromServer;

  @override
  void initState() {
    super.initState();

    _cachedBase64Image = HiveMethods.getEmpPhotoBase64();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final photoWeb = HiveMethods.getEmpPhotoBase64() ?? '';
      if (photoWeb.isNotEmpty) {
        context.read<ServicesCubit>().imageFileName(photoWeb, context);
      }

      final empId = int.tryParse(HiveMethods.getEmpCode() ?? '0') ?? 0;
      context.read<NotifictionCubit>().getReqCount(empId: empId);
      context.read<NotifictionCubit>().getemployeeRequestsNotify(empId: empId);
      context.read<NotifictionCubit>().getDynamicRequestToDecideModel(
        empId: empId,
        requestType: 5007,
      );
      context.read<NotifictionCubit>().getDynamicRequestToDecideModel(
        empId: empId,
        requestType: 5008,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final empName = lang == 'ar'
        ? (HiveMethods.getEmpNameAR() ?? '')
        : (HiveMethods.getEmpNameEn() ?? '');

    return BlocListener<ServicesCubit, ServicesState>(
      listener: (context, state) async {
        // بعد نجاح تحميل الصورة من السيرفر
        if (state.imageFileNameStatus?.isSuccess ?? false) {
          final newBase64 = state.imageFileNameStatus!.data;
          if (newBase64 != null && newBase64.isNotEmpty) {
            setState(() {
              _imageBase64FromServer = newBase64;
            });

            // حفظ الصورة الجديدة في الكاش
            HiveMethods.saveEmpPhotoBase64(newBase64);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.primaryColor(context),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const Gap(10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => NavigatorMethods.pushNamed(
                    context,
                    RoutesName.profileScreen,
                    arguments: {'empId': int.tryParse(HiveMethods.getEmpCode() ?? '0') ?? 0},
                  ),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColor.whiteColor(context),
                    backgroundImage: _getImageProvider(),
                    child: (_getImageProvider() == null)
                        ? Icon(Icons.person, color: AppColor.primaryColor(context))
                        : null,
                  ),
                ),
                const Gap(10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalKay.welcome.tr()} 👋',
                      style: AppTextStyle.text16MSecond(
                        context,
                        color: AppColor.whiteColor(context),
                      ),
                    ),
                    Text(
                      empName.split(' ').take(3).join(' '),
                      style: AppTextStyle.text14MPrimary(
                        context,
                        color: AppColor.whiteColor(context),
                      ).copyWith(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                _buildNotificationIcon(context),
              ],
            ),
            const Gap(10),
            widget.child,
          ],
        ),
      ),
    );
  }

  ImageProvider? _getImageProvider() {
    try {
      final base64 = _imageBase64FromServer ?? _cachedBase64Image;
      if (base64 != null && base64.isNotEmpty) {
        return MemoryImage(base64Decode(base64));
      }
    } catch (_) {}
    return null;
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () async {
            final homeCubit = context.read<HomeCubit>();
            final pagePrivID = homeCubit.state.vacationStatus.data?.pagePrivID ?? 0;
            await homeCubit.loadVacationAdditionalPrivilages(
              pageID: 14,
              empId: int.tryParse(HiveMethods.getEmpCode() ?? '0') ?? 0,
            );
            NavigatorMethods.pushNamed(
              context,
              RoutesName.notificationScreen,
              arguments: {'pagePrivID': pagePrivID},
            );
          },
          icon: Icon(Icons.notifications, size: 40, color: AppColor.whiteColor(context)),
        ),
        Positioned(
          right: 0,
          top: 5,
          child: BlocBuilder<NotifictionCubit, NotificationState>(
            builder: (context, state) {
              int cachedCount = HiveMethods.getNotificationCount() ?? 0;
              final dataList = state.reqCountStatus.data?.data ?? [];
              final list = state.employeeRequestsNotify.data?.data ?? [];
              final total5007 =
                  state.requestDynamic5007.data?.fold(0, (sum, item) => sum + item.requestCount) ??
                  0;
              final total5008 =
                  state.requestDynamic5008.data?.fold(0, (sum, item) => sum + item.requestCount) ??
                  0;

              final totalDynamic = total5007 + total5008;

              final totalReqCount = dataList.fold<int>(0, (sum, item) => sum + item.reqCount);
              final totalStatusesCount = list.length;

              final serverCount = totalReqCount + totalStatusesCount + totalDynamic;

              if (serverCount != cachedCount) {
                cachedCount = serverCount;
                HiveMethods.saveNotificationCount(serverCount);
              }

              if (cachedCount == 0) return const SizedBox();

              return Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  '$cachedCount',
                  style: AppTextStyle.text14RGrey(
                    context,
                    color: AppColor.whiteColor(context),
                  ).copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
