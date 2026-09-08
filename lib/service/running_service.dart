// lib/service/running_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_provider_data/model/reason_dropdown_model.dart';
import 'package:flutter_provider_data/model/master/reason_model.dart';
import 'package:flutter_provider_data/model/record_running_det_model.dart';
import 'package:flutter_provider_data/model/record_running_detail_model.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:flutter_provider_data/utils/logger.dart';

import 'dio_client.dart';

class RunningService {
  final Dio _dio = DioClient.instance;

  RunningService();

  // RunningService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  String _extractErrorMessage(dynamic body) {
    if (body is Map) {
      return body['error'] ?? body['message'] ?? 'Unknown error';
    }
    return 'Unknown error';
  }

  /// Menampilkan record list running dalam jumlah banyak.
  Future<List<RecordRunningModel>> fetchRunningRecords(String idProses) async {
    try {
      final response = await _dio.get(
        '/api/record-list/',
        queryParameters: {
          'run_status': 'running',
          'id_proses': idProses,
        },
      );

      final dynamic decoded = response.data;

      if (decoded is! List) {
        throw Exception(
            'FETCH_RUNNING_RECORDS_ERROR: Expected List but got ${decoded.runtimeType}');
      }

      return decoded
          .map((e) => RecordRunningModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logPrint('DioException type: ${e.type}');
      logPrint('DioException message: ${e.message}');
      logPrint('Status code: ${e.response?.statusCode}');
      logPrint('Response data: ${e.response?.data}');

      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'FETCH_RUNNING_RECORDS_FAILED: $errorMessage (${e.response?.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('FETCH_RUNNING_RECORDS_ERROR: $e');
    }
  }

  /// Ambil list reason untuk dropdown MASAL
  Future<List<ReasonModel>> fetchReasonList() async {
    try {
      final response = await _dio.get('/api/reason-list/all/');

      final List data = response.data;
      return data
          .map((e) => ReasonModel.fromJson(e))
          .where((reason) =>
              reason.idReason != "02" &&
              reason.idReason != "03" &&
              reason.idReason != "06")
          .toList();
    } on DioException {
      throw Exception('Failed to load reasons');
    }
  }

  /// Ambil list reason untuk dropdown SATU SATU
  Future<List<ReasonDropdownModel>> fetchReasonItems() async {
    try {
      final response = await _dio.get('/api/reason-list/all/');

      final List<dynamic> data = response.data;
      return data.map((item) => ReasonDropdownModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception(
          'Failed to load reason list: ${e.response?.statusCode} ${e.response?.statusMessage}');
    }
  }

  /// Ambil detail record Running
  Future<List<RecordRunningDetailModel>> fetchRecordDetail(
      String idRecord) async {
    try {
      final response = await _dio.get('/api/record-detail/$idRecord/');

      final jsonResponse = response.data;

      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('data')) {
        final dataList = jsonResponse['data'];
        if (dataList is List) {
          return dataList
              .map((item) => RecordRunningDetailModel.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else if (jsonResponse is Map<String, dynamic>) {
        return [RecordRunningDetailModel.fromJson(jsonResponse)];
      } else {
        return [];
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load records (status: ${e.response?.statusCode})');
    }
  }

  Future<bool> submitWorkdayOver({
    required String idRecord,
    required String idReason,
    required String idEmployee,
    required String idProses,
    required String bcode,
    required int shootQty,
    required List<Map<String, dynamic>> ngList,
  }) async {
    try {
      await _dio.post(
        '/api/submit-workday-over/',
        data: {
          "id_record": idRecord,
          "id_reason": idReason,
          "id_employee": idEmployee,
          "id_proses": idProses,
          "bcode": bcode,
          "shoot_qty": shootQty,
          "ng_list": ngList,
        },
      );

      return true;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'SUBMIT_CHANGE_OPERATOR_FAILED: $errorMessage (${e.response?.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('SUBMIT_CHANGE_OPERATOR_ERROR: $e');
    }
  }

  /// Service pergantian operator
  Future<bool> submitChangeOperator({
    required String idRecord,
    required String idReason,
    required String idEmployee,
    required String idProses,
    required String bcode,
    required int shootQty,
    required List<Map<String, dynamic>> ngList,
  }) async {
    try {
      await _dio.post(
        '/api/submit-change-operator/',
        data: {
          "id_record": idRecord,
          "id_reason": idReason,
          "id_employee": idEmployee,
          "id_proses": idProses,
          "bcode": bcode,
          "shoot_qty": shootQty,
          "ng_list": ngList,
        },
      );

      return true;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'SUBMIT_CHANGE_OPERATOR_FAILED: $errorMessage (${e.response?.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('SUBMIT_CHANGE_OPERATOR_ERROR: $e');
    }
  }

  /// Service pergantian machine
  Future<bool> submitChangeMachine({
    required String idRecord,
    required String idReason,
    required String idEmployee,
    required String idProses,
    required String bcode,
    required int shootQty,
    String? idMachine,
  }) async {
    try {
      final payload = {
        "id_record": idRecord,
        "id_reason": idReason,
        "id_employee": idEmployee,
        "id_proses": idProses,
        "bcode": bcode,
        "shoot_qty": shootQty,
        if (idMachine != null) "id_mc": idMachine,
      };

      await _dio.post(
        '/api/submit-change-machine/',
        data: payload,
      );

      return true;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'SUBMIT_CHANGE_MACHINE_FAILED: $errorMessage (${e.response?.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('SUBMIT_CHANGE_MACHINE_ERROR: $e');
    }
  }

  /// Submit stop record
  Future<bool> submitRecordStop({
    required String idRecord,
    required String idReason,
    required String idEmployee,
    required String idProses,
    required String bcode,
  }) async {
    try {
      await _dio.post(
        '/api/submit-record-pending/',
        data: {
          "id_record": idRecord,
          "id_reason": idReason,
          "id_employee": idEmployee,
          "id_proses": idProses,
          "bcode": bcode,
        },
      );

      return true;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'SUBMIT_RECORD_STOP_FAILED: $errorMessage (${e.response?.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('SUBMIT_RECORD_STOP_ERROR: $e');
    }
  }

  /// Stop multiple running records
  Future<Map<String, dynamic>> stopRunningRecord({
    required List<String> selectedRecordIds,
    required String idReason,
    required String idEmployeeFinish,
  }) async {
    try {
      final response = await _dio.post(
        '/api/record-stop/',
        data: {
          "record_ids": selectedRecordIds,
          "id_reason": idReason,
          "id_employee_finish": idEmployeeFinish,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception("Failed to stop records: ${e.response?.data}");
    }
  }

  /// Post pending records
  Future<bool> postPendingRecords({
    required List<RecordRunningModel> selectedItems,
    required ReasonDropdownModel? selectedReason,
  }) async {
    if (selectedReason == null) return false;

    final payload = {
      "records": selectedItems.map((r) {
        return {
          "id_record": r.idRecord.toString(),
          "id_reason": selectedReason.idReason,
          "id_employee": r.activeEmployee?.idEmployee ?? "",
          "id_proses": r.idProses,
          "bcode": r.detailsRecord.isNotEmpty
              ? r.detailsRecord.first.bcode.bcode
              : "",
        };
      }).toList()
    };

    // ✅ DEBUG PAYLOAD
    logPrint("=== DEBUG postPendingRecords ===");
    logPrint("URL: /api/record-set-pending/");
    logPrint("PAYLOAD: $payload");
    logPrint("================================");

    try {
      final response = await _dio.post(
        '/api/record-set-pending/',
        data: payload,
      );

      // ✅ DEBUG RESPONSE
      logPrint("=== DEBUG RESPONSE ===");
      logPrint("STATUS CODE: ${response.statusCode}");
      logPrint("RESPONSE BODY: ${response.data}");
      logPrint("======================");

      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException catch (e) {
      // ✅ DEBUG RESPONSE (gagal)
      logPrint("=== DEBUG RESPONSE ===");
      logPrint("STATUS CODE: ${e.response?.statusCode}");
      logPrint("RESPONSE BODY: ${e.response?.data}");
      logPrint("======================");

      return false;
    }
  }

  /// Ambil detail employee
  Future<Map<String, dynamic>> getEmployeeDetail(String qrCode) async {
    try {
      final response = await _dio.get('/api/employee-detail/$qrCode/');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("Employee not found");
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("timeout");
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception("network");
      }
      if (e.response != null) {
        throw Exception("Error ${e.response?.statusCode}");
      }
      throw Exception("unknown");
    } on FormatException {
      throw Exception("format");
    } catch (_) {
      throw Exception("unknown");
    }
  }

  /// Ambil detail running
  Future<RecordRunningDetModel> getRunningDetail(String idRecordTest) async {
    try {
      final response =
          await _dio.get('/api/record-running-detail/$idRecordTest/');

      final jsonData = response.data;
      return RecordRunningDetModel.fromJson(jsonData);
    } on DioException {
      throw Exception('Failed to load testing detail');
    }
  }
}
