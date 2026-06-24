import 'dart:convert';
import 'dart:async';
import 'package:flutter_provider_data/model/record_pending_det_model.dart';
import 'package:flutter_provider_data/model/record_pending_detail_model.dart';
import 'package:flutter_provider_data/model/record_pending_model.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_provider_data/config/app_config.dart';
import 'token_storage.dart';

class PendingService {
  final http.Client _client;

  PendingService({http.Client? client}) : _client = client ?? http.Client();

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

  Future<http.Response> _post(String url, Map<String, dynamic> body) async {
    final token = await _getToken();
    return _client.post(Uri.parse(url),
        headers: _headers(token), body: jsonEncode(body));
  }

  Future<http.Response> _patch(String url, Map<String, dynamic>? body) async {
    final token = await _getToken();
    return _client.patch(
      Uri.parse(url),
      headers: _headers(token),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// ================= FETCH LIST =================
  Future<List<RecordPendingModel>> fetchPendingList(String idProses) async {
    try {
      final url =
          '${AppConfig.baseUrl}/api/record-pending-list/?status_pending=open&id_proses=$idProses';
      final response = await _get(url);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is! List) {
          throw Exception(
              'FETCH_PENDING_LIST_ERROR: Expected List but got ${decoded.runtimeType}');
        }

        return decoded
            .map((e) => RecordPendingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final errorBody = jsonDecode(response.body);
      final errorMessage =
          errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
      throw Exception(
          'FETCH_PENDING_LIST_FAILED: $errorMessage (${response.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('FETCH_PENDING_LIST_ERROR: $e');
    }
  }

  /// ================= FETCH DETAIL =================
  Future<List<RecordPendingDetailModel>> fetchPendingDetail(
      String idPending) async {
    final response =
        await _get('${AppConfig.baseUrl}/api/pending-detail/$idPending/');

    if (response.statusCode != 200)
      throw Exception('Failed to load pending detail');

    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse is Map && jsonResponse['data'] is List) {
      return (jsonResponse['data'] as List)
          .map((e) => RecordPendingDetailModel.fromJson(e))
          .toList();
    }

    return [RecordPendingDetailModel.fromJson(jsonResponse)];
  }

  Future<RecordPendingDetailModel> fetchWithNgDetail(String idPending) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("Token not found, login required");

      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/pending-detail-with-ng/$idPending/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return RecordPendingDetailModel.fromJson(jsonResponse);
      }

      final errorBody = jsonDecode(response.body);
      final errorMessage =
          errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
      throw Exception(
          'FETCH_PENDING_DETAIL_NG_FAILED: $errorMessage (${response.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('FETCH_PENDING_DETAIL_NG_ERROR: $e');
    }
  }

  /// ================= UPDATE RECORD =================

  Future<Map<String, dynamic>> updateRecordPendingMc({
    required int idPending,
    required String idRecord, // ← tambah
    required String idMachine,
  }) async {
    final payload = {
      "records": [
        {
          "id_record": idRecord, // ← tambah
          "id_pending": idPending,
          "id_mc_new": idMachine, // ← rename
        }
      ]
    };

    // ✅ DEBUG
    logPrint("=== updateRecordPendingMc ===");
    logPrint("PAYLOAD: ${jsonEncode(payload)}");

    final response = await _post(
      '${AppConfig.baseUrl}/api/update-record-pending-mc/',
      payload,
    );

    logPrint("STATUS: ${response.statusCode}");
    logPrint("BODY: ${response.body}");
    logPrint("=============================");

    if (response.statusCode == 200) return jsonDecode(response.body);

    final errorBody = jsonDecode(response.body);
    final errorMessage =
        errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
    throw Exception('UPDATE_MC_FAILED: $errorMessage (${response.statusCode})');
  }

  /*### Function update pending biasa ##############################*/
  Future<Map<String, dynamic>> updateRecordPending({
    required int idPending,
  }) async {
    try {
      final response = await _patch(
        '${AppConfig.baseUrl}/api/update-record-pending/$idPending/',
        null,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      // Handle error response dari backend
      final errorBody = jsonDecode(response.body);
      final errorMessage =
          errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
      throw Exception(
          'UPDATE_PENDING_FAILED: $errorMessage (${response.statusCode})');
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
      final response = await _post(
        '${AppConfig.baseUrl}/api/update-record-workover/',
        {
          'id_pending': idPending,
          'id_record': idRecord,
          'id_employee': idEmployee,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      final errorBody = jsonDecode(response.body);
      final errorMessage =
          errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
      throw Exception(
          'UPDATE_WORKOVER_FAILED: $errorMessage (${response.statusCode})');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('UPDATE_WORKOVER_ERROR: $e');
    }
  }

  /// ================= SUBMIT START =================
  Future<void> updateRecordOpChange({
    required int idPending,
    required String idEmployee, // ✅ rename dari idEmployeeFinish
  }) async {
    try {
      final payload = {
        "id_pending": idPending,
        "id_employee": idEmployee, // ✅ sesuai backend
      };

      final response = await _patch(
        "${AppConfig.baseUrl}/api/update-record-pending-with-ng/",
        payload,
      );

      if (response.statusCode == 200) return;

      final errorBody = jsonDecode(response.body);
      final errorMessage =
          errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
      throw Exception(
          'UPDATE_OP_CHANGE_FAILED: $errorMessage (${response.statusCode})');
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

    final response =
        await _post("${AppConfig.baseUrl}/api/record-set-start/", payload);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          "SUBMIT_FAILED: ${response.statusCode} - ${response.body}");
    }
  }

  Future<RecordPendingDetModel> fetchRecordPendingDetail(
      String idRecord) async {
    final response =
        await _get('${AppConfig.baseUrl}/api/record-pending-detail/$idRecord/');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return RecordPendingDetModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load pending detail (${response.statusCode})');
    }
  }

  /// ================= CONTINUE WORKDAY OVER NEW OPERATOR =================
  Future<Map<String, dynamic>> continueWorkdayOverNewOperator({
    required String idRecord,
    required String idEmployeeLama,
    required String idEmployeeBaru,
    required int qtyShoot,
    required List<Map<String, dynamic>> ngData,
  }) async {
    try {
      final payload = {
        "id_record": idRecord,
        "id_employee_lama": idEmployeeLama,
        "id_employee_baru": idEmployeeBaru,
        "qty_shoot": qtyShoot,
        "ng_data": ngData,
      };

      logPrint("=== continueWorkdayOverNewOperator ===");
      logPrint("PAYLOAD : ${jsonEncode(payload)}");

      final response = await _post(
        '${AppConfig.baseUrl}/api/continue-workday-over-new-operator/',
        payload,
      );

      logPrint("STATUS : ${response.statusCode}");
      logPrint("BODY   : ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      final errorBody = jsonDecode(response.body);

      final errorMessage =
          errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';

      throw Exception(
        'CONTINUE_WORKDAY_OVER_FAILED: '
        '$errorMessage (${response.statusCode})',
      );
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('CONTINUE_WORKDAY_OVER_ERROR: $e');
    }
  }
}
