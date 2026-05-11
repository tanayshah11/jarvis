import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String _localIp = '10.20.225.40';

  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    // Physical device uses IP, simulator/emulator uses localhost
    if (Platform.isIOS || Platform.isAndroid) {
      return 'http://$_localIp:8000';
    }
    return 'http://localhost:8000';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
