import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<List<int>> getSecureKey() async {
  const storage = FlutterSecureStorage();
  String? key;
  
  try {
    key = await storage.read(key: 'hive_secure_key');
  } catch (e) {
    // If decryption fails (e.g. BadPaddingException), delete the corrupted key
    debugPrint('Secure storage decryption failed, deleting key: $e');
    await storage.delete(key: 'hive_secure_key');
    key = null;
  }

  if (key == null) {
    final secureKey = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    await storage.write(key: 'hive_secure_key', value: base64UrlEncode(secureKey));
    return secureKey;
  }

  return base64Url.decode(key);
}
