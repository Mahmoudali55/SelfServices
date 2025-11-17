import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/home/data/model/service_Item_model.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/home/presentation/view/screen/home_screen.dart';

class CustomGridViewList extends StatelessWidget {
  const CustomGridViewList({
    super.key,
    required this.cubit,
    required this.service,
    required this.widget,
    required this.langCode,
  });

  final HomeCubit cubit;
  final ServiceItem service;
  final HomeScreen widget;
  final String langCode;

  void _navigateToService(BuildContext context) {
    final pageItem = cubit.state.vacationStatus.data;
    final empId = widget.empId ?? 0;

    final Map<int, VoidCallback> routes = {
      1: () => NavigatorMethods.pushNamed(
        context,
        RoutesName.requestLeaveScreen,
        arguments: {'PagePrivID': pageItem?.pagePrivID ?? 0, 'empcode': empId},
      ),
      2: () => NavigatorMethods.pushNamed(
        context,
        RoutesName.backFromVacationScreen,
        arguments: {'empcode': empId, 'PagePrivID': pageItem?.pagePrivID ?? 0},
      ),
      3: () => NavigatorMethods.pushNamed(
        context,
        RoutesName.solfaRequestScreen,
        arguments: {'empId': empId},
      ),
      4: () => NavigatorMethods.pushNamed(
        context,
        RoutesName.resignationRequestScreen,
        arguments: {'empId': empId},
      ),

      5: () => NavigatorMethods.pushNamed(
        context,
        RoutesName.requestToIssueTicketsScreen,
        arguments: {'empId': empId},
      ),
      6: () => NavigatorMethods.pushNamed(
        context,
        RoutesName.housingAllowanceRequestcreen,
        arguments: {'empId': empId},
      ),
      7: () => NavigatorMethods.pushNamed(
        context,
        RoutesName.requestACar,
        arguments: {'empId': empId, 'PagePrivID': pageItem?.pagePrivID ?? 0},
      ),

      8: () => NavigatorMethods.pushNamed(
        context,
        RoutesName.transferrequest,
        arguments: {'empId': empId, 'PagePrivID': pageItem?.pagePrivID ?? 0},
      ),
      9: () => NavigatorMethods.pushNamed(context, RoutesName.sesidChangeRequestScreen),
      10: () => NavigatorMethods.pushNamed(context, RoutesName.requestgeneral),
    };

    routes[service.id]?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToService(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              service.image,
              fit: BoxFit.contain,
              height: 60,
              color: AppColor.primaryColor(context),
            ),
            const Gap(10),
            Text(
              service.getName(langCode),
              textAlign: TextAlign.center,
              style: AppTextStyle.text14MPrimary(
                context,
                color: AppColor.blackColor(context),
              ).copyWith(fontWeight: FontWeight.bold, fontSize: 15.sp),
            ),
          ],
        ),
      ),
    );
  }
}
