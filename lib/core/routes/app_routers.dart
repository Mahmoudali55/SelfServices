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

      case RoutesName.resignationRequestScreen:
        return MaterialPageRoute(
          builder: (_) => ResignationRequestScreen(
            empCode: args['empId'] as int,
            resignationModel: args['resignationRequestmodel'],
          ),
        );

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

      case RoutesName.transferrequest:
        return MaterialPageRoute(
          builder: (_) => TransferRequestScreen(
            empCode: args['empId'] as int,
            pagePrivID: args['PagePrivID'],
            transferModel: args['getAllTransferModel'],
          ),
        );

      case RoutesName.solfaRequestScreen:
        return MaterialPageRoute(
          builder: (_) => solfaRequestScreen(empId: args['empId'], solfaItem: args['solfaItem']),
        );

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
      case RoutesName.solfaDetailsScreen:
        return MaterialPageRoute(
          builder: (_) => SolfaDetailsScreen(request: settings.arguments as SolfaItem),
        );
      case RoutesName.rateApp:
        return MaterialPageRoute(builder: (_) => const RateAppScreen());
      case RoutesName.suggestions:
        return MaterialPageRoute(builder: (_) => const SuggestionsScreen());
      case RoutesName.requestHistoryDetilesScreen:
        return MaterialPageRoute(
          builder: (_) => RequestHistoryDetilesScreen(
            request: settings.arguments as VacationRequestOrdersModel,
          ),
        );
      case RoutesName.resignationDetailsScreen:
        return MaterialPageRoute(
          builder: (_) =>
              ResignationDetailsScreen(request: settings.arguments as GetAllResignationModel),
        );
      case RoutesName.transferDetailsScreen:
        return MaterialPageRoute(
          builder: (_) => TransferDetailsScreen(request: settings.arguments as GetAllTransferModel),
        );
      case RoutesName.backFromVacationDetailsScreen:
        return MaterialPageRoute(
          builder: (_) => BackFromVacationDetailsScreen(
            request: settings.arguments as GetRequestVacationBackModel,
          ),
        );
      case RoutesName.ticketDetailsScreen:
        return MaterialPageRoute(
          builder: (_) => TicketDetailsScreen(request: settings.arguments as AllTicketModel),
        );
      case RoutesName.carDetailsScreen:
        return MaterialPageRoute(
          builder: (_) => CarDetailsScreen(request: settings.arguments as GetAllCarsModel),
        );
      case RoutesName.housingAllowanceDetailsScreen:
        return MaterialPageRoute(
          builder: (_) => HousingAllowanceDetailsScreen(
            request: settings.arguments as GetAllHousingAllowanceModel,
          ),
        );
      case RoutesName.generalRequestDetailsScreen:
        return MaterialPageRoute(
          builder: (_) =>
              GeneralRequestDetailsScreen(request: settings.arguments as DynamicOrderModel),
        );
      case RoutesName.faceRecognitionAttendanceScreen:
        return MaterialPageRoute(builder: (_) => const FaceRecognitionAttendanceScreen());
      case RoutesName.studentFaceRegistrationScreen:
        return MaterialPageRoute(builder: (_) => const EmployeesFaceRegistrationScreen());
      default:
        return null;
    }
  }
}
