// lib/services/ng_service.dart
import 'package:dio/dio.dart';
import '../service/dio_client.dart';
import '../model/ng_dropdown_model.dart';

class NGService {
  final Dio _dio;

  NGService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// ================= FETCH NG LIST =================
  Future<List<NgDropdownModel>> fetchNGList({
    required String productType,
    required String idProses,
  }) async {
    try {
      final response = await _dio.get(
        '/api/ngs/',
        queryParameters: {
          'product_type': productType,
          'id_proses': idProses,
        },
      );

      final data = response.data;
      if (data is List) {
        return data.map((item) => NgDropdownModel.fromJson(item)).toList();
      } else {
        throw Exception("Unexpected response format: ${data.runtimeType}");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection.");
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Request timed out.");
      }
      throw Exception(
          "Failed to fetch NG list (${e.response?.statusCode}): ${e.response?.data}");
    } catch (e) {
      throw Exception("Error fetching NG list: $e");
    }
  }
}

/*
// lib/services/ng_service.dart
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_provider_data/service/token_storage.dart';
import '../config/app_config.dart';
import '../model/ng_dropdown_model.dart';

class NGService {
  final http.Client _client;

  NGService({http.Client? client}) : _client = client ?? http.Client();

  /// Helper untuk ambil token
  Future<String> _getToken() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token not found, login required");
    return token;
  }

  /// Helper header
  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// ================= FETCH NG LIST =================

  Future<List<NgDropdownModel>> fetchNGList({
    required String productType,
    required String idProses,
  }) async {
    final uri = Uri.parse("${AppConfig.baseUrl}/api/ngs/").replace(
      queryParameters: {
        'product_type': productType,
        'id_proses': idProses,
      },
    );

    try {
      final response = await _client
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => NgDropdownModel.fromJson(item)).toList();
        } else {
          throw Exception("Unexpected response format: ${data.runtimeType}");
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            "Failed to fetch NG list (${response.statusCode}): ${response.body}");
      }
    } on SocketException {
      throw Exception("No internet connection.");
    } on TimeoutException {
      throw Exception("Request timed out.");
    } catch (e) {
      throw Exception("Error fetching NG list: $e");
    }
  }
}

*/
