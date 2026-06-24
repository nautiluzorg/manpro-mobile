// lib/utils/safe_map_extension.dart

extension SafeMapExtension on Map<String, dynamic> {
  Map<String, dynamic> get safeMap => this;

  String safeString(String key, {String fallback = ''}) {
    final value = this[key];
    if (value == null) return fallback;
    return value.toString();
  }

  int safeInt(String key, {int fallback = 0}) {
    final value = this[key];
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  double safeDouble(String key, {double fallback = 0.0}) {
    final value = this[key];
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  bool safeBool(String key, {bool fallback = false}) {
    final value = this[key];
    if (value == null) return fallback;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  List<T> safeList<T>(String key, T Function(dynamic) fromJson) {
    final value = this[key];
    if (value == null || value is! List) return [];
    return value.map((e) => fromJson(e)).toList();
  }

  Map<String, dynamic>? safeNullableMap(String key) {
    final value = this[key];
    if (value == null || value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }
}
