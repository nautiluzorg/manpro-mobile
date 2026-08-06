// lib/services/record_service.dart
import 'dart:async';
import 'package:dio/dio.dart';
import '../service/dio_client.dart';
import '../model/record_active_model.dart';

class RecordService {
  final Dio _dio;

  RecordService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// ================= FETCH ACTIVE RECORDS =================
  Future<List<RecordActiveModel>> fetchActiveRecords({
    String jobnumber = '',
    String idEmployeeFinish = '',
    String runStatus = '', // bisa "pending,running"
  }) async {
    Map<String, String> queryParams = {};
    if (jobnumber.isNotEmpty) queryParams['jobnumber'] = jobnumber;
    if (idEmployeeFinish.isNotEmpty) {
      queryParams['id_employee_finish'] = idEmployeeFinish;
    }
    if (runStatus.isNotEmpty) queryParams['run_status'] = runStatus;

    try {
      final response = await _dio.get(
        '/api/record-on-process/',
        queryParameters: queryParams,
      );

      final body = response.data;
      if (body is List) {
        return body.map((r) => RecordActiveModel.fromJson(r)).toList();
      } else {
        throw Exception("Unexpected response type: ${body.runtimeType}");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection.");
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Request timed out.");
      }
      throw Exception(
          'Failed to load active records (${e.response?.statusCode})');
    } catch (e) {
      throw Exception("Error fetching active records: $e");
    }
  }

  /// ================= DELETE RECORD =================
  Future<bool> deleteRecord(String idRecord) async {
    try {
      final response = await _dio.delete(
        '/api/recordproses/delete/$idRecord/',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to delete record (${response.statusCode}): ${response.data}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection.");
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Request timed out.");
      }
      throw Exception(
          'Failed to delete record (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      throw Exception("Error deleting record: $e");
    }
  }
}














/*
// lib/services/record_service.dart
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_provider_data/service/token_storage.dart';
import '../config/app_config.dart';
import '../model/record_active_model.dart';

class RecordService {
  final http.Client _client;

  RecordService({http.Client? client}) : _client = client ?? http.Client();

  /// Helper untuk ambil token
  Future<String> _getToken() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token not found, login required");
    return token;
  }

  /// Helper untuk header
  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// ================= FETCH ACTIVE RECORDS =================
  Future<List<RecordActiveModel>> fetchActiveRecords({
    String jobnumber = '',
    String idEmployeeFinish = '',
    String runStatus = '', // bisa "pending,running"
  }) async {
    Map<String, String> queryParams = {};
    if (jobnumber.isNotEmpty) queryParams['jobnumber'] = jobnumber;
    if (idEmployeeFinish.isNotEmpty) {
      queryParams['id_employee_finish'] = idEmployeeFinish;
    }
    if (runStatus.isNotEmpty) queryParams['run_status'] = runStatus;

    Uri uri = Uri.parse('${AppConfig.baseUrl}/api/record-on-process/')
        .replace(queryParameters: queryParams);

    try {
      final response = await _client
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is List) {
          return body.map((r) => RecordActiveModel.fromJson(r)).toList();
        } else {
          throw Exception("Unexpected response type: ${body.runtimeType}");
        }
      } else {
        throw Exception(
            'Failed to load active records (${response.statusCode})');
      }
    } on SocketException {
      throw Exception("No internet connection.");
    } on TimeoutException {
      throw Exception("Request timed out.");
    } catch (e) {
      throw Exception("Error fetching active records: $e");
    }
  }

  /// ================= DELETE RECORD =================
  Future<bool> deleteRecord(String idRecord) async {
    Uri uri =
        Uri.parse('${AppConfig.baseUrl}/api/recordproses/delete/$idRecord/');

    try {
      final response = await _client
          .delete(uri, headers: await _headers())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to delete record (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw Exception("No internet connection.");
    } on TimeoutException {
      throw Exception("Request timed out.");
    } catch (e) {
      throw Exception("Error deleting record: $e");
    }
  }
}
*/













/*
import 'dart:convert';
import 'package:flutter_provider_data/model/record_active_model.dart';
import '../config/app_config.dart';

class RecordService {
  /// Ambil daftar record aktif (pending & running)
  Future<List<RecordActiveModel>> fetchActiveRecords({
    String jobnumber = '',
    String idEmployeeFinish = '',
    String runStatus = '', // bisa "pending,running"
  }) async {
    // Build query params
    Map<String, String> queryParams = {};
    if (jobnumber.isNotEmpty) queryParams['jobnumber'] = jobnumber;
    if (idEmployeeFinish.isNotEmpty) {
      queryParams['id_employee_finish'] = idEmployeeFinish;
    }
    if (runStatus.isNotEmpty) queryParams['run_status'] = runStatus;

    Uri uri = Uri.parse('${AppConfig.baseUrl}/api/record-on-process/')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body is List) {
        return body
            .map((record) => RecordActiveModel.fromJson(record))
            .toList();
      } else {
        throw Exception('Expected a list but got: ${body.runtimeType}');
      }
    } else {
      throw Exception(
          'Failed to load active records (status: ${response.statusCode})');
    }
  }

  /// Hapus record berdasarkan id
  Future<bool> deleteRecord(String idRecord) async {
    Uri uri =
        Uri.parse('${AppConfig.baseUrl}/api/recordproses/delete/$idRecord/');

    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      // bisa cek response body jika perlu
      return true;
    } else {
      throw Exception(
          'Failed to delete record (status: ${response.statusCode})');
    }
  }
}
*/