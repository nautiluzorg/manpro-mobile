import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/reason_dropdown_model.dart';
import 'package:flutter_provider_data/model/master/reason_model.dart';
import 'package:flutter_provider_data/model/record_running_det_model.dart';
import 'package:flutter_provider_data/model/record_running_detail_model.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/service/running_service.dart';
import 'package:flutter_provider_data/utils/logger.dart';

class RunningProvider extends ChangeNotifier {
  final RunningService service;

  RunningProvider({required this.service});

  // ===========================================================================
  // REGION: EMPLOYEE
  // ===========================================================================

  EmployeeModel? confirmedEmployee;
  bool isEmployeeScanned = false;
  bool isEmployeeConfirmed = false;
  String employeeName = '';
  String scannedEmployeeId = '';
  String idEmployeeConfirm = '';
  String nameEmployeeConfirm = '';

  String? _expectedEmployeeId;
  String? get expectedEmployeeId => _expectedEmployeeId;

  void setExpectedEmployeeId(String id) {
    _expectedEmployeeId = id;
    notifyListeners();
  }

  void resetExpectedEmployee() {
    _expectedEmployeeId = null;
    notifyListeners();
  }

  void confirmEmployeeFromSource(EmployeeModel employee) {
    setEmployee(employee);
    isEmployeeConfirmed = true;
  }

  void setEmployee(EmployeeModel employee) {
    confirmedEmployee = employee;
    idEmployeeConfirm = employee.idEmployee;
    nameEmployeeConfirm = employee.fullName;
    notifyListeners();
  }

  void clearEmployeeDependency() {
    isEmployeeConfirmed = false;
    // Tidak reset EmployeeProvider di sini (decoupled)
  }

  Future<void> scanEmployee(
      String code, EmployeeProvider employeeProvider) async {
    setLoading(true);

    try {
      final success = await employeeProvider.scanEmployee(code);

      if (!success) {
        clearEmployeeDependency();
        return;
      }

      setEmployee(employeeProvider.employee);
      isEmployeeConfirmed = true;
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, String>?> validateEmployee(String qrCode) async {
    try {
      final data = await service.getEmployeeDetail(qrCode);

      if (data.isEmpty) {
        throw Exception("Data employee kosong atau tidak ditemukan");
      }

      if (!data.containsKey('id_employee')) {
        throw Exception("Employee ID tidak ditemukan");
      }

      if (data['status'] == "02") {
        throw Exception("Employee tidak aktif");
      }

      return {
        'id': data["id_employee"].toString(),
        'name': data['full_name'] ?? 'Unknown',
        'photo': "${data["id_employee"]}.png",
      };
    } catch (e) {
      logPrint("ERROR validateEmployee → $e");
      rethrow;
    }
  }

  // ===========================================================================
  // REGION: FILTER
  // ===========================================================================

  String scannedFilterJobNumber = '';
  String scannedFilterEmployee = '';

  bool get isFilterSearchActive =>
      scannedFilterJobNumber.isNotEmpty || scannedFilterEmployee.isNotEmpty;

  bool get isSearchDisabled => isFilterSearchActive;

  void setFilterSearch({String? jobNumber, String? employee}) {
    if (jobNumber != null) scannedFilterJobNumber = jobNumber;
    if (employee != null) scannedFilterEmployee = employee;
    notifyListeners();
  }

  void clearFilterSearch() {
    scannedFilterJobNumber = '';
    scannedFilterEmployee = '';
    notifyListeners();
  }

  // ===========================================================================
  // REGION: REASON DROPDOWN
  // ===========================================================================

  List<ReasonDropdownModel> _reasonItems = [];
  List<ReasonDropdownModel> get reasonItems => _reasonItems;

  ReasonDropdownModel? _selectedReason;
  ReasonDropdownModel? get selectedReason => _selectedReason;

  bool _isLoadingReason = false;
  bool get isLoadingReason => _isLoadingReason;

  String? _reasonErrorMessage;
  String? get reasonErrorMessage => _reasonErrorMessage;

  // getter untuk button CONFIRM
  bool get canConfirm => _selectedReason != null;

  void setSelectedReason(ReasonDropdownModel? reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  Future<void> loadReasonItems() async {
    _isLoadingReason = true;
    _reasonErrorMessage = null;
    notifyListeners();

    try {
      _reasonItems = await service.fetchReasonItems();
    } catch (e) {
      _reasonItems = [];
      _reasonErrorMessage = e.toString();
    }

    _isLoadingReason = false;
    notifyListeners();
  }

  Future<List<ReasonModel>> getReasonList() async {
    try {
      final reasons = await service.fetchReasonList();
      return reasons;
    } catch (e) {
      _reasonErrorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // ===========================================================================
  // REGION: RECORD LIST
  // ===========================================================================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<RecordRunningModel> _allRecords = [];
  List<RecordRunningModel> get allRecords => _allRecords;

  List<RecordRunningModel> get filteredRecords {
    if (!isFilterSearchActive) return _allRecords;

    return _allRecords.where((item) {
      final jobnumber = (item.detailsRecord.isNotEmpty)
          ? item.detailsRecord[0].jobNumber
          : '';
      final employeeId = (item.activeEmployee?.idEmployee).toString();

      final matchJob = scannedFilterJobNumber.isEmpty ||
          jobnumber.trim().toLowerCase() ==
              scannedFilterJobNumber.trim().toLowerCase();

      final matchEmployee = scannedFilterEmployee.isEmpty ||
          employeeId.trim().toLowerCase() ==
              scannedFilterEmployee.trim().toLowerCase();

      return matchJob && matchEmployee;
    }).toList();
  }

  Future<void> loadRunningRecords(String idProses) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final data = await service.fetchRunningRecords(idProses);
      _allRecords = data;
      clearFilterSearch();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _allRecords = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String idProses) async {
    _hasError = false;
    _errorMessage = '';

    try {
      final data = await service.fetchRunningRecords(idProses);
      _allRecords = data;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      // tidak clear _allRecords saat refresh — data lama tetap tampil
    } finally {
      notifyListeners();
    }
  }

  // ===========================================================================
  // REGION: RECORD DETAIL
  // ===========================================================================

  List<RecordRunningDetailModel> _recordDetails = [];
  List<RecordRunningDetailModel> get recordDetails => _recordDetails;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  String? _detailErrorMessage;
  String? get detailErrorMessage => _detailErrorMessage;

  int _shootRemain = 0;
  int get shootRemain => _shootRemain;

  Future<void> loadRecordDetail(String idRecord) async {
    _isLoadingDetails = true;
    _detailErrorMessage = null;
    notifyListeners();

    try {
      _recordDetails = await service.fetchRecordDetail(idRecord);

      if (_recordDetails.isNotEmpty &&
          _recordDetails[0].detailsRecord.isNotEmpty) {
        _expectedEmployeeId = _recordDetails[0].activeEmployee.idEmployee;

        final initialShootQty = _recordDetails[0].detailsRecord[0].shootQty;
        initShootRemain(initialShootQty);
      }
    } catch (e) {
      _recordDetails = [];
      _detailErrorMessage = e.toString();
      _expectedEmployeeId = null;
    }

    _isLoadingDetails = false;
    notifyListeners();
  }

  void initShootRemain(int initialShootQty) {
    _shootRemain = initialShootQty;
    notifyListeners();
  }

  void updateShootRemain(int shootFinished, int maxQty) {
    _shootRemain = (maxQty - shootFinished).clamp(0, maxQty);
    notifyListeners();
  }

  // ===========================================================================
  // REGION: RUNNING DETAIL (TESTING)
  // ===========================================================================

  bool isTestingLoading = false;
  RecordRunningDetModel? detail;
  String? error;

  Future<void> fetchRunningDetail(String idRecordTest) async {
    isTestingLoading = true;
    error = null;
    notifyListeners();

    try {
      detail = await service.getRunningDetail(idRecordTest);
    } catch (e) {
      error = e.toString();
    }

    isTestingLoading = false;
    notifyListeners();
  }

  // ===========================================================================
  // REGION: SELECTED ITEMS
  // ===========================================================================

  List<RecordRunningModel> _selectedItems = [];
  List<RecordRunningModel> get selectedItems => _selectedItems;

  void setSelectedItems(List<RecordRunningModel> items) {
    _selectedItems = items;
    notifyListeners();
  }

  void addSelectedItem(RecordRunningModel item) {
    _selectedItems.add(item);
    notifyListeners();
  }

  void removeSelectedItem(RecordRunningModel item) {
    _selectedItems.remove(item);
    notifyListeners();
  }

  void toggleSelectedItem(RecordRunningModel item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
    notifyListeners();
  }

  void clearSelectedItems() {
    _selectedItems.clear();
    notifyListeners();
  }

  // ===========================================================================
  // REGION: SUBMIT / STOP / PENDING
  // ===========================================================================

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isLoadingStop = false;
  bool get isLoadingStop => _isLoadingStop;

  String? _submitMessage;
  String? get submitMessage => _submitMessage;

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void setLoadingStop(bool value) {
    _isLoadingStop = value;
    notifyListeners();
  }

  Future<bool> submitChangeOperatorData({
    required String idRecord,
    required String idReason,
    required String idEmployee,
    required String idProses,
    required String bcode,
    required int shootQty,
    required List<Map<String, dynamic>> ngList,
  }) async {
    setLoadingStop(true);
    _errorMessage = '';
    notifyListeners();

    try {
      return await service.submitChangeOperator(
        idRecord: idRecord,
        idReason: idReason,
        idEmployee: idEmployee,
        idProses: idProses,
        bcode: bcode,
        shootQty: shootQty,
        ngList: ngList,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoadingStop(false);
      notifyListeners();
    }
  }

  Future<bool> submitChangeMachineData({
    required String idRecord,
    required String idReason,
    required String idEmployee,
    required String idProses,
    required String bcode,
    required int shootQty,
    String? idMachine,
  }) async {
    setLoadingStop(true);
    _errorMessage = '';
    notifyListeners();

    try {
      return await service.submitChangeMachine(
        idRecord: idRecord,
        idReason: idReason,
        idEmployee: idEmployee,
        idProses: idProses,
        bcode: bcode,
        shootQty: shootQty,
        idMachine: idMachine,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoadingStop(false);
      notifyListeners();
    }
  }

  Future<bool> submitWorkdayOverData({
    required String idRecord,
    required String idEmployee,
    required String idProses,
    required String bcode,
  }) async {
    setLoadingStop(true);
    _errorMessage = '';
    notifyListeners();

    try {
      return await service.submitWorkdayOver(
        idRecord: idRecord,
        idEmployee: idEmployee,
        idProses: idProses,
        bcode: bcode,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoadingStop(false);
      notifyListeners();
    }
  }

  Future<bool> submitRecordStopData({
    required String idRecord,
    required String idReason,
    required String idEmployee,
    required String idProses,
    required String bcode,
  }) async {
    setLoadingStop(true);
    _errorMessage = '';
    notifyListeners();

    try {
      return await service.submitRecordStop(
        idRecord: idRecord,
        idReason: idReason,
        idEmployee: idEmployee,
        idProses: idProses,
        bcode: bcode,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoadingStop(false);
      notifyListeners();
    }
  }

  Future<bool> stopRecords({
    required List<RecordRunningModel> selectedRecords,
    required String idReason,
  }) async {
    if (selectedRecords.isEmpty) {
      _submitMessage = "Belum ada data yang dipilih.";
      notifyListeners();
      return false;
    }

    final first = selectedRecords.first.activeEmployee?.fullName ?? '';
    final sameEmployee = selectedRecords.every(
      (e) => e.activeEmployee?.fullName == first,
    );

    if (!sameEmployee) {
      _submitMessage = "Operator harus sama.";
      notifyListeners();
      return false;
    }

    _isLoadingStop = true;
    notifyListeners();

    try {
      final result = await service.stopRunningRecord(
        selectedRecordIds: selectedRecords.map((e) => e.idRecord).toList(),
        idReason: idReason,
        idEmployeeFinish:
            selectedRecords.first.activeEmployee?.idEmployee ?? '',
      );

      _submitMessage = result["message"] ?? "Stop success";
      notifyListeners();
      return true;
    } catch (e) {
      _submitMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoadingStop = false;
      notifyListeners();
    }
  }

  Future<bool> postPending(
    List<RecordRunningModel> selectedItems,
    ReasonDropdownModel? selectedReason,
    String idProses,
  ) async {
    if (_isSubmitting) return false; // cegah double click
    if (selectedReason == null) return false;

    try {
      setSubmitting(true);
      setLoading(true);

      logPrint("=== DEBUG POST PENDING ===");
      logPrint("selectedReason.idReason: ${selectedReason.idReason}");
      for (final item in selectedItems) {
        logPrint(
            "bcode: ${item.detailsRecord.isNotEmpty ? item.detailsRecord[0].bcode : 'KOSONG'}");
        logPrint("idProses: ${item.idProses}");
        logPrint("idEmployee: ${item.activeEmployee?.idEmployee}");
      }
      logPrint("==========================");

      final success = await service.postPendingRecords(
        selectedItems: selectedItems,
        selectedReason: selectedReason,
      );

      logPrint("postPendingRecords result: $success");

      clearSelectedItems();
      await refresh(idProses);
      clearFilterSearch();

      return success;
    } catch (e) {
      logPrint("POST PENDING ERROR → $e");
      return false;
    } finally {
      setLoading(false);
      setSubmitting(false);
    }
  }

  // ===========================================================================
  // REGION: UTILITY & RESET
  // ===========================================================================

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void resetConfirm() {
    _selectedReason = null;
    confirmedEmployee = null;
    isEmployeeConfirmed = false;
    idEmployeeConfirm = '';
    nameEmployeeConfirm = '';
    notifyListeners();
  }

  void resetSuccessSubmit() {
    _selectedReason = null;
    confirmedEmployee = null;
    isEmployeeConfirmed = false;
    idEmployeeConfirm = '';
    nameEmployeeConfirm = '';
    _expectedEmployeeId = null;
    _selectedItems.clear();
    notifyListeners();
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/reason_dropdown_model.dart';
import 'package:flutter_provider_data/model/master/reason_model.dart';
import 'package:flutter_provider_data/model/record_running_det_model.dart';
import 'package:flutter_provider_data/model/record_running_detail_model.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/service/running_service.dart';
import 'package:flutter_provider_data/utils/logger.dart';

class RunningProvider extends ChangeNotifier {
  final RunningService service;

  RunningProvider({required this.service});

  // ===========================================================================
  // REGION: EMPLOYEE
  // ===========================================================================

  EmployeeModel? confirmedEmployee;
  bool isEmployeeScanned = false;
  bool isEmployeeConfirmed = false;
  String employeeName = '';
  String scannedEmployeeId = '';
  String idEmployeeConfirm = '';
  String nameEmployeeConfirm = '';

  String? _expectedEmployeeId;
  String? get expectedEmployeeId => _expectedEmployeeId;

  void setExpectedEmployeeId(String id) {
    _expectedEmployeeId = id;
    notifyListeners();
  }

  void resetExpectedEmployee() {
    _expectedEmployeeId = null;
    notifyListeners();
  }

  void confirmEmployeeFromSource(EmployeeModel employee) {
    setEmployee(employee);
    isEmployeeConfirmed = true;
  }

  void setEmployee(EmployeeModel employee) {
    confirmedEmployee = employee;
    idEmployeeConfirm = employee.idEmployee;
    nameEmployeeConfirm = employee.fullName;
    notifyListeners();
  }

  void clearEmployeeDependency() {
    isEmployeeConfirmed = false;
    // Tidak reset EmployeeProvider di sini (decoupled)
  }

  Future<void> scanEmployee(
      String code, EmployeeProvider employeeProvider) async {
    setLoading(true);

    try {
      final success = await employeeProvider.scanEmployee(code);

      if (!success) {
        clearEmployeeDependency();
        return;
      }

      setEmployee(employeeProvider.employee);
      isEmployeeConfirmed = true;
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, String>?> validateEmployee(String qrCode) async {
    try {
      final data = await service.getEmployeeDetail(qrCode);

      if (data.isEmpty) {
        throw Exception("Data employee kosong atau tidak ditemukan");
      }

      if (!data.containsKey('id_employee')) {
        throw Exception("Employee ID tidak ditemukan");
      }

      if (data['status'] == "02") {
        throw Exception("Employee tidak aktif");
      }

      return {
        'id': data["id_employee"].toString(),
        'name': data['full_name'] ?? 'Unknown',
        'photo': "${data["id_employee"]}.png",
      };
    } catch (e) {
      logPrint("ERROR validateEmployee → $e");
      rethrow;
    }
  }

  // ===========================================================================
  // REGION: FILTER
  // ===========================================================================

  String scannedFilterJobNumber = '';
  String scannedFilterEmployee = '';

  bool get isFilterSearchActive =>
      scannedFilterJobNumber.isNotEmpty || scannedFilterEmployee.isNotEmpty;

  bool get isSearchDisabled => isFilterSearchActive;

  void setFilterSearch({String? jobNumber, String? employee}) {
    if (jobNumber != null) scannedFilterJobNumber = jobNumber;
    if (employee != null) scannedFilterEmployee = employee;
    notifyListeners();
  }

  void clearFilterSearch() {
    scannedFilterJobNumber = '';
    scannedFilterEmployee = '';
    notifyListeners();
  }

  // ===========================================================================
  // REGION: REASON DROPDOWN
  // ===========================================================================

  List<ReasonDropdownModel> _reasonItems = [];
  List<ReasonDropdownModel> get reasonItems => _reasonItems;

  ReasonDropdownModel? _selectedReason;
  ReasonDropdownModel? get selectedReason => _selectedReason;

  bool _isLoadingReason = false;
  bool get isLoadingReason => _isLoadingReason;

  String? _reasonErrorMessage;
  String? get reasonErrorMessage => _reasonErrorMessage;

  // getter untuk button CONFIRM
  bool get canConfirm => _selectedReason != null;

  void setSelectedReason(ReasonDropdownModel? reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  Future<void> loadReasonItems() async {
    _isLoadingReason = true;
    _reasonErrorMessage = null;
    notifyListeners();

    try {
      _reasonItems = await service.fetchReasonItems();
    } catch (e) {
      _reasonItems = [];
      _reasonErrorMessage = e.toString();
    }

    _isLoadingReason = false;
    notifyListeners();
  }

  Future<List<ReasonModel>> getReasonList() async {
    try {
      final reasons = await service.fetchReasonList();
      return reasons;
    } catch (e) {
      _reasonErrorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // ===========================================================================
  // REGION: RECORD LIST
  // ===========================================================================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<RecordRunningModel> _allRecords = [];
  List<RecordRunningModel> get allRecords => _allRecords;

  List<RecordRunningModel> get filteredRecords {
    if (!isFilterSearchActive) return _allRecords;

    return _allRecords.where((item) {
      final jobnumber = (item.detailsRecord.isNotEmpty)
          ? item.detailsRecord[0].jobNumber
          : '';
      final employeeId = (item.activeEmployee?.idEmployee).toString();

      final matchJob = scannedFilterJobNumber.isEmpty ||
          jobnumber.trim().toLowerCase() ==
              scannedFilterJobNumber.trim().toLowerCase();

      final matchEmployee = scannedFilterEmployee.isEmpty ||
          employeeId.trim().toLowerCase() ==
              scannedFilterEmployee.trim().toLowerCase();

      return matchJob && matchEmployee;
    }).toList();
  }

  Future<void> loadRunningRecords(String idProses) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final data = await service.fetchRunningRecords(idProses);
      _allRecords = data;
      clearFilterSearch();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _allRecords = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String idProses) async {
    _hasError = false;
    _errorMessage = '';

    try {
      final data = await service.fetchRunningRecords(idProses);
      _allRecords = data;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      // tidak clear _allRecords saat refresh — data lama tetap tampil
    } finally {
      notifyListeners();
    }
  }

  // ===========================================================================
  // REGION: RECORD DETAIL
  // ===========================================================================

  List<RecordRunningDetailModel> _recordDetails = [];
  List<RecordRunningDetailModel> get recordDetails => _recordDetails;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  String? _detailErrorMessage;
  String? get detailErrorMessage => _detailErrorMessage;

  int _shootRemain = 0;
  int get shootRemain => _shootRemain;

  Future<void> loadRecordDetail(String idRecord) async {
    _isLoadingDetails = true;
    _detailErrorMessage = null;
    notifyListeners();

    try {
      _recordDetails = await service.fetchRecordDetail(idRecord);

      if (_recordDetails.isNotEmpty &&
          _recordDetails[0].detailsRecord.isNotEmpty) {
        _expectedEmployeeId = _recordDetails[0].activeEmployee.idEmployee;

        final initialShootQty = _recordDetails[0].detailsRecord[0].shootQty;
        initShootRemain(initialShootQty);
      }
    } catch (e) {
      _recordDetails = [];
      _detailErrorMessage = e.toString();
      _expectedEmployeeId = null;
    }

    _isLoadingDetails = false;
    notifyListeners();
  }

  void initShootRemain(int initialShootQty) {
    _shootRemain = initialShootQty;
    notifyListeners();
  }

  void updateShootRemain(int shootFinished, int maxQty) {
    _shootRemain = (maxQty - shootFinished).clamp(0, maxQty);
    notifyListeners();
  }

  // ===========================================================================
  // REGION: RUNNING DETAIL (TESTING)
  // ===========================================================================

  bool isTestingLoading = false;
  RecordRunningDetModel? detail;
  String? error;

  Future<void> fetchRunningDetail(String idRecordTest) async {
    isTestingLoading = true;
    error = null;
    notifyListeners();

    try {
      detail = await service.getRunningDetail(idRecordTest);
    } catch (e) {
      error = e.toString();
    }

    isTestingLoading = false;
    notifyListeners();
  }

  // ===========================================================================
  // REGION: SELECTED ITEMS
  // ===========================================================================

  List<RecordRunningModel> _selectedItems = [];
  List<RecordRunningModel> get selectedItems => _selectedItems;

  void setSelectedItems(List<RecordRunningModel> items) {
    _selectedItems = items;
    notifyListeners();
  }

  void addSelectedItem(RecordRunningModel item) {
    _selectedItems.add(item);
    notifyListeners();
  }

  void removeSelectedItem(RecordRunningModel item) {
    _selectedItems.remove(item);
    notifyListeners();
  }

  void toggleSelectedItem(RecordRunningModel item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
    notifyListeners();
  }

  void clearSelectedItems() {
    _selectedItems.clear();
    notifyListeners();
  }

  // ===========================================================================
  // REGION: SUBMIT / STOP / PENDING
  // ===========================================================================

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isLoadingStop = false;
  bool get isLoadingStop => _isLoadingStop;

  String? _submitMessage;
  String? get submitMessage => _submitMessage;

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void setLoadingStop(bool value) {
    _isLoadingStop = value;
    notifyListeners();
  }

  Future<bool> submitChangeOperatorData({
    required String idRecord,
    required String idReason,
    required String idEmployee,
    required String idProses,
    required String bcode,
    required int shootQty,
    required List<Map<String, dynamic>> ngList,
  }) async {
    setLoadingStop(true);
    _errorMessage = '';
    notifyListeners();

    try {
      return await service.submitChangeOperator(
        idRecord: idRecord,
        idReason: idReason,
        idEmployee: idEmployee,
        idProses: idProses,
        bcode: bcode,
        shootQty: shootQty,
        ngList: ngList,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoadingStop(false);
      notifyListeners();
    }
  }

  Future<bool> submitChangeMachineData({
    required String idRecord,
    required String idReason,
    required String idEmployee,
    required String idProses,
    required String bcode,
    required int shootQty,
    String? idMachine,
  }) async {
    setLoadingStop(true);
    _errorMessage = '';
    notifyListeners();

    try {
      return await service.submitChangeMachine(
        idRecord: idRecord,
        idReason: idReason,
        idEmployee: idEmployee,
        idProses: idProses,
        bcode: bcode,
        shootQty: shootQty,
        idMachine: idMachine,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoadingStop(false);
      notifyListeners();
    }
  }

  Future<bool> submitWorkdayOverData({
    required String idRecord,
    required String idEmployee,
    required String idProses,
    required String bcode,
  }) async {
    setLoadingStop(true);
    _errorMessage = '';
    notifyListeners();

    try {
      return await service.submitWorkdayOver(
        idRecord: idRecord,
        idEmployee: idEmployee,
        idProses: idProses,
        bcode: bcode,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoadingStop(false);
      notifyListeners();
    }
  }

  Future<bool> submitRecordStopData({
    required String idRecord,
    required String idReason,
    required String idEmployee,
    required String idProses,
    required String bcode,
  }) async {
    setLoadingStop(true);
    _errorMessage = '';
    notifyListeners();

    try {
      return await service.submitRecordStop(
        idRecord: idRecord,
        idReason: idReason,
        idEmployee: idEmployee,
        idProses: idProses,
        bcode: bcode,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoadingStop(false);
      notifyListeners();
    }
  }

  Future<bool> stopRecords({
    required List<RecordRunningModel> selectedRecords,
    required String idReason,
  }) async {
    if (selectedRecords.isEmpty) {
      _submitMessage = "Belum ada data yang dipilih.";
      notifyListeners();
      return false;
    }

    final first = selectedRecords.first.activeEmployee?.fullName ?? '';
    final sameEmployee = selectedRecords.every(
      (e) => e.activeEmployee?.fullName == first,
    );

    if (!sameEmployee) {
      _submitMessage = "Operator harus sama.";
      notifyListeners();
      return false;
    }

    _isLoadingStop = true;
    notifyListeners();

    try {
      final result = await service.stopRunningRecord(
        selectedRecordIds: selectedRecords.map((e) => e.idRecord).toList(),
        idReason: idReason,
        idEmployeeFinish:
            selectedRecords.first.activeEmployee?.idEmployee ?? '',
      );

      _submitMessage = result["message"] ?? "Stop success";
      notifyListeners();
      return true;
    } catch (e) {
      _submitMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoadingStop = false;
      notifyListeners();
    }
  }

  Future<bool> postPending(
    List<RecordRunningModel> selectedItems,
    ReasonDropdownModel? selectedReason,
    String idProses,
  ) async {
    if (_isSubmitting) return false; // cegah double click
    if (selectedReason == null) return false;

    try {
      setSubmitting(true);
      setLoading(true);

      logPrint("=== DEBUG POST PENDING ===");
      logPrint("selectedReason.idReason: ${selectedReason.idReason}");
      selectedItems.forEach((item) {
        logPrint(
            "bcode: ${item.detailsRecord.isNotEmpty ? item.detailsRecord[0].bcode : 'KOSONG'}");
        logPrint("idProses: ${item.idProses}");
        logPrint("idEmployee: ${item.activeEmployee?.idEmployee}");
      });
      logPrint("==========================");

      final success = await service.postPendingRecords(
        selectedItems: selectedItems,
        selectedReason: selectedReason,
      );

      logPrint("postPendingRecords result: $success");

      clearSelectedItems();
      await refresh(idProses);
      clearFilterSearch();

      return success;
    } catch (e) {
      logPrint("POST PENDING ERROR → $e");
      return false;
    } finally {
      setLoading(false);
      setSubmitting(false);
    }
  }

  // ===========================================================================
  // REGION: UTILITY & RESET
  // ===========================================================================

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void resetConfirm() {
    _selectedReason = null;
    confirmedEmployee = null;
    isEmployeeConfirmed = false;
    idEmployeeConfirm = '';
    nameEmployeeConfirm = '';
    notifyListeners();
  }

  void resetSuccessSubmit() {
    _selectedReason = null;
    confirmedEmployee = null;
    isEmployeeConfirmed = false;
    idEmployeeConfirm = '';
    nameEmployeeConfirm = '';
    _expectedEmployeeId = null;
    _selectedItems.clear();
    notifyListeners();
  }
}
*/
