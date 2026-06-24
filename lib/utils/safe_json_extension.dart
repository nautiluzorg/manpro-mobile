import 'dart:convert';
import 'package:flutter_provider_data/utils/logger.dart';

extension SafeJsonExtension on Map<String, dynamic> {
  Map<String, dynamic> safeMap(String key) {
    final dynamic value = this[key];
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return {};
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (e) {
        logPrint("❌ safeMap[$key] decode error: $e"); // ✅ hanya log kalau error
      }
    }
    return {};
  }

  List<dynamic> safeList(String key) {
    final dynamic value = this[key];
    if (value == null) return [];
    if (value is List) return value;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return [];
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) return decoded;
      } catch (e) {
        logPrint(
            "❌ safeList[$key] decode error: $e"); // ✅ hanya log kalau error
      }
    }
    return [];
  }

  String safeString(String key) {
    final dynamic value = this[key];
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  int safeInt(String key) {
    final dynamic value = this[key];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double safeDouble(String key) {
    final dynamic value = this[key];
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  bool safeBool(String key) {
    final dynamic value = this[key];
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false;
  }

  T? safeObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final map = safeMap(key);
    if (map.isEmpty) return null;
    try {
      return fromJson(map);
    } catch (e) {
      logPrint("❌ safeObject[$key] parse error: $e"); // ✅ hanya log kalau error
      return null;
    }
  }

  List<T> safeObjectList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson, {
    required T defaultValue,
  }) {
    final list = safeList(key);
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        try {
          return fromJson(item);
        } catch (e) {
          logPrint(
              "❌ safeObjectList[$key] parse error: $e"); // ✅ hanya log kalau error
          return defaultValue;
        }
      }
      return defaultValue;
    }).toList();
  }
}
