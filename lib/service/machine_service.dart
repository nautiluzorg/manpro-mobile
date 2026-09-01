// lib/service/machine_service.dart
import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../model/master/machine_model.dart';
import '../model/machine_model_dropdown.dart';
import '../model/machine_layout_model.dart';

class MachineService {
  final Dio _dio;

  MachineService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// ================= CHECK MACHINE STATUS =================
  Future<Map<String, dynamic>> checkMachineStatus(String id) async {
    try {
      final res = await _dio.get('/api/check-machine-status/$id/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection.");
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Request timed out.");
      }
      // Non-200 tapi ada body -> balikin sebagai map error, bukan throw
      // (sesuai behavior asli)
      if (body is Map<String, dynamic>) {
        return {
          'status': 'error',
          'message': body['message'] ?? 'Unknown error'
        };
      }
      return {'status': 'error', 'message': 'Unknown error'};
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
      final res = await _dio.get('/api/machine-detail/$id/');
      return MachineModel.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
          "Machine not found or server error (${e.response?.statusCode})");
    } catch (e) {
      throw Exception("Error fetching machine detail: $e");
    }
  }

  Future<List<MachineModelDropdown>> getAllMachines() async {
    try {
      final res = await _dio.get(
        '/api/machine-list-all/',
        queryParameters: {'category_mc': 'MOLDING'},
      );

      final List data = res.data;
      return data.map((e) => MachineModelDropdown.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception(
          "Failed to load machine list (${e.response?.statusCode})");
    } catch (e) {
      throw Exception("Error fetching machine list: $e");
    }
  }

  Future<List<MachineLayoutModel>> getMachineLayoutStatus() async {
    try {
      final res = await _dio.get('/api/machine-layout-status/');

      final data = res.data;
      final List list = data['machines'] ?? [];
      return list.map((e) => MachineLayoutModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception("Failed load machine layout (${e.response?.statusCode})");
    } catch (e) {
      throw Exception("Error fetching machine layout: $e");
    }
  }

  /// ================= MACHINE STATUS TESTING =================
  Future<Map<String, dynamic>> checkMachineStatusTesting(
      String machineId) async {
    try {
      final res =
          await _dio.get('/api/check-machine-status-testing/$machineId/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {
          "status": "not_found",
          "job_status": "not_found",
          "message": "Mesin tidak ditemukan"
        };
      }
      throw Exception(
          "Failed check machine status (${e.response?.statusCode})");
    } catch (e) {
      throw Exception("Error checking machine status testing: $e");
    }
  }

  /// ================= CHECK MACHINE STATUS DROPDOWN =================
  Future<Map<String, dynamic>> checkMachineStatusDropdown(
      String machineId) async {
    try {
      final res = await _dio.get('/api/check-machine-status/$machineId/');
      final data = res.data;

      return {
        "status": data["status"],
        "run_status": data["run_status"],
        "message": data["message"],
        "id_record": data["id_record"],
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {
          "status": "not_found",
          "message": "Machine tidak ditemukan",
        };
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection.");
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Request timeout.");
      }
      throw Exception(
          "Failed check machine status (${e.response?.statusCode})");
    } catch (e) {
      throw Exception("Error check machine status dropdown: $e");
    }
  }
}
