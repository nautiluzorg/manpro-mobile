// lib/service/auth_session.dart
import '../service/token_storage.dart';
import '../utils/jwt_helper.dart';

class AuthSession {
  static Map<String, dynamic>? _payload;

  /// Load & decode JWT dari storage
  static Future<bool> load() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      _payload = null;
      return false;
    }

    try {
      final payload = JwtHelper.decodePayload(token);

      if (JwtHelper.isExpired(payload)) {
        await TokenStorage.clear();
        _payload = null;
        return false;
      }

      _payload = payload;
      return true;
    } catch (_) {
      _payload = null;
      return false;
    }
  }

  /// Apakah user sedang login
  static bool get isAuthenticated => _payload != null;

  /// Ambil username langsung dari top-level payload
  static String? get username => _payload?['username'];

  /// First name
  static String? get firstName => _payload?['first_name'];

  /// Last name
  static String? get lastName => _payload?['last_name'];

  /// Full name (aman dari null & spasi)
  static String get fullName {
    final first = (_payload?['first_name'] ?? '').toString().trim();
    final last = (_payload?['last_name'] ?? '').toString().trim();

    if (first.isEmpty && last.isEmpty) {
      return '';
    }
    return '$first $last'.trim();
  }

  /// Ambil groups user (langsung dari top-level payload)
  static List<String> get groups {
    final rawGroups = _payload?['groups'] as List<dynamic>? ?? [];
    return rawGroups.map((e) => e.toString().toUpperCase()).toList();
  }

  /// Logout & clear session
  static Future<void> logout() async {
    _payload = null;
    await TokenStorage.clear();
  }
}
