import 'package:flutter/foundation.dart';

/// AppConfig manages configurable base URLs and environment settings.
class AppConfig {
  AppConfig._();

  /// Toggle to true if you want to run against local Python backend on localhost:8000
  static const bool useLocalhostBackend = false;

  /// Production 24/7 Render backend base URL: https://backend-sir-app-live.onrender.com
  static String get baseUrl {
    if (useLocalhostBackend) {
      if (kIsWeb) {
        return 'http://localhost:8000';
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8000';
      }
      return 'http://localhost:8000';
    }
    return 'https://backend-sir-app-live.onrender.com';
  }
}

/// Centralized API configuration for production backend access.
class ApiConfig {
  ApiConfig._();

  /// Production 24/7 Render backend base URL
  static String get baseUrl => AppConfig.baseUrl;
}
