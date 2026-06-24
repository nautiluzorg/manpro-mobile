import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_provider_data/service/token_storage.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../model/master/machine_model.dart';
import '../model/machine_model_dropdown.dart';
import '../model/machine_layout_model.dart';

class MachineService {
  final http.Client _client;

  MachineService({http.Client? client}) : _client = client ?? http.Client();

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

  /// ================= CHECK MACHINE STATUS =================
  Future<Map<String, dynamic>> checkMachineStatus(String id) async {
    try {
      final res =
          await _get("${AppConfig.baseUrl}/api/check-machine-status/$id/")
              .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return json.decode(res.body);
      } else {
        final body = json.decode(res.body);
        return {
          'status': 'error',
          'message': body['message'] ?? 'Unknown error'
        };
      }
    } on SocketException {
      throw Exception("No internet connection.");
    } on TimeoutException {
      throw Exception("Request timed out.");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<Map<String, dynamic>> checkMachineRunStatus(String id) async {
    try {
      final data = await checkMachineStatus(id);
      return {
        'status': data['status'],
        'run_status': data['run_status'],
        'message': data['message'],
        'id_record': data['id_record'],
      };
    } catch (e) {
      throw Exception("Error checking run status: $e");
    }
  }

  /// ================= MACHINE DETAIL =================
  Future<MachineModel> getMachineDetail(String id) async {
    try {
      final res =
          await _get("${AppConfig.baseUrl}/api/machine-detail/$id/").timeout(
        const Duration(seconds: 10),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return MachineModel.fromJson(data);
      } else {
        throw Exception(
            "Machine not found or server error (${res.statusCode})");
      }
    } catch (e) {
      throw Exception("Error fetching machine detail: $e");
    }
  }

  Future<List<MachineModelDropdown>> getAllMachines() async {
    try {
      final res = await _get(
              "${AppConfig.baseUrl}/api/machine-list-all/?category_mc=MOLDING")
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        return data.map((e) => MachineModelDropdown.fromJson(e)).toList();
      } else if (res.statusCode == 404) {
        return [];
      } else {
        throw Exception("Failed to load machine list (${res.statusCode})");
      }
    } catch (e) {
      throw Exception("Error fetching machine list: $e");
    }
  }

  Future<List<MachineLayoutModel>> getMachineLayoutStatus() async {
    try {
      final res =
          await _get("${AppConfig.baseUrl}/api/machine-layout-status/").timeout(
        const Duration(seconds: 10),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List list = data['machines'] ?? [];
        return list.map((e) => MachineLayoutModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed load machine layout (${res.statusCode})");
      }
    } catch (e) {
      throw Exception("Error fetching machine layout: $e");
    }
  }

  /// ================= MACHINE STATUS TESTING =================
  Future<Map<String, dynamic>> checkMachineStatusTesting(
      String machineId) async {
    try {
      final res = await _get(
        "${AppConfig.baseUrl}/api/check-machine-status-testing/$machineId/",
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return json.decode(res.body);
      } else if (res.statusCode == 404) {
        return {
          "status": "not_found",
          "job_status": "not_found",
          "message": "Mesin tidak ditemukan"
        };
      } else {
        throw Exception("Failed check machine status (${res.statusCode})");
      }
    } catch (e) {
      throw Exception("Error checking machine status testing: $e");
    }
  }

// ================= CHECK MACHINE STATUS DROPDOWN =================
  Future<Map<String, dynamic>> checkMachineStatusDropdown(
      String machineId) async {
    try {
      final res = await _get(
        "${AppConfig.baseUrl}/api/check-machine-status/$machineId/",
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        return {
          "status": data["status"],
          "run_status": data["run_status"],
          "message": data["message"],
          "id_record": data["id_record"],
        };
      } else if (res.statusCode == 404) {
        return {
          "status": "not_found",
          "message": "Machine tidak ditemukan",
        };
      } else {
        throw Exception(
          "Failed check machine status (${res.statusCode})",
        );
      }
    } on SocketException {
      throw Exception("No internet connection.");
    } on TimeoutException {
      throw Exception("Request timeout.");
    } catch (e) {
      throw Exception("Error check machine status dropdown: $e");
    }
  }
}
