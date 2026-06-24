import 'dart:convert';
import 'dart:async';
import 'dart:io'; // <- untuk SocketException
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_provider_data/config/app_config.dart';
import 'token_storage.dart';

class EmployeeService {
  final http.Client _client;

  EmployeeService({http.Client? client}) : _client = client ?? http.Client();

  /// ================= Helper Function =================
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

  /// ================= GET EMPLOYEE DETAIL =================
  Future<EmployeeModel> getEmployeeDetail(String id) async {
    final url = "${AppConfig.baseUrl}/api/employee-detail/$id/";

    try {
      final response = await _get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (!data.containsKey('id_employee')) {
          throw Exception("Invalid data from server");
        }

        if (data['status'] == "02") {
          throw Exception("Employee not Active");
        }

        return EmployeeModel.fromJson(data);
      }

      if (response.statusCode == 404) {
        throw Exception("Employee not found");
      }

      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    } on SocketException {
      throw Exception("No internet connection.");
    } on TimeoutException {
      throw Exception("Request timed out.");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  /// ================= GET ALL EMPLOYEES =================
  Future<List<EmployeeModel>> getAllEmployees() async {
    final url = "${AppConfig.baseUrl}/api/employee-list-search/";

    try {
      final response = await _get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => EmployeeModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load employee list: ${response.statusCode}");
      }
    } on SocketException {
      throw Exception("No internet connection.");
    } on TimeoutException {
      throw Exception("Request timed out.");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
