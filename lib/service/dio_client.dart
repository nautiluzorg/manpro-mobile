// lib/service/dio_client.dart

import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  static bool _authInterceptorAdded = false;

  /// Dio biasa, PAKAI AuthInterceptor (auto attach token + auto refresh).
  /// Ini yang dipakai buat manggil API yang butuh login (employees, dll).
  static Dio get instance {
    if (!_authInterceptorAdded) {
      _dio.interceptors.add(AuthInterceptor(_dio));
      _authInterceptorAdded = true;
    }
    return _dio;
  }

  /// Dio "polos" TANPA AuthInterceptor.
  /// WAJIB dipakai khusus buat call ke endpoint login & refresh token,
  /// supaya gak nyangkut ke interceptor dan gak bisa infinite loop.
  static final Dio authDio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
}































/*
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static bool _authInterceptorAdded =
      false; // ✅ flag eksplisit, gak gantung ke isEmpty

  static Dio get instance {
    if (!_authInterceptorAdded) {
      _dio.interceptors.add(AuthInterceptor(_dio));
      _authInterceptorAdded = true;
    }
    return _dio;
  }
}
*/