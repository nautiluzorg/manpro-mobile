import 'dart:convert';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/master/mold_model.dart';
import 'package:flutter_provider_data/model/monitor_testing_model.dart';
import 'package:flutter_provider_data/model/master/product_model.dart';
import 'package:flutter_provider_data/model/check_proses_testing_model.dart';
import 'package:flutter_provider_data/model/record_testing_detail_response.dart';
import 'package:flutter_provider_data/service/token_storage.dart';
import 'package:http/http.dart' as http;

class TestingService {
  final http.Client _client;
  TestingService(this._client);

  // ================= JWT HEADER =================
  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw Exception("Token not found, login required");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ================= HTTP HELPERS =================
  Future<http.Response> _get(String url) async {
    final headers = await _authHeaders();
    return _client
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 10));
  }

  Future<http.Response> _post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final headers = await _authHeaders();
    return _client
        .post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
  }

  Future<http.Response> _patch(
    String url,
    Map<String, dynamic> body,
  ) async {
    final headers = await _authHeaders();
    return _client
        .patch(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
  }

  // ================= JOB NUMBER =================
  Future<CheckProsesTestingModel> checkJobNumber({
    required String jobNumber,
    required String idProses,
  }) async {
    final response = await _get(
      "${AppConfig.baseUrl}/api/check-proses-jobnumber-testing/$jobNumber/$idProses/",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Job number not found (status: ${response.statusCode})",
      );
    }

    return CheckProsesTestingModel.fromJson(
      jsonDecode(response.body),
    );
  }

  // ================= PRODUCT DETAIL =================
  Future<ProductModel> fetchProductDetail(String bcode) async {
    final response = await _get(
      "${AppConfig.baseUrl}/api/product-detail/$bcode/",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed load product detail (status: ${response.statusCode})",
      );
    }

    return ProductModel.fromJson(
      jsonDecode(response.body),
    );
  }

  // ================= GET LIST MOLDS BY DRAWING =================
  Future<List<MoldModel>> fetchMoldsByDrawing(
    String drawingNumber,
  ) async {
    final response = await _get(
      "${AppConfig.baseUrl}/api/mold-list-by-drawing/$drawingNumber/",
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MoldModel.fromJson(e)).toList();
    } else {
      throw Exception(
        "Failed to load molds (status: ${response.statusCode})",
      );
    }
  }

  // ================= POST RECORD TESTING =================
  Future<bool> postRecordTesting(
    Map<String, dynamic> body,
  ) async {
    final response = await _post(
      "${AppConfig.baseUrl}/api/record-testing/",
      body,
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // ================= PATCH RECORD TESTING =================
  Future<bool> patchRecordTesting(
    Map<String, dynamic> body,
  ) async {
    final response = await _patch(
      "${AppConfig.baseUrl}/api/record-testing/",
      body,
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // ================= GET TESTING DETAIL =================
  Future<RecordTestingDetailResponse> getTestingDetail(
    String idRecordTest,
  ) async {
    final response = await _get(
      "${AppConfig.baseUrl}/api/testing/detail/$idRecordTest/",
    );

    if (response.statusCode == 200) {
      return RecordTestingDetailResponse.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
        "Failed to load testing detail (status: ${response.statusCode})",
      );
    }
  }

  // ================= LIST ON PROGRESS TESTING =================
  Future<MonitorTestingModel> fetchOnProgressTesting() async {
    final response = await _get(
      "${AppConfig.baseUrl}/api/onprogress-testing/",
    );

    if (response.statusCode == 200) {
      return MonitorTestingModel.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
        "Failed to fetch testing data (status: ${response.statusCode})",
      );
    }
  }
}



























/*
class TestingService {
  final http.Client _client;
  TestingService(this._client);

  // ================= HEADER JWT =================
  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.getAccessToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ================= JOB NUMBER =================
  Future<CheckProsesTestingModel> checkJobNumber({
    required String jobNumber,
    required String idProses,
  }) async {
    final url = Uri.parse(
      "${AppConfig.baseUrl}/api/check-proses-jobnumber-testing/$jobNumber/$idProses/",
    );

    final headers = await _authHeaders();

    final response = await _client
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Jobnumber not found");
    }

    final jsonData = json.decode(response.body);
    return CheckProsesTestingModel.fromJson(jsonData);
  }

  // ================= PRODUCT DETAIL =================
  Future<ProductModel> fetchProductDetail(String bcode) async {
    final url = Uri.parse("${AppConfig.baseUrl}/api/product-detail/$bcode/");
    final headers = await _authHeaders();

    final response = await _client.get(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception("Failed load product detail");
    }

    final jsonData = json.decode(response.body);
    return ProductModel.fromJson(jsonData);
  }

  // ================= GET LIST MOLDS BY DRAWING =================
  Future<List<MoldModel>> fetchMoldsByDrawing(String drawingNumber) async {
    final url = Uri.parse(
      "${AppConfig.baseUrl}/api/mold-list-by-drawing/$drawingNumber/",
    );

    final headers = await _authHeaders();

    final response = await _client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MoldModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load molds');
    }
  }

  // ================= POST RECORD TESTING =================
  Future<http.Response> postRecordTesting(Map<String, dynamic> body) async {
    final url = Uri.parse("${AppConfig.baseUrl}/api/record-testing/");
    final headers = await _authHeaders();

    return _client
        .post(
          url,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
  }

  // ================= PATCH RECORD TESTING =================
  Future<http.Response> patchRecordTesting(Map<String, dynamic> body) async {
    final url = Uri.parse("${AppConfig.baseUrl}/api/record-testing/");
    final headers = await _authHeaders();

    return _client
        .patch(
          url,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
  }

  // ================= GET TESTING DETAIL =================
  Future<RecordTestingDetailResponse> getTestingDetail(
      String idRecordTest) async {
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/testing/detail/$idRecordTest/');

    final headers = await _authHeaders();

    final response = await _client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return RecordTestingDetailResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load testing detail');
    }
  }

// ============================ LIST MOLDING TESTING ==================

  Future<MonitorTestingModel> fetchOnProgressTesting() async {
    final url = Uri.parse("${AppConfig.baseUrl}/api/onprogress-testing/");
    final headers = {
      "Content-Type": "application/json",
    };

    final response = await _client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return MonitorTestingModel.fromJson(body);
    } else {
      throw Exception(
        "Failed to fetch testing data (${response.statusCode})",
      );
    }
  }
}
*/








































/*
import 'dart:convert';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/mold_model.dart';
import 'package:flutter_provider_data/model/product_model.dart';
import 'package:flutter_provider_data/model/check_proses_testing_model.dart';
import 'package:flutter_provider_data/model/record_testing_detail_response.dart';
import 'package:http/http.dart' as http;

class TestingService {
  final http.Client _client;
  TestingService(this._client);

  // ================= JOB NUMBER =================
  Future<CheckProsesTestingModel> checkJobNumber({
    required String jobNumber,
    required String idProses,
  }) async {
    final url = Uri.parse(
      "${AppConfig.baseUrl}/api/check-proses-jobnumber-testing/$jobNumber/$idProses/",
    );

    final response = await _client.get(url).timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode != 200) {
      throw Exception("Jobnumber not found");
    }

    final jsonData = json.decode(response.body);
    return CheckProsesTestingModel.fromJson(jsonData);
  }

  // ================= PRODUCT DETAIL =================
  Future<ProductModel> fetchProductDetail(String bcode) async {
    final url = Uri.parse("${AppConfig.baseUrl}/api/product-detail/$bcode/");
    final response = await _client.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed load product detail");
    }

    final jsonData = json.decode(response.body);
    return ProductModel.fromJson(
        jsonData); // pastikan ProductModel punya fromJson
  }

//===================== GET LIST MOLDS BY DRAW NUMBER ===================
  Future<List<MoldModel>> fetchMoldsByDrawing(String drawingNumber) async {
    final response = await http.get(
      Uri.parse(
          "${AppConfig.baseUrl}/api/mold-list-by-drawing/$drawingNumber/"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MoldModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load molds');
    }
  }

//POST DATA TESTING MOLDING
  Future<http.Response> postRecordTesting(Map<String, dynamic> body) async {
    final url = Uri.parse("${AppConfig.baseUrl}/api/record-testing/");
    return _client
        .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
  }

  Future<http.Response> patchRecordTesting(Map<String, dynamic> body) async {
    final url = Uri.parse("${AppConfig.baseUrl}/api/record-testing/");
    return _client
        .patch(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
  }

  Future<RecordTestingDetailResponse> getTestingDetail(
      String idRecordTest) async {
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/testing/detail/$idRecordTest/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return RecordTestingDetailResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load testing detail');
    }
  }
}
*/