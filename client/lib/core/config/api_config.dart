import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    // If it's running on Web, use localhost (assumes backend and frontend are on same host or properly configured CORS)
    if (kIsWeb) {
      return 'http://localhost:18001';
    }

    // If running on an Android emulator, loopback is 10.0.2.2.
    // Otherwise, we default to localhost (good for iOS simulator and desktop).
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:18001';
    }

    return 'http://localhost:18001';
  }
}
