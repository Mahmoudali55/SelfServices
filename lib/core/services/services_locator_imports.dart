part of 'services_locator.dart';

final sl = GetIt.instance;
Future<void> initDependencies() async {
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<AppInterceptors>(() => AppInterceptors());
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerFactory<ApiConsumer>(() => DioConsumer(client: sl()));
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl()));
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<AuthRepo>(), sl<ConnectionChecker>()));
  sl.registerLazySingleton<ConnectionChecker>(() => ConnectionCheckerImpl(InternetConnection()));
  sl.registerLazySingleton<OnBoardingRepository>(() => OnBoardingRepository());
  sl.registerLazySingleton<OnBoardingCubit>(() => OnBoardingCubit(repository: sl()));
  sl.registerLazySingleton<LayoutCubit>(() => LayoutCubit());
  sl.registerLazySingleton<HomeRepoImp>(() => HomeRepoImp(sl()));
  sl.registerLazySingleton<HomeCubit>(() => HomeCubit(sl()));
  sl.registerLazySingleton<ServicesRepo>(() => ServicesRepoImpl(sl()));
  sl.registerLazySingleton<ServicesCubit>(() => ServicesCubit(sl()));
  sl.registerLazySingleton<VacationRequestsRepo>(() => VacationRequestsRepoImpl(sl()));
  sl.registerLazySingleton<VacationRequestsCubit>(() => VacationRequestsCubit(sl()));
  sl.registerLazySingleton<ProfileRepo>(() => ProfileRepoImp(sl()));
  sl.registerLazySingleton<PrefileCubit>(() => PrefileCubit(sl()));
  sl.registerLazySingleton<NotificationsRepo>(() => NotifictionRepoImpl(sl()));
  sl.registerLazySingleton<NotificationsCubit>(() => NotificationsCubit(sl()));
  sl.registerLazySingleton<RequestStatusMonitor>(() => RequestStatusMonitor(sl()));
  sl.registerLazySingleton<SettingCubit>(() => SettingCubit(sl()));
  sl.registerLazySingleton<SettingRepo>(() => SettingRepoImp(sl()));
  sl.registerLazySingleton<FaceRecognitionRepo>(() => FaceRecognitionRepo());
  sl.registerLazySingleton<AttendanceRepo>(() => AttendanceRepo());
  sl.registerLazySingleton<CameraService>(() => CameraService());
  sl.registerLazySingleton<FaceDetectionService>(() => FaceDetectionService());
  sl.registerFactory<AttendanceCubit>(() => AttendanceCubit(attendanceRepo: sl()));
  sl.registerFactory<FaceRecognitionCubit>(
    () => FaceRecognitionCubit(cameraService: sl(), faceDetectionService: sl()),
  );
  sl.registerFactory<ChatRepository>(() => ChatRepository(firestore: FirebaseFirestore.instance));
  sl.registerFactory<ChatCubit>(
    () => ChatCubit(
      repository: sl<ChatRepository>(),
      currentUserId: int.parse(HiveMethods.getEmpCode() ?? '0'),
    ),
  );
  sl.registerFactory<GroupCubit>(
    () => GroupCubit(sl<ChatRepository>(), int.parse(HiveMethods.getEmpCode() ?? '0')),
  );
}
