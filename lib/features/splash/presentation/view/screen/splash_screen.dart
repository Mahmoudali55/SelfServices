import 'package:flutter/material.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/utils/navigator_methods.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3)).then(
      (value) => HiveMethods.getToken() != null
          ? NavigatorMethods.pushNamedAndRemoveUntil(context, RoutesName.loginScreen)
          : NavigatorMethods.pushNamedAndRemoveUntil(context, RoutesName.onboardingScreen),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset('assets/global_icon/compLogo.png')));
  }
}
