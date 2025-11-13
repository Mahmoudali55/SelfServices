part of 'app_routers_import.dart';

class AppRouters {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    dynamic args;
    if (settings.arguments != null) args = settings.arguments;
    switch (settings.name) {
      case RoutesName.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RoutesName.homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen(name: args as String));
      case RoutesName.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RoutesName.layoutScreen:
        return MaterialPageRoute(
          builder: (_) {
            final args = settings.arguments as Map<String, dynamic>;
            return LayoutScreen(
              restoreIndex: args['restoreIndex'] is int
                  ? args['restoreIndex']
                  : int.tryParse(args['restoreIndex'].toString()) ?? 0,
              initialType: (args['initialType'] ?? AppLocalKay.leave.tr()) as String,
            );
          },
        );

      case RoutesName.onboardingScreen:
        return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
      case RoutesName.requestLeaveScreen:
        return MaterialPageRoute(
          builder: (_) => RequestLeaveScreen(
            pagePrivID: args['PagePrivID'],
            empCode: args['empcode'],
            vacationRequestOrdersModel: args['vacationRequestOrdersModel'],
          ),
        );
      case RoutesName.backFromVacationScreen:
        return MaterialPageRoute(
          builder: (_) => BackFromVacationScreen(
            empcode: args['empcode'],
            pagePrivID: args['PagePrivID'],
            vacationBackRequestModel: args['vacationRequestOrdersModelBack'],
          ),
        );
      case RoutesName.requestAletterScreen:
        return MaterialPageRoute(builder: (_) => const RequestAletterScreen());
      case RoutesName.requestAtrainingCourseScreen:
        return MaterialPageRoute(builder: (_) => const RequestAtrainingCourseScreen());
      case RoutesName.resignationRequestScreen:
        return MaterialPageRoute(
          builder: (_) => ResignationRequestScreen(
            empCode: args['empId'] as int,
            resignationModel: args['resignationRequestmodel'],
          ),
        );
      case RoutesName.passportapplicationScreen:
        return MaterialPageRoute(builder: (_) => const PassportApplicationScreen());
      case RoutesName.requestToIssueTicketsScreen:
        return MaterialPageRoute(
          builder: (_) => RequestToIssueTicketsScreen(
            empCode: args['empId'],
            allTicketModel: args['allTicketModel'],
          ),
        );
      case RoutesName.housingAllowanceRequestcreen:
        return MaterialPageRoute(
          builder: (_) => HousingAllowanceRequestScreen(
            empCode: args['empId'] as int,
            model: args['housingAllowancemodel'],
          ),
        );
      case RoutesName.requestACar:
        return MaterialPageRoute(
          builder: (_) => RequestACarScreen(empCode: args['empId'] as int, car: args['requestCar']),
        );
      case RoutesName.employmentApplication:
        return MaterialPageRoute(builder: (_) => const EmploymentApplicationScreen());
      case RoutesName.transferrequest:
        return MaterialPageRoute(
          builder: (_) => TransferRequestScreen(
            empCode: args['empId'] as int,
            pagePrivID: args['PagePrivID'],
            transferModel: args['getAllTransferModel'],
          ),
        );
      case RoutesName.evaluatingAnemployeesPerformanceScreen:
        return MaterialPageRoute(builder: (_) => const EvaluatingAnemployeesPerformanceScreen());
      case RoutesName.solfaRequestScreen:
        return MaterialPageRoute(
          builder: (_) => solfaRequestScreen(empId: args['empId'], solfaItem: args['solfaItem']),
        );
      case RoutesName.employeewarning:
        return MaterialPageRoute(builder: (_) => const EmployeeWarningScreen());
      case RoutesName.notificationScreen:
        return MaterialPageRoute(
          builder: (_) => NotificationScreen(pagePrivID: args['pagePrivID']),
        );
      case RoutesName.privacyScreen:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());
      case RoutesName.securitySettingsScreen:
        return MaterialPageRoute(builder: (_) => const SecuritySettingsScreen());
      case RoutesName.pendingRequests:
        return MaterialPageRoute(builder: (_) => PendingRequestsScreen(type: args['type']));
      case RoutesName.pendingRequestDetailScreen:
        return MaterialPageRoute(
          builder: (_) => PendingRequestDetailScreen(request: args['request']),
        );
      case RoutesName.helpCenterScreen:
        return MaterialPageRoute(builder: (_) => const HelpCenterScreen());
      case RoutesName.chatBotScreen:
        return MaterialPageRoute(builder: (_) => const ChatBotScreen());
      case RoutesName.profileScreen:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case RoutesName.attendanceScreen:
        return MaterialPageRoute(builder: (_) => const AttendanceScreen());
      case RoutesName.salaryvocabulary:
        return MaterialPageRoute(builder: (_) => const SalaryVocabularyScreen());
      case RoutesName.timeSheetScreen:
        return MaterialPageRoute(builder: (_) => const TimeSheetScreen());
      case RoutesName.sesidChangeRequestScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SesidChangeRequestScreen(dynamicOrderModel: args?['request']),
        );
      case RoutesName.requestgeneral:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RequestGeneralScreen(dynamicOrderModel: args?['request']),
        );
      case RoutesName.rateApp:
        return MaterialPageRoute(builder: (_) => const RateAppScreen());
      case RoutesName.suggestions:
        return MaterialPageRoute(builder: (_) => const SuggestionsScreen());
      default:
        return null;
    }
  }
}
