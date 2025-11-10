import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static final ValueNotifier<String> baseUrlNotifier = ValueNotifier('https://delta-asg.com:57513');

  static String get baseUrl => baseUrlNotifier.value;

  static Future<void> setBaseUrl(String url) async {
    baseUrlNotifier.value = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', url);
  }

  static Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrlNotifier.value = prefs.getString('baseUrl') ?? 'https://delta-asg.com:57513';
  }
}
