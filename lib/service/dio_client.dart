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
      // TIDAK pasang validateStatus di sini
      // biar status 401 auto-throw sebagai DioException
      // dan ke-tangkep di AuthInterceptor.onError()
    ),
  );

  static Dio get instance {
    if (_dio.interceptors.isEmpty) {
      _dio.interceptors.add(AuthInterceptor(_dio));
    }
    return _dio;
  }
}
