// lib/service/auth_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_provider_data/utils/app_logger.dart';
import '../config/api_config.dart';
import 'dio_client.dart';
import 'token_storage.dart';

/// Hasil login yang lebih deskriptif, bukan cuma true/false.
/// Biar UI bisa nampilin pesan yang sesuai ke user.
class LoginResult {
  final bool success;
  final String? errorMessage;

  LoginResult.success()
      : success = true,
        errorMessage = null;
  LoginResult.failure(this.errorMessage) : success = false;
}

class AuthService {
  // Pakai authDio yang udah disiapin di DioClient —
  // dio polos TANPA AuthInterceptor, supaya gak ada risiko infinite loop
  // saat login/refresh gagal dengan status 401.
  final Dio _dio = DioClient.authDio;

  Future<LoginResult> login({
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

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        final user = data['user'];

        if (accessToken == null || refreshToken == null) {
          AppLogger.e("Login sukses tapi token gak lengkap dari server");
          return LoginResult.failure("Respon server tidak lengkap");
        }

        await TokenStorage.saveTokens(
          access: accessToken,
          refresh: refreshToken,
        );

        // Jangan print isi token-nya, cukup konfirmasi tersimpan.
        AppLogger.i("Login berhasil, token tersimpan");

        if (user != null) {
          await TokenStorage.saveUserProfile({
            'id': user['id'],
            'username': user['username'],
            'email': user['email'],
            'first_name': user['first_name'],
            'last_name': user['last_name'],
            'groups': user['groups'],
            'photo': user['photo'],
          });
        }

        return LoginResult.success();
      }

      // Status selain 200 (400/401/403/dll) → ambil pesan dari server kalau ada
      final serverMessage = _extractErrorMessage(response.data);
      AppLogger.w(
          "Login gagal, status: ${response.statusCode}, pesan: $serverMessage");
      return LoginResult.failure(
          serverMessage ?? "Username atau password salah");
    } on DioException catch (e) {
      AppLogger.e("Login error (koneksi/timeout)", e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return LoginResult.failure("Koneksi timeout, coba lagi");
      }
      if (e.type == DioExceptionType.connectionError) {
        return LoginResult.failure("Tidak ada koneksi internet");
      }
      return LoginResult.failure("Terjadi kesalahan, coba lagi");
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refresh = await TokenStorage.getRefreshToken();
      if (refresh == null) {
        AppLogger.w("Refresh token kosong, gak bisa refresh");
        return false;
      }

      final response = await _dio.post(
        ApiConfig.refresh,
        data: {"refresh": refresh},
      );

      if (response.statusCode == 200) {
        final newAccess = response.data['access'];
        final newRefresh = response.data['refresh'];

        if (newAccess == null) {
          AppLogger.w("Refresh sukses tapi access token null");
          return false;
        }

        await TokenStorage.saveTokens(
          access: newAccess,
          refresh: newRefresh ?? refresh,
        );
        AppLogger.i("Refresh token berhasil");
        return true;
      }

      AppLogger.w("Refresh token gagal, status: ${response.statusCode}");
      return false;
    } on DioException catch (e) {
      AppLogger.e("Refresh token error", e);
      return false;
    }
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map) {
      // Sesuaikan sama format error response Django REST Framework kamu.
      // Umumnya: {"detail": "..."} atau {"non_field_errors": ["..."]}
      if (responseData['detail'] != null) {
        return responseData['detail'].toString();
      }
      if (responseData['non_field_errors'] != null) {
        final errors = responseData['non_field_errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
      }
    }
    return null;
  }
}




































/*
import 'package:dio/dio.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import '../config/api_config.dart';
import 'token_storage.dart';
// import 'dio_client.dart'; // tambahkan ini

class AuthService {
  // final Dio _dio = DioClient.instance; // pakai dio utama

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {
        "Content-Type": "application/json",
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      followRedirects: false,
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

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        final user = data['user'];

        if (accessToken == null || refreshToken == null) {
          return false;
        }

        await TokenStorage.saveTokens(
          access: accessToken,
          refresh: refreshToken,
        );

        logPrint("✅ Token tersimpan: $accessToken");

        if (user != null) {
          await TokenStorage.saveUserProfile({
            'id': user['id'],
            'username': user['username'],
            'email': user['email'],
            'first_name': user['first_name'],
            'last_name': user['last_name'],
            'groups': user['groups'],
            'photo': user['photo'],
          });
        }

        return true;
      }
      return false;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refresh = await TokenStorage.getRefreshToken();
      if (refresh == null) return false;

      final response = await _dio.post(
        ApiConfig.refresh,
        data: {"refresh": refresh},
      );

      if (response.statusCode == 200) {
        final newAccess = response.data['access'];
        final newRefresh = response.data['refresh'];

        if (newAccess == null) return false;

        await TokenStorage.saveTokens(
          access: newAccess,
          refresh: newRefresh ?? refresh,
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
*/