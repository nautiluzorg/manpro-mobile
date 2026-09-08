// lib/service/connectivity_service.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../utils/app_logger.dart';

/// Status koneksi MANPRO.
///
/// checking     = sedang melakukan pengecekan
/// noNetwork    = device tidak mempunyai koneksi network
/// serverDown   = network tersedia tetapi server MANPRO tidak dapat dijangkau
/// connected    = network tersedia dan server MANPRO dapat dijangkau
enum ManproConnectionStatus {
  checking,
  noNetwork,
  serverDown,
  connected,
}

class ConnectivityService {
  ConnectivityService._internal();

  /// Singleton.
  ///
  /// Hanya ada satu ConnectivityService
  /// untuk seluruh aplikasi MANPRO.
  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  /// ============================================================
  /// DIO KHUSUS HEALTH-CHECK
  /// ============================================================
  ///
  /// Tidak menggunakan DioClient.authDio karena kita ingin
  /// health-check mempunyai timeout sendiri.
  ///
  /// Health-check juga tidak membutuhkan JWT / Authorization.
  ///
  final Dio _healthDio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {
        "Content-Type": "application/json",
      },

      // Health-check harus relatif cepat.
      connectTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Timer? _healthCheckTimer;

  final StreamController<ManproConnectionStatus> _statusController =
      StreamController<ManproConnectionStatus>.broadcast();

  ManproConnectionStatus _status = ManproConnectionStatus.checking;

  bool _isInitialized = false;

  bool _isChecking = false;

  /// Status koneksi terakhir.
  ManproConnectionStatus get status => _status;

  /// TRUE hanya jika:
  ///
  /// 1. Device mempunyai network
  /// 2. Server MANPRO berhasil memberikan HTTP 200
  bool get isConnected => _status == ManproConnectionStatus.connected;

  /// Stream perubahan status koneksi.
  Stream<ManproConnectionStatus> get statusStream => _statusController.stream;

  // ============================================================
  // INITIALIZE
  // ============================================================

  /// Inisialisasi monitoring koneksi.
  ///
  /// Aman dipanggil berkali-kali karena hanya akan
  /// melakukan initialization satu kali.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;

    AppLogger.i(
      "ConnectivityService: initialization started",
    );

    // ==========================================================
    // STATUS AWAL
    // ==========================================================

    _updateStatus(
      ManproConnectionStatus.checking,
    );

    // ==========================================================
    // HEALTH CHECK PERTAMA
    // ==========================================================

    await checkConnection();

    // ==========================================================
    // MONITOR PERUBAHAN NETWORK
    // ==========================================================

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        AppLogger.i(
          "Network connectivity changed: $results",
        );

        // ======================================================
        // TIDAK ADA NETWORK
        // ======================================================

        if (results.contains(ConnectivityResult.none)) {
          _updateStatus(
            ManproConnectionStatus.noNetwork,
          );

          return;
        }

        // ======================================================
        // NETWORK ADA
        // ======================================================
        //
        // Jangan langsung menyatakan CONNECTED.
        //
        // Tetap lakukan health-check ke server MANPRO.
        //

        await checkConnection();
      },
      onError: (error) {
        AppLogger.e(
          "Connectivity stream error",
          error,
        );

        _updateStatus(
          ManproConnectionStatus.noNetwork,
        );
      },
    );

    // ==========================================================
    // PERIODIC HEALTH CHECK
    // ==========================================================
    //
    // Walaupun Wi-Fi tidak berubah, server MANPRO
    // bisa saja down.
    //
    // Oleh karena itu lakukan health-check setiap 30 detik.
    //

    _healthCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        await checkConnection();
      },
    );
  }

  // ============================================================
  // CHECK CONNECTION
  // ============================================================

  /// Mengecek koneksi MANPRO secara berlapis.
  ///
  /// Layer 1:
  /// Apakah device mempunyai network?
  ///
  /// Layer 2:
  /// Apakah server MANPRO dapat dijangkau?
  Future<bool> checkConnection() async {
    // ==========================================================
    // CEGAH HEALTH-CHECK BERTUMPUK
    // ==========================================================

    if (_isChecking) {
      return isConnected;
    }

    _isChecking = true;

    try {
      // ========================================================
      // LAYER 1 - CHECK NETWORK
      // ========================================================

      final connectivity = await _connectivity.checkConnectivity();

      if (connectivity.contains(ConnectivityResult.none)) {
        AppLogger.w(
          "MANPRO: device tidak memiliki network",
        );

        _updateStatus(
          ManproConnectionStatus.noNetwork,
        );

        return false;
      }

      // ========================================================
      // LAYER 2 - CHECK SERVER MANPRO
      // ========================================================

      _updateStatus(
        ManproConnectionStatus.checking,
      );

      AppLogger.i(
        "MANPRO health-check: ${ApiConfig.health}",
      );

      final response = await _healthDio.get(
        ApiConfig.health,
      );

      // ========================================================
      // SERVER MANPRO SEHAT
      // ========================================================

      if (response.statusCode == 200) {
        AppLogger.i(
          "MANPRO server: CONNECTED",
        );

        _updateStatus(
          ManproConnectionStatus.connected,
        );

        return true;
      }

      // ========================================================
      // SERVER MEMBERIKAN HTTP ERROR
      // ========================================================

      AppLogger.w(
        "MANPRO server response tidak sehat. "
        "HTTP ${response.statusCode}",
      );

      _updateStatus(
        ManproConnectionStatus.serverDown,
      );

      return false;
    } on DioException catch (e) {
      // ========================================================
      // SERVER TIDAK DAPAT DIJANGKAU
      // ========================================================

      AppLogger.w(
        "MANPRO health-check gagal: ${e.type}",
      );

      _updateStatus(
        ManproConnectionStatus.serverDown,
      );

      return false;
    } catch (e) {
      // ========================================================
      // ERROR LAINNYA
      // ========================================================

      AppLogger.e(
        "MANPRO health-check unexpected error",
        e,
      );

      _updateStatus(
        ManproConnectionStatus.serverDown,
      );

      return false;
    } finally {
      _isChecking = false;
    }
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  /// Mengubah status dan broadcast ke listener.
  void _updateStatus(
    ManproConnectionStatus newStatus,
  ) {
    // Jangan broadcast kalau status tidak berubah.
    if (_status == newStatus) {
      return;
    }

    _status = newStatus;

    if (!_statusController.isClosed) {
      _statusController.add(newStatus);
    }

    AppLogger.i(
      "MANPRO connection status: "
      "${newStatus.name}",
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  /// Membersihkan seluruh resource.
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();

    _connectivitySubscription = null;

    _healthCheckTimer?.cancel();

    _healthCheckTimer = null;

    _healthDio.close();

    if (!_statusController.isClosed) {
      await _statusController.close();
    }

    _isInitialized = false;

    AppLogger.i(
      "ConnectivityService: disposed",
    );
  }
}
