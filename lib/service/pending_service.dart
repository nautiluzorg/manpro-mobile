// lib/service/pending_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_provider_data/model/record_pending_det_model.dart';
import 'package:flutter_provider_data/model/record_pending_detail_model.dart';
import 'package:flutter_provider_data/model/record_pending_model.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'dio_client.dart';

class PendingService {
  final Dio _dio;

  PendingService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// Helper ekstrak pesan error dari response backend
  String _extractErrorMessage(dynamic body) {
    if (body is Map) {
      return body['error'] ?? body['message'] ?? 'Unknown error';
    }
    return 'Unknown error';
  }

  /// ================= FETCH LIST =================
  Future<List<RecordPendingModel>> fetchPendingList(String idProses) async {
    try {
      final response = await _dio.get(
        '/api/record-pending-list/',
        queryParameters: {
          'status_pending': 'open',
          'id_proses': idProses,
        },
      );

      final dynamic decoded = response.data;

      if (decoded is! List) {
        throw Exception(
            'FETCH_PENDING_LIST_ERROR: Expected List but got ${decoded.runtimeType}');
      }

      return decoded
          .map((e) => RecordPendingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'FETCH_PENDING_LIST_FAILED: $errorMessage (${e.response?.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('FETCH_PENDING_LIST_ERROR: $e');
    }
  }

  /// ================= FETCH DETAIL =================
  Future<List<RecordPendingDetailModel>> fetchPendingDetail(
      String idPending) async {
    try {
      final response = await _dio.get('/api/pending-detail/$idPending/');

      final jsonResponse = response.data;

      if (jsonResponse is Map && jsonResponse['data'] is List) {
        return (jsonResponse['data'] as List)
            .map((e) => RecordPendingDetailModel.fromJson(e))
            .toList();
      }

      return [RecordPendingDetailModel.fromJson(jsonResponse)];
    } on DioException catch (e) {
      throw Exception(
          'Failed to load pending detail (${e.response?.statusCode})');
    }
  }

  Future<List<RecordPendingDetailModel>> fetchPendingDetailWorkdayOver(
      String idPending) async {
    try {
      final response =
          await _dio.get('/api/pending-detail-workdayover/$idPending/');

      final jsonResponse = response.data;

      if (jsonResponse is Map && jsonResponse['data'] is List) {
        return (jsonResponse['data'] as List)
            .map((e) => RecordPendingDetailModel.fromJson(e))
            .toList();
      }

      return [RecordPendingDetailModel.fromJson(jsonResponse)];
    } on DioException catch (e) {
      throw Exception(
          'Failed to load pending detail (${e.response?.statusCode})');
    }
  }

  Future<RecordPendingDetailModel> fetchWithNgDetail(String idPending) async {
    try {
      final response =
          await _dio.get('/api/pending-detail-with-ng/$idPending/');

      final jsonResponse = response.data;
      return RecordPendingDetailModel.fromJson(jsonResponse);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'FETCH_PENDING_DETAIL_NG_FAILED: $errorMessage (${e.response?.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('FETCH_PENDING_DETAIL_NG_ERROR: $e');
    }
  }

  /// ================= UPDATE RECORD =================

  Future<Map<String, dynamic>> updateRecordPendingMc({
    required int idPending,
    required String idRecord,
    required String idMachine,
  }) async {
    final payload = {
      "records": [
        {
          "id_record": idRecord,
          "id_pending": idPending,
          "id_mc_new": idMachine,
        }
      ]
    };

    // ✅ DEBUG
    logPrint("=== updateRecordPendingMc ===");
    logPrint("PAYLOAD: $payload");

    try {
      final response = await _dio.post(
        '/api/update-record-pending-mc/',
        data: payload,
      );

      logPrint("STATUS: ${response.statusCode}");
      logPrint("BODY: ${response.data}");
      logPrint("=============================");

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      logPrint("STATUS: ${e.response?.statusCode}");
      logPrint("BODY: ${e.response?.data}");
      logPrint("=============================");

      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'UPDATE_MC_FAILED: $errorMessage (${e.response?.statusCode})');
    }
  }

  /*### Function update pending biasa ##############################*/
  Future<Map<String, dynamic>> updateRecordPending({
    required int idPending,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/update-record-pending/$idPending/',
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'UPDATE_PENDING_FAILED: $errorMessage (${e.response?.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('UPDATE_PENDING_ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> updateRecordWorkover({
    required int idPending,
    required String idRecord,
    required String idEmployee,
  }) async {
    try {
      final response = await _dio.post(
        '/api/update-record-workover/',
        data: {
          'id_pending': idPending,
          'id_record': idRecord,
          'id_employee': idEmployee,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'UPDATE_WORKOVER_FAILED: $errorMessage (${e.response?.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('UPDATE_WORKOVER_ERROR: $e');
    }
  }

  /// ================= SUBMIT START =================
  Future<void> updateRecordOpChange({
    required int idPending,
    required String idEmployee,
  }) async {
    try {
      final payload = {
        "id_pending": idPending,
        "id_employee": idEmployee,
      };

      await _dio.patch(
        "/api/update-record-pending-changeoperator/",
        data: payload,
      );

      return;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data);
      throw Exception(
          'UPDATE_OP_CHANGE_FAILED: $errorMessage (${e.response?.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('UPDATE_OP_CHANGE_ERROR: $e');
    }
  }

  Future<void> updateMassRecords(List<RecordPendingModel> records) async {
    if (records.isEmpty) return;

    final payload = {
      "records": records
          .map((r) => {"id_record": r.idRecord, "id_pending": r.idPending})
          .toList(),
    };

    try {
      await _dio.post("/api/record-set-start/", data: payload);
    } on DioException catch (e) {
      throw Exception(
          "SUBMIT_FAILED: ${e.response?.statusCode} - ${e.response?.data}");
    }
  }

  Future<RecordPendingDetModel> fetchRecordPendingDetail(
      String idRecord) async {
    try {
      final response = await _dio.get('/api/record-pending-detail/$idRecord/');

      final Map<String, dynamic> jsonData = response.data;
      return RecordPendingDetModel.fromJson(jsonData);
    } on DioException catch (e) {
      throw Exception(
          'Failed to load pending detail (${e.response?.statusCode})');
    }
  }

  /// ================= CONTINUE WORKDAY OVER NEW OPERATOR =================
  Future<Map<String, dynamic>> continueWorkdayOverNewOperator({
    required String idRecord,
    required String idEmployee, // ⬅ operator baru, sesuai key backend
  }) async {
    try {
      final payload = {
        "id_record": idRecord,
        "id_employee": idEmployee,
      };

      logPrint("=== continueWorkdayOverNewOperator ===");
      logPrint("PAYLOAD : $payload");

      final response = await _dio.post(
        '/api/continue-workday-over-new-operator/',
        data: payload,
      );

      logPrint("STATUS : ${response.statusCode}");
      logPrint("BODY   : ${response.data}");

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      logPrint("STATUS : ${e.response?.statusCode}");
      logPrint("BODY   : ${e.response?.data}");

      final errorMessage = _extractErrorMessage(e.response?.data);

      throw Exception(
        'CONTINUE_WORKDAY_OVER_FAILED: '
        '$errorMessage (${e.response?.statusCode})',
      );
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('CONTINUE_WORKDAY_OVER_ERROR: $e');
    }
  }
}
