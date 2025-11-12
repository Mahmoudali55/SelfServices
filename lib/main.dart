import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_template/core/network/contants.dart';
import 'app.dart';
import 'core/theme/cubit/app_theme_cubit.dart';
import 'service_initialize.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('app');
  final box = Hive.box('app');
  final savedLang = box.get('lang', defaultValue: 'ar') as String;
  await ServiceInitialize.initialize();
  await Constants.loadBaseUrl();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'i18n',
      fallbackLocale: const Locale('ar'),
      startLocale: Locale(savedLang),
      saveLocale: true,
      child: BlocProvider(
        create: (context) => AppThemeCubit()..initial(),
        child: const SelfServices(),
      ),
    ),
  );
}
