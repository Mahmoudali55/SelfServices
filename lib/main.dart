import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:my_template/core/cache/hive/get_secure_key.dart';
import 'package:my_template/core/network/contants.dart';
import 'package:my_template/core/theme/cubit/app_theme_cubit.dart';
import 'package:my_template/firebase_options.dart';
import 'app.dart';
import 'core/theme/theme_enum.dart';
import 'service_initialize.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Instant UI to show the app has started
    runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Starting App... / جارِ التشغيل..."),
            ],
          ),
        ),
      ),
    ));
    
    // Global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Platform Error: $error');
      return true;
    };

    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      await Hive.initFlutter();
      
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ThemeEnumAdapter());
      }

      // Robust Hive Box Opening
      Box box;
      try {
        final key = await getSecureKey();
        box = await Hive.openBox('app', encryptionCipher: HiveAesCipher(key));
      } catch (e) {
        debugPrint('Hive encryption error, attempting recovery: $e');
        // If opening with encryption fails, the key might be corrupted/mismatched.
        // Recovery: Delete the box and start fresh to prevent black screen.
        await Hive.deleteBoxFromDisk('app');
        final key = await getSecureKey();
        box = await Hive.openBox('app', encryptionCipher: HiveAesCipher(key));
      }

      final savedLang = box.get('lang', defaultValue: 'ar') as String;
      
      await EasyLocalization.ensureInitialized();
      await ServiceInitialize.initialize();
      await Constants.loadBaseUrl();

      bool isDeviceJailBroken = false;
      bool isDebugged = false;

      try {
        isDeviceJailBroken = await JailbreakRootDetection.instance.isJailBroken.timeout(
          const Duration(seconds: 2),
          onTimeout: () => false,
        );
        isDebugged = await JailbreakRootDetection.instance.isDebugged.timeout(
          const Duration(seconds: 2),
          onTimeout: () => false,
        );
      } catch (e) {
        debugPrint('Jailbreak detection failed: $e');
      }

      if (isDeviceJailBroken && !isDebugged) {
        runApp(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Device not supported / الجهاز غير مدعوم",
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
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
    } catch (e, stack) {
      debugPrint('Initialization Fatal Error: $e\n$stack');
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Initialization Error / خطأ في التشغيل',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      e.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => main(),
                      child: const Text('Retry / إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }, (error, stack) {
    debugPrint('Zoned Error: $error\n$stack');
  });
}
