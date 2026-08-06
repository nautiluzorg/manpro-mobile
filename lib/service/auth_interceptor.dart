// lib/service/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'token_storage.dart';
import 'auth_service.dart';
import 'package:flutter_provider_data/main.dart'; // untuk akses navigatorKey

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final AuthService _authService = AuthService();
  final Dio dio; // dio instance utama app (yang dipasangi interceptor ini)

  AuthInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _authService.refreshToken();

      if (refreshed) {
        // retry request yang gagal pakai token baru
        final newToken = await TokenStorage.getAccessToken();
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';

        try {
          final cloneReq = await dio.fetch(opts);
          return handler.resolve(cloneReq);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // refresh token juga expired/invalid -> baru bener2 logout
        await TokenStorage.clear();
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/', // route login page lo di main.dart
          (route) => false,
        );
      }
    }
    handler.next(err);
  }
}
