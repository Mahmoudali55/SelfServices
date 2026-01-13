import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../theme/theme_enum.dart';

class HiveMethods {
  static final _box = Hive.box('app');

  static String getLang() {
    return _box.get('lang', defaultValue: 'ar');
  }

  static void updateLang(Locale locale) {
    _box.put('lang', locale.languageCode);
  }

  static String? getToken() {
    return _box.get('token');
  }

  static void updateToken(String token) {
    _box.put('token', token);
  }

  static Future<void> deleteToken() async {
    await _box.delete('token');
  }

  static bool isFirstTime() {
    return _box.get('isFirstTime', defaultValue: true);
  }

  static void updateFirstTime() {
    _box.put('isFirstTime', false);
  }

  static ThemeEnum getTheme() {
    return _box.get('theme', defaultValue: ThemeEnum.light);
  }

  static void updateThem(ThemeEnum theme) {
    _box.put('theme', theme);
  }

  static void updateEmpNameAr(String empNameAr) {
    _box.put('EMP_NAME_AR', empNameAr);
  }

  static void updateEmpNameEN(String empNameEn) {
    _box.put('EMP_NAME_EN', empNameEn);
  }

  static String? getEmpNameAR() {
    return _box.get('EMP_NAME_AR');
  }

  static String? getEmpNameEn() {
    return _box.get('EMP_NAME_EN');
  }

  static void updateEmpCode(String empCode) {
    _box.put('EMP_CODE', empCode);
  }

  static Future<void> deleteEmpCode() async {
    await _box.delete('EMP_CODE');
  }

  static String? getEmpCode() {
    return _box.get('EMP_CODE');
  }

  static void deleteEmpData() {
    _box.delete('EMP_NAME');
    _box.delete('EMP_CODE');
  }

  static void updateEmpPassword(String password) {
    _box.put('EMP_PASSWORD', password);
  }

  static String? getEmpPassword() {
    return _box.get('EMP_PASSWORD');
  }

  static Future<void> saveDeviceId(String id) async {
    await _box.put('DEVICE_ID', id);
  }

  static String? getDeviceId() {
    return _box.get('DEVICE_ID');
  }

  static const String _empIdKey = 'employee_id';

  static Future<void> saveEmpId(int id) async {
    await _box.put(_empIdKey, id);
  }

  static int? getSavedEmpId() {
    return _box.get(_empIdKey);
  }

  static Future<void> savePagePrivID(int pagePrivID) async {
    await _box.put('PAGE_PRIV_ID', pagePrivID);
  }

  static int? getPagePrivID() {
    return _box.get('PAGE_PRIV_ID');
  }

  static const String _empPhotoKey = 'EMP_PHOTO_BASE64';

  static Future<void> saveEmpPhotoBase64(String base64) async {
    await _box.put(_empPhotoKey, base64);
  }

  static String? getEmpPhotoBase64() {
    return _box.get(_empPhotoKey);
  }

  static Future<void> deleteEmpPhoto() async {
    await _box.delete(_empPhotoKey);
  }

  static const String _projectIdKey = 'PROJECT_ID';

  static Future<void> saveProjectId(int projectId) async {
    await _box.put(_projectIdKey, projectId);
  }

  static int? getProjectId() {
    return _box.get(_projectIdKey);
  }

  static Future<void> deleteProjectId() async {
    await _box.delete(_projectIdKey);
  }

  static const String _notificationCountKey = 'NOTIFICATION_COUNT';

  static Future<void> saveNotificationCount(int count) async {
    await _box.put(_notificationCountKey, count);
  }

  static int? getNotificationCount() {
    return _box.get(_notificationCountKey);
  }

  static Future<void> deleteBoxFromDisk(String empId) async {
    return _box.delete('chat_messages_$empId');
  }

  /// Clears all user-specific data while preserving app-level settings
  /// Preserves: lang, theme, isFirstTime
  /// Deletes: all user data (token, names, password, device info, etc.)
  static Future<void> clearAllUserData() async {
    // Get empId before deleting to clean up chat messages
    final empId = getEmpCode();

    // Delete all user-specific data
    await Future.wait<void>([
      // Auth data
      deleteToken(),
      deleteEmpCode(),
      _box.delete('EMP_NAME_AR'),
      _box.delete('EMP_NAME_EN'),
      _box.delete('EMP_PASSWORD'),

      // Device & session data
      _box.delete('DEVICE_ID'),
      _box.delete(_empIdKey),
      _box.delete('PAGE_PRIV_ID'),

      // User content
      deleteEmpPhoto(),
      deleteProjectId(),
      _box.delete(_notificationCountKey),
    ]);

    // Delete chat messages separately
    if (empId != null) {
      await deleteBoxFromDisk(empId);
    }
  }
}
