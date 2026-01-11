import 'package:bot_toast/bot_toast.dart';
import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/routes/app_routers_import.dart';
import 'package:my_template/core/services/notification_service.dart';
import 'package:my_template/core/services/services_locator.dart';
import 'package:my_template/features/attendance/cubit/attendance_cubit.dart';
import 'package:my_template/features/attendance/cubit/face_recognition_cubit.dart';
import 'package:my_template/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:my_template/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:my_template/features/chat/presentation/cubit/group_cubit.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:my_template/features/on_boarding/presentation/view/cubit/on_boarding_cubit.dart';
import 'package:my_template/features/profile/presentation/cubit/prefile_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/setting/presentation/cubit/settting_cubit.dart';

import 'core/cache/hive/hive_methods.dart';
import 'core/routes/routes_name.dart';
import 'core/theme/style.dart';

class SelfServices extends StatefulWidget {
  const SelfServices({super.key});
  @override
  State<SelfServices> createState() => _SelfServicesState();
}

class _SelfServicesState extends State<SelfServices> {
  @override
  void initState() {
    super.initState();
    _startListeningToMessages();
  }

  void _startListeningToMessages() {
    final empCode = HiveMethods.getEmpCode();
    if (empCode != null) {
      final empCodeInt = int.tryParse(empCode);
      if (empCodeInt != null) {
        NotificationService.startListeningForNotifications(empCodeInt);
        NotificationService.startListeningForGroupNotifications(empCodeInt);
      }
    }
  }

  @override
  void dispose() {
    NotificationService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<LayoutCubit>()),
        BlocProvider(create: (context) => sl<AuthCubit>()),
        BlocProvider(create: (context) => sl<OnBoardingCubit>()),
        BlocProvider(create: (context) => sl<HomeCubit>()),
        BlocProvider(create: (context) => sl<ServicesCubit>()),
        BlocProvider(create: (context) => sl<VacationRequestsCubit>()),
        BlocProvider(create: (context) => sl<PrefileCubit>()),
        BlocProvider(create: (context) => sl<NotifictionCubit>()),
        BlocProvider(create: (context) => sl<SettingCubit>()),
        BlocProvider(create: (context) => sl<ChatCubit>()),
        BlocProvider(create: (context) => sl<GroupCubit>()),
        BlocProvider(create: (context) => sl<FaceRecognitionCubit>()),
        BlocProvider(create: (context) => sl<AttendanceCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            localizationsDelegates: [
              ...context.localizationDelegates,
              CountryLocalizations.delegate,
            ],
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            // Provide fallback for locales not supported by all delegates
            localeResolutionCallback: (locale, supportedLocales) {
              // If the locale is Urdu and CountryLocalizations doesn't support it,
              // fallback to Arabic for country picker
              if (locale?.languageCode == 'ur') {
                return locale;
              }
              return locale;
            },
            debugShowCheckedModeBanner: false,
            theme: appThemeData(context),
            initialRoute: RoutesName.splashScreen,
            onGenerateRoute: AppRouters.onGenerateRoute,
            navigatorKey: AppRouters.navigatorKey,
            builder: BotToastInit(),
            navigatorObservers: [BotToastNavigatorObserver()],
          );
        },
      ),
    );
  }
}
