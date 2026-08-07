// lib/service/auth_interceptor.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_provider_data/main.dart'; // navigatorKey
import 'package:flutter_provider_data/utils/app_logger.dart';
import 'token_storage.dart';
import 'auth_service.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final AuthService _authService = AuthService();
  final Dio dio;

  AuthInterceptor(this.dio);

  // Guard supaya kalau banyak request 401 bersamaan,
  // proses refresh token cuma jalan SEKALI.
  Completer<bool>? _refreshCompleter;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();

    AppLogger.d("Interceptor jalan untuk: ${options.uri}");

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      AppLogger.w("Token kosong, request jalan tanpa Authorization header");
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    AppLogger.e(
      "onError ${err.requestOptions.uri}",
      "status: $statusCode",
    );

    // Bukan 401 → gak ada urusan sama interceptor ini, lempar aja errornya.
    if (statusCode != 401) {
      return handler.next(err);
    }

    AppLogger.w("401 detected, mencoba refresh token...");
    final refreshed = await _refreshTokenSafely();

    if (!refreshed) {
      AppLogger.w("Refresh gagal, logout user");
      await TokenStorage.clear();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
      return handler.next(err);
    }

    // Refresh berhasil → retry request yang gagal tadi dengan token baru
    try {
      final newToken = await TokenStorage.getAccessToken();
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';

      AppLogger.d("Retry request ke: ${opts.uri}");
      final cloneReq = await dio.fetch(opts);
      return handler.resolve(cloneReq);
    } catch (e) {
      AppLogger.e("Retry gagal", e);
      return handler.next(err);
    }
  }

  /// Mencegah beberapa request yang 401 bersamaan
  /// memicu banyak kali refresh token secara paralel.
  /// Request kedua dst akan "numpang nunggu" hasil refresh yang sudah berjalan.
  Future<bool> _refreshTokenSafely() {
    if (_refreshCompleter != null) {
      AppLogger.d("Refresh udah jalan, numpang nunggu hasilnya...");
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    _authService.refreshToken().then((result) {
      _refreshCompleter?.complete(result);
      _refreshCompleter = null;
    }).catchError((e) {
      AppLogger.e("Error saat refresh token", e);
      _refreshCompleter?.complete(false);
      _refreshCompleter = null;
    });

    return _refreshCompleter!.future;
  }
}

























/*
import 'package:dio/dio.dart';
import 'token_storage.dart';
import 'auth_service.dart';
import 'package:flutter_provider_data/main.dart'; // untuk akses navigatorKey

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final AuthService _authService = AuthService();
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();

    // 🔎 Tambahin log di sini
    print("➡️ Interceptor jalan untuk : ${options.uri}");
    print("🔑 Token dari storage halo: $token");

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print("✅ Header Authorization ditambahkan");
    } else {
      print("⚠️ Token kosong, header nggak ditambahin");
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print(
        "❌ Interceptor onError: ${err.response?.statusCode} ${err.requestOptions.uri}");

    if (err.response?.statusCode == 401) {
      print("⚠️ 401 detected, mencoba refresh token...");
      final refreshed = await _authService.refreshToken();

      if (refreshed) {
        final newToken = await TokenStorage.getAccessToken();
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';

        print("🔄 Token baru dipakai: $newToken");
        print("🔁 Retry request ke: ${opts.uri}");

        try {
          final cloneReq = await dio.fetch(opts);
          return handler.resolve(cloneReq);
        } catch (e) {
          print("💥 Retry gagal: $e");
          return handler.next(err);
        }
      } else {
        print("🚪 Refresh gagal, logout user");
        await TokenStorage.clear();
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    }
    handler.next(err);
  }
}
*/