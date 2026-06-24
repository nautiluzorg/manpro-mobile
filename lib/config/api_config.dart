// lib/config/api_config.dart

import 'app_config.dart';

class ApiConfig {
  static String get baseUrl => AppConfig.baseUrl;
  static String get login => "$baseUrl/api/login/";
  static String get refresh => "$baseUrl/api/token/refresh/";

  // Bisa tambah endpoint lain misal:
  static String get employees => "$baseUrl/api/employees-list/";
}
