import 'dart:convert';
import 'package:flutter_provider_data/utils/logger.dart';

/// Helper untuk parsing JSON dengan aman.
/// Menangani kasus ketika API mengirim String yang berisi JSON
/// atau langsung Map/List.
class JsonSafeParse {
  /// Parse response body yang bisa jadi String JSON atau Map langsung.
  static dynamic parse(dynamic data) {
    logPrint("🔍 JsonSafeParse input type: ${data.runtimeType}");

    if (data == null) return null;

    // Jika sudah Map atau List, gunakan langsung
    if (data is Map<String, dynamic> || data is List) {
      return data;
    }

    // Jika String, coba decode
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return null;
      try {
        final decoded = jsonDecode(trimmed);
        logPrint("🔍 JsonSafeParse decoded type: ${decoded.runtimeType}");
        return decoded;
      } catch (e) {
        logPrint("❌ JsonSafeParse decode error: $e");
        return null;
      }
    }

    logPrint("⚠️ JsonSafeParse unexpected type: ${data.runtimeType}");
    return data;
  }

  /// Parse dengan ekspektasi Map<String, dynamic>
  static Map<String, dynamic> parseMap(dynamic data) {
    final parsed = parse(data);
    if (parsed is Map<String, dynamic>) return parsed;
    logPrint("❌ JsonSafeParse expected Map but got: ${parsed?.runtimeType}");
    return {};
  }

  /// Parse dengan ekspektasi List
  static List<dynamic> parseList(dynamic data) {
    final parsed = parse(data);
    if (parsed is List) return parsed;
    logPrint("❌ JsonSafeParse expected List but got: ${parsed?.runtimeType}");
    return [];
  }

  /// Parse field yang bisa jadi String JSON di dalam Map
  static dynamic parseField(dynamic fieldValue) {
    if (fieldValue == null) return null;
    if (fieldValue is String) {
      final trimmed = fieldValue.trim();
      if (trimmed.isEmpty) return null;
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          return jsonDecode(trimmed);
        } catch (_) {
          return fieldValue;
        }
      }
      return fieldValue;
    }
    return fieldValue;
  }
}
