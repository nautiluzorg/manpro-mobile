import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/machine_layout_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';
import 'package:flutter_provider_data/model/machine_model_dropdown.dart';
import 'package:flutter_provider_data/service/machine_service.dart';

class MachineProvider extends ChangeNotifier {
  final MachineService _service = MachineService();

  // =========================================================
  // PRIVATE STATE
  // =========================================================

  MachineModel _machine = MachineModel.empty;
  List<MachineModelDropdown> _machineList = [];
  List<MachineLayoutModel> _monitoringList = [];

  bool _isLoading = false;
  bool _isScanning = false;
  bool _isListLoading = false;
  bool _isMonitoringLoading = false;
  bool _isValidating = false;

  String? _errorMessage;
  String? _listError;
  String? _monitoringError;

  // =========================================================
  // GETTERS (READ-ONLY)
  // =========================================================

  MachineModel get machine => _machine;
  bool get hasMachine => _machine.idMc.isNotEmpty;

  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  bool get isListLoading => _isListLoading;
  bool get isMonitoringLoading => _isMonitoringLoading;
  bool get isValidating => _isValidating;

  String? get errorMessage => _errorMessage;
  String? get listError => _listError;
  String? get monitoringError => _monitoringError;

  List<MachineModelDropdown> get machineList => List.unmodifiable(_machineList);

  List<MachineLayoutModel> get monitoringList =>
      List.unmodifiable(_monitoringList);

  // =========================================================
  // PRIVATE HELPERS
  // =========================================================

  void _setMachine(MachineModel value, {bool notify = true}) {
    _machine = value;
    if (notify) notifyListeners();
  }

  void _setMachineList(List<MachineModelDropdown> value, {bool notify = true}) {
    _machineList = value;
    if (notify) notifyListeners();
  }

  void _setMonitoringList(List<MachineLayoutModel> value,
      {bool notify = true}) {
    _monitoringList = value;
    if (notify) notifyListeners();
  }

  void _setLoading(bool value, {bool notify = true}) {
    _isLoading = value;
    if (notify) notifyListeners();
  }

  void _setScanning(bool value, {bool notify = true}) {
    _isScanning = value;
    if (notify) notifyListeners();
  }

  void _setListLoading(bool value, {bool notify = true}) {
    _isListLoading = value;
    if (notify) notifyListeners();
  }

  void _setMonitoringLoading(bool value, {bool notify = true}) {
    _isMonitoringLoading = value;
    if (notify) notifyListeners();
  }

  void _setValidating(bool value, {bool notify = true}) {
    _isValidating = value;
    if (notify) notifyListeners();
  }

  void _setError(String? message, {bool notify = true}) {
    _errorMessage = message;
    if (notify) notifyListeners();
  }

  void _setListError(String? message, {bool notify = true}) {
    _listError = message;
    if (notify) notifyListeners();
  }

  void _setMonitoringError(String? message, {bool notify = true}) {
    _monitoringError = message;
    if (notify) notifyListeners();
  }

  // =========================================================
  // CLEAR STATE
  // =========================================================

  void clearMachine() {
    _machine = MachineModel.empty;
    _errorMessage = null;
    _isScanning = false;
    notifyListeners();
  }

  // =========================================================
  // SCAN MACHINE
  // =========================================================

  Future<String?> scanMachine(String code) async {
    if (!RegExp(r'^[a-zA-Z0-9\-]{10}$').hasMatch(code)) {
      return "INVALID QR CODE FORMAT OR NOT QR CODE MACHINE";
    }

    return await validateAndSetMachine(code);
  }

  Future<String?> validateAndSetMachine(String idMc) async {
    _setScanning(true);
    _setLoading(true);
    _setError(null);

    try {
      final validationError = await validateMachineDropdown(idMc);
      if (validationError != null) return validationError;

      final detail = await _service.getMachineDetail(idMc);
      _setMachine(detail);

      return null;
    } catch (e) {
      _setError("Error validasi mesin: $e");
      return _errorMessage;
    } finally {
      _setScanning(false);
      _setLoading(false);
    }
  }

  // =========================================================
  // VALIDATE MACHINE DROPDOWN
  // =========================================================

  Future<String?> validateMachineDropdown(String idMc) async {
    try {
      _setValidating(true);

      final result = await _service.checkMachineStatusDropdown(idMc);

      final status = result['status'];
      final runStatus = result['run_status'];
      final message = result['message'];

      if (status == 'in_use') return message ?? 'Machine sedang digunakan';
      if (runStatus == 'running') return message ?? 'Machine status RUNNING';

      return null;
    } catch (e) {
      return "Error validasi machine: $e";
    } finally {
      _setValidating(false);
    }
  }

  // =========================================================
  // LOAD MACHINE LIST
  // =========================================================

  Future<String?> loadMachines() async {
    _setListLoading(true);
    _setListError(null);

    try {
      final list = await _service.getAllMachines();
      _setMachineList(list, notify: false);
      return null;
    } catch (e) {
      _setMachineList([], notify: false);
      _setListError("Error loading machines: $e", notify: false);
      return _listError;
    } finally {
      _setListLoading(false);
      notifyListeners();
    }
  }

  // =========================================================
  // MONITORING
  // =========================================================

  Future<void> fetchMachineMonitoring() async {
    _setMonitoringLoading(true);
    _setMonitoringError(null);

    try {
      final list = await _service.getMachineLayoutStatus();
      _setMonitoringList(list, notify: false);
    } catch (e) {
      _setMonitoringList([], notify: false);
      _setMonitoringError(e.toString(), notify: false);
    } finally {
      _setMonitoringLoading(false);
      notifyListeners();
    }
  }

  void selectMachine(MachineModelDropdown machine) {
    _setMachine(
      MachineModel.empty.copyWith(
        idMc: machine.idMc,
        nmMc: machine.nmMc,
        areaMc: machine.areaMc,
      ),
    );
  }

  void setMachineDataFromMap(Map<String, dynamic>? data) {
    if (data == null) return;

    _setMachine(
      MachineModel.fromJson(data),
    );
  }

// =========================================================
// TESTING MACHINE
// =========================================================

  Future<String?> setMachineByIdTesting(String qrCode) async {
    if (_isValidating) {
      return "Validasi mesin sedang berjalan";
    }

    try {
      _setValidating(true, notify: false);
      _setLoading(true);

      final status = await _service.checkMachineStatusTesting(qrCode);

      if (status['status'] == 'in_use' && status['job_status'] == 'open') {
        return status['message'] ??
            "Mesin masih digunakan (TESTING masih OPEN)";
      }

      if (status['status'] == 'not_found') {
        return "Mesin tidak ditemukan";
      }

      // Ambil detail mesin
      final detail = await _service.getMachineDetail(qrCode);
      _setMachine(detail);

      return null;
    } catch (e) {
      return "Error: $e";
    } finally {
      _setLoading(false, notify: false);
      _setValidating(false);
    }
  }
}
