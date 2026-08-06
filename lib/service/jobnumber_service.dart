// lib/service/jobnumber_service.dart
import 'package:dio/dio.dart';
import 'dio_client.dart';

class JobNumberService {
  final Dio _dio;

  JobNumberService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// ================= QR UTILS =================
  bool isValidQR(String code) {
    if (code.length < 21) return false;
    final regex =
        RegExp(r'^[a-zA-Z0-9]{9}[a-zA-Z0-9]{10}[a-zA-Z0-9]{2}[0-9]+$');
    return regex.hasMatch(code);
  }

  Map<String, String> parseQR(String code) {
    try {
      String bcode = code.substring(0, 9);
      String jobnumber = code.substring(9, 19);
      String batchnumber = jobnumber.substring(0, 8);
      String lot = jobnumber.substring(jobnumber.length - 2);
      String totallot = code.substring(19, 21);
      String qty = code.substring(21);
      return {
        "bcode": bcode,
        "jobnumber": jobnumber,
        "batchnumber": batchnumber,
        "lot": lot,
        "totallot": totallot,
        "qty": qty,
      };
    } catch (e) {
      throw FormatException("QR parsing error: $e");
    }
  }

  /// ==GET API UNTUK CEK STATUS JOBNUMBER =====================================
  Future<Map<String, dynamic>> checkJobNumberStatus(
      String jobnumber, String idProses) async {
    try {
      final res =
          await _dio.get('/api/check-proses-jobnumber/$jobnumber/$idProses/');

      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Coba baca pesan error dari body backend kalau ada
      final body = e.response?.data;
      if (body is Map<String, dynamic>) {
        final errorMsg = body['error'] ??
            body['message'] ??
            "Status error: ${e.response?.statusCode}";
        throw Exception(errorMsg);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Koneksi timeout, coba lagi.");
      }

      throw Exception("Failed to get jobnumber status: ${e.message}");
    } catch (e) {
      throw Exception("Failed to get jobnumber status: $e");
    }
  }

  Future<Map<String, dynamic>> getProductDetail(String bcode) async {
    try {
      final res = await _dio.get('/api/product-detail/$bcode/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception("Detail product error: ${e.response?.statusCode}");
    } catch (e) {
      throw Exception("Failed to load product detail: $e");
    }
  }

  Future<List<dynamic>> getMoldsByDrawing(String drawingNumber) async {
    try {
      final res = await _dio.get('/api/mold-list/by-drawing/$drawingNumber/');
      return res.data['results'] ?? [];
    } on DioException catch (e) {
      throw Exception("Failed to load molds (${e.response?.statusCode})");
    } catch (e) {
      throw Exception("Error loading molds: $e");
    }
  }

  /// ================= SUBMIT RECORD =================
  Future<Map<String, dynamic>> submitRecord({
    required String idEmployee,
    required String idMachine,
    required String idProcess,
    required String batchNumber,
    required String totalJobNumber,
    required String bcode,
    required String jobNumber,
    required String lotNumber,
    required int startQty,
    required String? selectedMold,
    required int moldCavity,
    required String mixLotNo,
    String? goldPill,
    String? carbonPill,
    String? idRecordUpdate,
    List<Map<String, dynamic>>? ngData,
  }) async {
    try {
      final method =
          (idRecordUpdate == null || idRecordUpdate.isEmpty) ? 'POST' : 'PATCH';

      String url = "/api/record-create/";
      if (method == 'PATCH') {
        url += "?id_record=$idRecordUpdate";
      }

      final bodyData = {
        "id_employee": idEmployee,
        "id_mc": idMachine,
        "id_proses": idProcess,
        "batch_number": batchNumber,
        "total_jobnumber": totalJobNumber,
        "details_record": [
          {
            "bcode": bcode,
            "jobnumber": jobNumber,
            "lotnumber": lotNumber,
            "start_qty": startQty,
            "moldnumber": selectedMold,
            "moldcavity": moldCavity,
            "mix_lot_no": mixLotNo,
            "gold_pill": goldPill,
            "carbon_pill": carbonPill,
          }
        ],
      };

      if (ngData != null && ngData.isNotEmpty) {
        bodyData["ng_data"] = ngData;
      }

      final response = method == 'POST'
          ? await _dio.post(url, data: bodyData)
          : await _dio.patch(url, data: bodyData);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception("Failed to submit record: ${e.response?.data}");
    } catch (e) {
      throw Exception("Error submitting record: $e");
    }
  }
}























/*
import 'dart:async';
import 'dart:convert';
import 'package:flutter_provider_data/config/app_config.dart';
import 'token_storage.dart';

class JobNumberService {
  final http.Client _client;

  JobNumberService({http.Client? client}) : _client = client ?? http.Client();

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

  Future<http.Response> _send(
    String url,
    Map<String, dynamic> body, {
    String method = 'POST',
  }) async {
    final token = await _getToken();
    final uri = Uri.parse(url);

    if (method == 'POST') {
      return _client.post(uri,
          headers: _headers(token), body: jsonEncode(body));
    } else if (method == 'PATCH') {
      return _client.patch(uri,
          headers: _headers(token), body: jsonEncode(body));
    } else {
      throw Exception("Unsupported method: $method");
    }
  }

  /// ================= QR UTILS =================
  bool isValidQR(String code) {
    if (code.length < 21) return false;
    final regex =
        RegExp(r'^[a-zA-Z0-9]{9}[a-zA-Z0-9]{10}[a-zA-Z0-9]{2}[0-9]+$');
    return regex.hasMatch(code);
  }

  Map<String, String> parseQR(String code) {
    try {
      String bcode = code.substring(0, 9);
      String jobnumber = code.substring(9, 19);
      String batchnumber = jobnumber.substring(0, 8);
      String lot = jobnumber.substring(jobnumber.length - 2);
      String totallot = code.substring(19, 21);
      String qty = code.substring(21);
      return {
        "bcode": bcode,
        "jobnumber": jobnumber,
        "batchnumber": batchnumber,
        "lot": lot,
        "totallot": totallot,
        "qty": qty,
      };
    } catch (e) {
      throw FormatException("QR parsing error: $e");
    }
  }

  /// ==GET API UNTUK CEK STATUS JOBNUMBER =====================================
  Future<Map<String, dynamic>> checkJobNumberStatus(
      String jobnumber, String idProses) async {
    final url =
        "${AppConfig.baseUrl}/api/check-proses-jobnumber/$jobnumber/$idProses/";

    try {
      final res = await _get(url).timeout(const Duration(seconds: 10));

      // Decode dulu agar pesan error backend bisa dibaca
      final body = json.decode(res.body) as Map<String, dynamic>;

      if (res.statusCode != 200) {
        final errorMsg = body['error'] ??
            body['message'] ??
            "Status error: ${res.statusCode}";
        throw Exception(errorMsg); // ← pesan error lebih informatif
      }

      return body;
    } on TimeoutException {
      throw Exception("Koneksi timeout, coba lagi.");
    } catch (e) {
      throw Exception("Failed to get jobnumber status: $e");
    }
  }

  Future<Map<String, dynamic>> getProductDetail(String bcode) async {
    final url = "${AppConfig.baseUrl}/api/product-detail/$bcode/";

    try {
      final res = await _get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw Exception("Detail product error: ${res.statusCode}");
      }
      return json.decode(res.body);
    } catch (e) {
      throw Exception("Failed to load product detail: $e");
    }
  }

  Future<List<dynamic>> getMoldsByDrawing(String drawingNumber) async {
    final url = "${AppConfig.baseUrl}/api/mold-list/by-drawing/$drawingNumber/";
    try {
      final res = await _get(url);
      if (res.statusCode != 200) {
        throw Exception("Failed to load molds");
      }
      return json.decode(res.body)['results'] ?? [];
    } catch (e) {
      throw Exception("Error loading molds: $e");
    }
  }

  /// ================= SUBMIT RECORD =================
  Future<Map<String, dynamic>> submitRecord({
    required String idEmployee,
    required String idMachine,
    required String idProcess,
    required String batchNumber,
    required String totalJobNumber,
    required String bcode,
    required String jobNumber,
    required String lotNumber,
    required int startQty,
    required String? selectedMold,
    required int moldCavity,
    required String mixLotNo,
    String? goldPill,
    String? carbonPill,
    String? idRecordUpdate,
    List<Map<String, dynamic>>? ngData,
  }) async {
    try {
      final method =
          (idRecordUpdate == null || idRecordUpdate.isEmpty) ? 'POST' : 'PATCH';

      String url = "${AppConfig.baseUrl}/api/record-create/";
      if (method == 'PATCH') {
        url += "?id_record=$idRecordUpdate";
      }

      final bodyData = {
        "id_employee": idEmployee,
        "id_mc": idMachine,
        "id_proses": idProcess,
        "batch_number": batchNumber,
        "total_jobnumber": totalJobNumber,
        "details_record": [
          {
            "bcode": bcode,
            "jobnumber": jobNumber,
            "lotnumber": lotNumber,
            "start_qty": startQty,
            "moldnumber": selectedMold,
            "moldcavity": moldCavity,
            "mix_lot_no": mixLotNo,
            "gold_pill": goldPill,
            "carbon_pill": carbonPill,
          }
        ],
      };

      if (ngData != null && ngData.isNotEmpty) {
        bodyData["ng_data"] = ngData;
      }

      final response = await _send(url, bodyData, method: method);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to submit record: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error submitting record: $e");
    }
  }
}
*/