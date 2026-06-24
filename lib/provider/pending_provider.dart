import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/record_pending_det_model.dart';
import 'package:flutter_provider_data/model/record_pending_detail_model.dart';
import 'package:flutter_provider_data/model/record_pending_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/service/pending_service.dart';
import 'package:flutter_provider_data/utils/logger.dart';

class PendingProvider extends ChangeNotifier {
  // ===================== SERVICE =====================
  final PendingService _service = PendingService();

  // ===================== DEPENDENCY =====================
  EmployeeProvider? _employeeProvider;

  void attachEmployeeProvider(EmployeeProvider provider) {
    _employeeProvider = provider;
  }

  // ===================== CONSTRUCTOR =====================
  PendingProvider.initial();

  // ===================== LOADING STATE =====================
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setLoading(bool value) => _setLoading(value);

  // ===================== SUBMIT STATE =====================
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void setSubmitting(bool value) => _setSubmitting(value);

  // ===================== ERROR STATE =====================
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ===================== CORE STATE =====================
  bool get isEmployeeScanned => hasConfirmedEmployee;
  String get employeeName =>
      hasConfirmedEmployee ? _confirmedEmployee.fullName : '';

  // ===================== EMPLOYEE CONFIRM =====================
  EmployeeModel _confirmedEmployee = EmployeeModel.empty;
  EmployeeModel get confirmedEmployee => _confirmedEmployee;
  bool get hasConfirmedEmployee => _confirmedEmployee.isValid;

  void confirmEmployee(EmployeeModel employee) {
    _confirmedEmployee = employee;
    _errorMessage = null;
    notifyListeners();
  }

  void clearConfirmedEmployee() {
    _confirmedEmployee = EmployeeModel.empty;
    notifyListeners();
  }

  void resetEmployeeScan() => clearConfirmedEmployee();

  void attachEmployee(EmployeeModel employee) {
    _confirmedEmployee = employee;
    _nextOperator = employee;
    notifyListeners();
  }

  void resetEmployeeScanState() {
    _confirmedEmployee = EmployeeModel.empty;
    _nextOperator = EmployeeModel.empty;
    _errorMessage = null;
    _isSubmitting = false;
    notifyListeners();
  }

  // ===================== MACHINE =====================
  String _nextMachineId = '';
  String _nextMachineName = '';

  String get nextMachineId => _nextMachineId;
  String get nextMachineName => _nextMachineName;
  bool get hasNextMachine => _nextMachineId.isNotEmpty;

  void setNextMachine({required String id, required String name}) {
    _nextMachineId = id;
    _nextMachineName = name;
    notifyListeners();
  }

  // ===================== PENDING LIST =====================
  List<RecordPendingModel> _allPending = [];
  List<RecordPendingModel> _filteredPending = [];

  List<RecordPendingModel> get pendingList => _filteredPending;
  List<RecordPendingModel> get filteredPending => _filteredPending;

  String _filterJobNumber = '';
  String _filterEmployeeFinishId = '';

  bool get isFilterActive =>
      _filterJobNumber.isNotEmpty || _filterEmployeeFinishId.isNotEmpty;

  // ===================== FETCH PENDING LIST =====================
  Future<void> fetchPending(String idProcess) async {
    _setLoading(true);
    _setError(null);

    try {
      _allPending = await _service.fetchPendingList(idProcess);
      _filteredPending = List.from(_allPending);
    } catch (e) {
      _allPending = [];
      _filteredPending = [];
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reload(String idProcess) async => await fetchPending(idProcess);

  // ===================== FILTER =====================
  set scannedJobNumber(String value) {
    _filterJobNumber = value;
    _applyFilter();
  }

  set scannedEmployeeFinishId(String value) {
    _filterEmployeeFinishId = value;
    _applyFilter();
  }

  void setJobNumberFilter(String value) {
    _filterJobNumber = value;
    _applyFilter();
  }

  void setEmployeeFinishFilter(String value) {
    _filterEmployeeFinishId = value;
    _applyFilter();
  }

  void clearFilter() {
    _filterJobNumber = '';
    _filterEmployeeFinishId = '';
    _filteredPending = List.from(_allPending);
    notifyListeners();
  }

  void _applyFilter() {
    _filteredPending = _allPending.where((item) {
      final matchJob =
          _filterJobNumber.isEmpty || item.jobnumber == _filterJobNumber;
      final matchEmployee = _filterEmployeeFinishId.isEmpty ||
          item.idEmployee == _filterEmployeeFinishId;
      return matchJob && matchEmployee;
    }).toList();
    notifyListeners();
  }

  // ===================== PENDING DETAIL (Simple) =====================
  List<RecordPendingDetailModel> _pendingDetail = [];
  List<RecordPendingDetailModel> get pendingDetail => _pendingDetail;

  String _storedEmployeeId = '';

  Future<void> fetchPendingDetail(String idPending) async {
    _setLoading(true);
    _setError(null);

    logPrint("Fetching pending detail for idPending: $idPending");

    try {
      _pendingDetail = await _service.fetchPendingDetail(idPending);
      if (_pendingDetail.isNotEmpty) {
        _storedEmployeeId = _pendingDetail.first.idEmployee;
      }
      logPrint("Fetched ${_pendingDetail.length} records");
    } catch (e) {
      _pendingDetail = [];
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void resetPendingDetail() {
    _pendingDetail = [];
    notifyListeners();
  }

  // ===================== PENDING DETAIL WITH NG =====================
  RecordPendingDetailModel _ngDetail =
      RecordPendingDetailModel.empty; // ✅ single object
  RecordPendingDetailModel get ngDetail => _ngDetail;

  bool _isNgLoading = false;
  bool get isNgLoading => _isNgLoading;

  String? _ngError;
  String? get ngError => _ngError;

  Future<void> loadPendingDetailWithNg(int idPending) async {
    _isNgLoading = true;
    _ngError = null;
    _ngDetail = RecordPendingDetailModel.empty;
    notifyListeners();

    try {
      _ngDetail = await _service.fetchWithNgDetail(idPending.toString());
    } catch (e) {
      _ngDetail = RecordPendingDetailModel.empty;
      _ngError = e.toString();
    } finally {
      _isNgLoading = false;
      notifyListeners();
    }
  }

  void resetNgDetail() {
    _ngDetail = RecordPendingDetailModel.empty;
    _ngError = null;
    notifyListeners();
  }

  // ===================== VALIDATION =====================
  bool get isEmployeeConfirmationValid =>
      hasConfirmedEmployee &&
      _confirmedEmployee.idEmployee == _storedEmployeeId;

  bool isEmployeeValid() => hasConfirmedEmployee;

  // ===================== SUBMIT =====================
  Future<bool> submitChangeMachine({
    required int idPending,
    required String idRecord, // ← tambah
  }) async {
    if (!hasConfirmedEmployee) {
      _setError("PLEASE CONFIRM EMPLOYEE");
      return false;
    }
    if (!hasNextMachine) {
      _setError("PLEASE SELECT MACHINE");
      return false;
    }
    if (!isEmployeeConfirmationValid) {
      _setError("EMPLOYEE CONFIRMATION MISMATCH");
      return false;
    }

    _setSubmitting(true);
    _setError(null);

    try {
      await _service.updateRecordPendingMc(
        idPending: idPending,
        idRecord: idRecord, // ← tambah
        idMachine: _nextMachineId,
      );
      clearConfirmedEmployee();
      clearNextMachine();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateRecordOpChange({required int idPending}) async {
    if (!hasConfirmedEmployee) {
      _setError("PLEASE CONFIRM EMPLOYEE");
      return false;
    }

    _setSubmitting(true);
    _setError(null);

    try {
      await _service.updateRecordOpChange(
        idPending: idPending,
        idEmployee: confirmedEmployee.idEmployee, // ✅ rename di sini
      );
      clearConfirmedEmployee();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> submitMassRecords(List<RecordPendingModel> records) async {
    _setSubmitting(true);
    _setError(null);
    try {
      await _service.updateMassRecords(records);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updatePendingRecordMc({
    required int idPending,
    required String idRecord, // ← tambah
  }) async {
    if (!hasNextMachine) {
      _setError("PLEASE SELECT MACHINE");
      return false;
    }

    _setSubmitting(true);
    _setError(null);

    try {
      await _service.updateRecordPendingMc(
        idPending: idPending,
        idRecord: idRecord, // ← tambah
        idMachine: _nextMachineId,
      );
      clearConfirmedEmployee();
      clearNextMachine();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updatePendingRecordNormal(int idPending) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _service.updateRecordPending(idPending: idPending);
      logPrint('✅ UPDATE SUCCESS — Response: $result');

      // clearConfirmedEmployee();
      resetEmployeeState();
      _pendingDetail = [];
      notifyListeners();
      return true;
    } catch (e) {
      logPrint('❌ UPDATE FAILED — Error: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===================== NEXT OPERATOR =====================
  EmployeeModel _nextOperator = EmployeeModel.empty;
  EmployeeModel get nextOperator => _nextOperator;
  bool get isNextOperatorReady => _nextOperator.isValid;

  String get photoNextOperator => _nextOperator.idEmployee.isNotEmpty
      ? "${_nextOperator.idEmployee}.png"
      : "employee.png";
  String get nameNextOperator => _nextOperator.fullName;
  String get nrpNextOperator => _nextOperator.nrp;
  String get divNextOperator => _nextOperator.division;
  String get secNextOperator => _nextOperator.section;

  void setNextOperator(EmployeeModel employee) {
    _nextOperator = employee;
    notifyListeners();
  }

  void resetNextOperator() {
    _nextOperator = EmployeeModel.empty;
    notifyListeners();
  }

  void confirmNextOperator(EmployeeModel employee) {
    _nextOperator = employee;
    notifyListeners();
  }

  void resetNextOperatorState() {
    _confirmedEmployee = EmployeeModel.empty;
    _nextOperator = EmployeeModel.empty;
    _errorMessage = null;
    notifyListeners();
  }

  // ===================== RECORD PENDING DETAIL (Det) =====================
  bool _isPendingLoading = false; // ✅ private
  bool get isPendingLoading => _isPendingLoading;

  String? _errorPendingMessage; // ✅ private
  String? get errorPendingMessage => _errorPendingMessage;

  RecordPendingDetModel? recordPending;
  bool get hasData => recordPending != null;

  Future<void> loadPendingDetail(String idRecord) async {
    _isPendingLoading = true;
    _errorPendingMessage = null;
    notifyListeners();

    try {
      recordPending = await _service.fetchRecordPendingDetail(idRecord);
    } catch (e) {
      _errorPendingMessage = e.toString();
      recordPending = null;
    } finally {
      _isPendingLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    recordPending = null;
    _errorPendingMessage = null;
    notifyListeners();
  }

  // ===================== RESET ALL =====================
  void resetAll() {
    _confirmedEmployee = EmployeeModel.empty;
    _nextOperator = EmployeeModel.empty;
    _nextMachineId = '';
    _nextMachineName = '';
    _errorMessage = null;
    _isSubmitting = false;
    notifyListeners();
  }

  Future<bool> updatePendingWorkdayOver({
    required int idPending,
    required String idEmployee,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Ambil idRecord dari pendingDetail yang sudah di-fetch sebelumnya
      // pastikan fetchPendingDetail sudah dipanggil sebelum halaman ini
      final idRecord =
          _pendingDetail.isNotEmpty ? _pendingDetail.first.idRecord : '';

      if (idRecord.isEmpty) {
        _setError("ID Record tidak ditemukan.");
        return false;
      }

      final result = await _service.updateRecordWorkover(
        idPending: idPending,
        idRecord: idRecord,
        idEmployee: idEmployee,
      );

      logPrint('✅ WORKOVER RESUME SUCCESS — Response: $result');

      clearConfirmedEmployee();
      _pendingDetail = [];
      notifyListeners();
      return true;
    } catch (e) {
      logPrint('❌ WORKOVER RESUME FAILED — Error: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// ================= CONTINUE WORKDAY OVER NEW OPERATOR =================
  Future<bool> continueWorkdayOverNewOperator({
    required String idRecord,
    required String idEmployeeLama,
    required String idEmployeeBaru,
    required int qtyShoot,
    required List<Map<String, dynamic>> ngData,
  }) async {
    _setSubmitting(true);
    _setError(null);

    try {
      final response = await _service.continueWorkdayOverNewOperator(
        idRecord: idRecord,
        idEmployeeLama: idEmployeeLama,
        idEmployeeBaru: idEmployeeBaru,
        qtyShoot: qtyShoot,
        ngData: ngData,
      );

      logPrint(
        'CONTINUE WORKDAY OVER SUCCESS: $response',
      );

      return true;
    } catch (e) {
      _setError(e.toString());

      logPrint(
        'CONTINUE WORKDAY OVER ERROR: $e',
      );

      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  void resetEmployeeState() {
    _confirmedEmployee = EmployeeModel.empty;
    _nextOperator = EmployeeModel.empty;
    _errorMessage = null;

    _employeeProvider?.clearEmployee();

    notifyListeners();
  }

  void clearNextMachine() {
    _nextMachineId = '';
    _nextMachineName = '';
    notifyListeners();
  }
}
