// lib/utils/app_logger.dart
import 'package:flutter/foundation.dart';

/// Logger khusus untuk service/network layer.
/// Dipisah dari logger.dart (yang isinya widget helper)
/// biar file service kayak auth_interceptor gak perlu
/// import material.dart, google_fonts, dll cuma buat logging.
class AppLogger {
  static void d(String message) {
    if (kDebugMode) print("🐛 $message");
  }

  static void i(String message) {
    if (kDebugMode) print("ℹ️ $message");
  }

  static void w(String message) {
    if (kDebugMode) print("⚠️ $message");
  }

  static void e(String message, [Object? error]) {
    if (kDebugMode) print("❌ $message ${error ?? ''}");
  }
}
