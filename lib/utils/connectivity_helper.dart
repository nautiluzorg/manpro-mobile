// lib/utils/connectivity_helper.dart

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  /// Cek cepat status koneksi device (WiFi/data aktif atau tidak).
  /// Catatan: ini cuma ngecek device "tersambung ke jaringan",
  /// bukan jaminan internetnya beneran nyampe ke luar.
  /// Makanya tetap ada lapisan kedua di AuthService (DioException handling).
  static Future<bool> hasInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
