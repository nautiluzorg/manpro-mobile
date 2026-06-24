// lib/service/token_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _accessToken = "ACCESS_TOKEN";
  static const _refreshToken = "REFRESH_TOKEN";

  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(key: _accessToken, value: access);
    await _storage.write(key: _refreshToken, value: refresh);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessToken);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshToken);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  static const _userProfile = "USER_PROFILE";

  static Future<void> saveUserProfile(Map<String, dynamic> data) async {
    await _storage.write(key: _userProfile, value: jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final raw = await _storage.read(key: _userProfile);
    if (raw == null) return null;
    return jsonDecode(raw);
  }
}
