// lib/config/api_config.dart

import 'app_config.dart';

class ApiConfig {
  static String get baseUrl => AppConfig.baseUrl;

  static String get login => "$baseUrl/api/login/";
  static String get refresh => "$baseUrl/api/token/refresh/";
  static String get employees => "$baseUrl/api/employees-list/";

  // Health check untuk memastikan API MANPRO benar-benar dapat diakses.
  static String get health => "$baseUrl/api/health/";

  /// Daftar path yang TIDAK butuh Authorization header
  /// dan TIDAK boleh masuk logic auto-refresh token.
  static const List<String> authFreeEndpoints = [
    "/api/login/",
    "/api/token/refresh/",
    "/api/health/",
  ];
}
