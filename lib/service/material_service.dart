// lib/service/material_service.dart
import 'package:dio/dio.dart';
import 'dio_client.dart';

class MaterialService {
  final Dio _dio;

  MaterialService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// ================= GOLD PILL DETAIL =================
  Future<Map<String, dynamic>> getGoldPillDetail(int id) async {
    try {
      final res = await _dio.get('/api/goldpill-detail/$id/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("GoldPill not found");
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection.");
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Request timed out.");
      }
      throw Exception(
          "Error: ${e.response?.statusCode} - ${e.response?.statusMessage}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  /// ================= CARBON PILL DETAIL =================
  Future<Map<String, dynamic>> getCarbonPillDetail(int id) async {
    try {
      final res = await _dio.get('/api/carbonpill-detail/$id/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("CarbonPill not found");
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection.");
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Request timed out.");
      }
      throw Exception(
          "Error: ${e.response?.statusCode} - ${e.response?.statusMessage}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}



/*
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/service/token_storage.dart';

class MaterialService {
  final http.Client _client;

  MaterialService({http.Client? client}) : _client = client ?? http.Client();

  /// ================= Helper Functions =================
  Future<String> _getToken() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token not found, login required");
    return token;
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _get(String url) async {
    final token = await _getToken();
    return _client.get(Uri.parse(url), headers: _headers(token));
  }

  /// ================= GOLD PILL DETAIL =================
  Future<Map<String, dynamic>> getGoldPillDetail(int id) async {
    final url = "${AppConfig.baseUrl}/api/goldpill-detail/$id/";
    try {
      final res = await _get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return json.decode(res.body);
      }

      if (res.statusCode == 404) {
        throw Exception("GoldPill not found");
      }

      throw Exception("Error: ${res.statusCode} - ${res.reasonPhrase}");
    } on SocketException {
      throw Exception("No internet connection.");
    } on TimeoutException {
      throw Exception("Request timed out.");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  /// ================= CARBON PILL DETAIL =================
  Future<Map<String, dynamic>> getCarbonPillDetail(int id) async {
    final url = "${AppConfig.baseUrl}/api/carbonpill-detail/$id/";
    try {
      final res = await _get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return json.decode(res.body);
      }

      if (res.statusCode == 404) {
        throw Exception("CarbonPill not found");
      }

      throw Exception("Error: ${res.statusCode} - ${res.reasonPhrase}");
    } on SocketException {
      throw Exception("No internet connection.");
    } on TimeoutException {
      throw Exception("Request timed out.");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
*/