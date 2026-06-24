// lib/config/app_config.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl => dotenv.env['API_URL'] ?? 'http://localhost:8000';
  static String get environment => dotenv.env['ENV'] ?? 'development';

  // Tambahkan konfigurasi lain jika perlu
  static bool get isDevelopment => environment == 'development';
  static bool get isTesting => environment == 'testing';
  static bool get isProduction => environment == 'production';
}
