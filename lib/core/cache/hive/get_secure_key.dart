import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<List<int>> getSecureKey() async {
  const storage = FlutterSecureStorage();
  String? key = await storage.read(key: 'hive_secure_key');

  if (key == null) {
    final secureKey = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    await storage.write(key: 'hive_secure_key', value: base64UrlEncode(secureKey));
    return secureKey;
  }

  return base64Url.decode(key);
}
