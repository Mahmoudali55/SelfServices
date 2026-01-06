import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:my_template/core/cache/hive/get_secure_key.dart';
import 'package:my_template/core/network/contants.dart';
import 'package:my_template/core/theme/cubit/app_theme_cubit.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

import 'app.dart';
import 'core/theme/theme_enum.dart';
import 'service_initialize.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(ThemeEnumAdapter());
  final key = await getSecureKey();
  await Hive.openBox('app', encryptionCipher: HiveAesCipher(key));
  final box = Hive.box('app');
  final savedLang = box.get('lang', defaultValue: 'ar') as String;
  await ServiceInitialize.initialize();
  await Constants.loadBaseUrl();
  final isDeviceJailBroken = await JailbreakRootDetection.instance.isJailBroken;
  final isDebugged = await JailbreakRootDetection.instance.isDebugged;
  if (isDeviceJailBroken && !isDebugged) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              AppLocalKay.device_not_supported.tr(),
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    return;
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en'), Locale('ur')],
      path: 'i18n',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      child: BlocProvider(
        create: (context) => AppThemeCubit()..initial(),
        child: const SelfServices(),
      ),
    ),
  );
}
