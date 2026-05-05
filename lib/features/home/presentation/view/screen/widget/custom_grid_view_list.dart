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

class CustomGridViewList extends StatefulWidget {
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

  @override
  State<CustomGridViewList> createState() => _CustomGridViewListState();
}

class _CustomGridViewListState extends State<CustomGridViewList>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  static const Map<int, _ServiceStyle> _serviceStyles = {
    1: _ServiceStyle(
      icon: Icons.beach_access_rounded,
      gradientColors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
    ),
    2: _ServiceStyle(
      icon: Icons.flight_land_rounded,
      gradientColors: [Color(0xFF11998E), Color(0xFF38EF7D)],
    ),
    3: _ServiceStyle(
      icon: Icons.account_balance_wallet_rounded,
      gradientColors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
    ),
    4: _ServiceStyle(
      icon: Icons.exit_to_app_rounded,
      gradientColors: [Color(0xFFDA4453), Color(0xFF89216B)],
    ),
    5: _ServiceStyle(
      icon: Icons.airplane_ticket_rounded,
      gradientColors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
    ),
    6: _ServiceStyle(
      icon: Icons.home_work_rounded,
      gradientColors: [Color(0xFFF7971E), Color(0xFFFFD200)],
    ),
    7: _ServiceStyle(
      icon: Icons.directions_car_filled_rounded,
      gradientColors: [Color(0xFF0F9B58), Color(0xFF00BF8F)],
    ),
    8: _ServiceStyle(
      icon: Icons.swap_horiz_rounded,
      gradientColors: [Color(0xFF434343), Color(0xFF000000)],
    ),
    9: _ServiceStyle(
      icon: Icons.phone_android_rounded,
      gradientColors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
    ),
    10: _ServiceStyle(
      icon: Icons.assignment_rounded,
      gradientColors: [Color(0xFFEB5757), Color(0xFFB06AB3)],
    ),
  };

  _ServiceStyle get _style =>
      _serviceStyles[widget.service.id] ??
      const _ServiceStyle(
        icon: Icons.miscellaneous_services_rounded,
        gradientColors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
      );

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToService(BuildContext context) {
    final pageItem = widget.cubit.state.vacationStatus.data;
    final empId = widget.widget.empId ?? 0;

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

    routes[widget.service.id]?.call();
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return GestureDetector(
      onTapDown: (_) => _animController.forward(),
      onTapUp: (_) {
        _animController.reverse();
        _navigateToService(context);
      },
      onTapCancel: () => _animController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: style.gradientColors[0].withOpacity(0.18),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: style.gradientColors[0].withOpacity(0.10),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gradient Icon Box — stays fully inside the card
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: style.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: style.gradientColors[0].withOpacity(0.40),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  style.icon,
                  color: Colors.white,
                  size: 30.sp,
                ),
              ),
              Gap(12.h),
              // Service label — same horizontal padding as the icon
              Text(
                widget.service.getName(widget.langCode),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.text14MPrimary(
                  context,
                  color: AppColor.blackColor(context),
                ).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceStyle {
  final IconData icon;
  final List<Color> gradientColors;

  const _ServiceStyle({
    required this.icon,
    required this.gradientColors,
  });
}
