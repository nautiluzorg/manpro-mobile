// lib/services/reason_service.dart
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_provider_data/service/token_storage.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../model/reason_dropdown_model.dart';

class ReasonService {
  final http.Client _client;

  ReasonService({http.Client? client}) : _client = client ?? http.Client();

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

  /// ================= FETCH REASON LIST =================
  Future<List<ReasonDropdownModel>> fetchReasonList({
    required String idProses,
  }) async {
    final url = "${AppConfig.baseUrl}/api/reason-list/all/";

    try {
      final response = await _client
          .get(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => ReasonDropdownModel.fromJson(e)).toList();
        } else {
          throw Exception("Unexpected response format: ${data.runtimeType}");
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            "Failed to fetch reason list (${response.statusCode}): ${response.body}");
      }
    } on SocketException {
      throw Exception("No internet connection.");
    } on TimeoutException {
      throw Exception("Request timed out.");
    } catch (e) {
      throw Exception("Error fetching reason list: $e");
    }
  }
}





/*
import 'dart:convert';
import 'package:flutter_provider_data/model/reason_dropdown_model.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ReasonService {
  Future<List<ReasonDropdownModel>> fetchReasonList({
    required String idProses,
  }) async {
    final url = "${AppConfig.baseUrl}/api/reason-list/all/";
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data as List)
          .map((e) => ReasonDropdownModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Gagal mengambil reason (${res.statusCode})");
    }
  }
}

*/