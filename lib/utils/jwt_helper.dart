// lib/utils/jwt_helper.dart
import 'dart:convert';

class JwtHelper {
  /// Decode payload JWT menjadi Map
  /// Return null jika token invalid
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null; // Invalid JWT
      }

      final payloadBase64 = parts[1];
      final normalized = base64Url.normalize(payloadBase64);
      final decoded = utf8.decode(base64Url.decode(normalized));

      final payload = jsonDecode(decoded) as Map<String, dynamic>;
      return payload;
    } catch (_) {
      return null; // Jika ada error decode
    }
  }

  /// Cek apakah JWT expired
  /// Tambahkan bufferSeconds untuk toleransi sinkronisasi
  static bool isExpired(Map<String, dynamic>? payload,
      {int bufferSeconds = 5}) {
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return true;

    try {
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now()
          .add(Duration(seconds: bufferSeconds))
          .isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  /// Ambil claim tertentu, misal 'username' atau 'groups'
  static dynamic getClaim(Map<String, dynamic>? payload, String claim) {
    if (payload == null) return null;
    return payload[claim];
  }
}
