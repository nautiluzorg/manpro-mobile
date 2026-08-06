// lib/service/auth_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import '../config/api_config.dart';
import 'token_storage.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        "Content-Type": "application/json",
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          "username": username.trim(),
          "password": password,
        },
      );

      logPrint("LOGIN STATUS: ${response.statusCode}");
      logPrint("LOGIN RESPONSE: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        final user = data['user'];

        if (accessToken == null || refreshToken == null) {
          logPrint("TOKEN KOSONG");
          return false;
        }

        // 1️⃣ Simpan token
        await TokenStorage.saveTokens(
          access: accessToken,
          refresh: refreshToken,
        );

        // 2️⃣ Simpan user profile (BARU)
        if (user != null) {
          await TokenStorage.saveUserProfile({
            'id': user['id'],
            'username': user['username'],
            'email': user['email'],
            'first_name': user['first_name'],
            'last_name': user['last_name'],
            'groups': user['groups'],
            'photo': user['photo'], // bisa null, aman
          });
        }

        return true;
      }

      return false;
    } on DioException catch (e) {
      logPrint("DIO ERROR: ${e.response?.data}");
      logPrint("DIO STATUS: ${e.response?.statusCode}");
      return false;
    } catch (e) {
      logPrint("UNKNOWN ERROR: $e");
      return false;
    }
  }

// Function baru
// lib/service/auth_service.dart
  Future<bool> refreshToken() async {
    try {
      final refresh = await TokenStorage.getRefreshToken();
      if (refresh == null) return false;

      final response = await _dio.post(
        ApiConfig
            .refresh, // pastikan endpoint ini ada di ApiConfig, biasanya /api/token/refresh/
        data: {"refresh": refresh},
      );

      if (response.statusCode == 200) {
        final newAccess = response.data['access'];
        final newRefresh =
            response.data['refresh']; // ada karena ROTATE_REFRESH_TOKENS=True

        if (newAccess == null) return false;

        await TokenStorage.saveTokens(
          access: newAccess,
          refresh: newRefresh ?? refresh,
        );
        return true;
      }
      return false;
    } catch (e) {
      logPrint("REFRESH ERROR: $e");
      return false;
    }
  }
}


























/*
import 'package:dio/dio.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import '../config/api_config.dart';
import 'token_storage.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        "Content-Type": "application/json",
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          "username": username.trim(),
          "password": password,
        },
      );

      logPrint("LOGIN STATUS: ${response.statusCode}");
      logPrint("LOGIN RESPONSE: ${response.data}");

      if (response.statusCode == 200) {
        final accessToken = response.data['access'];
        final refreshToken = response.data['refresh'];

        if (accessToken == null || refreshToken == null) {
          logPrint("TOKEN KOSONG");
          return false;
        }

        await TokenStorage.saveTokens(
          access: accessToken,
          refresh: refreshToken,
        );

        return true;
      }

      return false;
    } on DioException catch (e) {
      logPrint("DIO ERROR: ${e.response?.data}");
      logPrint("DIO STATUS: ${e.response?.statusCode}");
      return false;
    } catch (e) {
      logPrint("UNKNOWN ERROR: $e");
      return false;
    }
  }
}
*/
/*
class AuthService {
  final Dio _dio = Dio();

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          "username": username,
          "password": password,
        },
      );

      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];

      await TokenStorage.saveTokens(
        access: accessToken,
        refresh: refreshToken,
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
*/