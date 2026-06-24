import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_active_model.dart';
import 'package:flutter_provider_data/service/record_service.dart';

class RecordProvider extends ChangeNotifier {
  final RecordService service;

  RecordProvider({required this.service});

  // =================== STATE LIST ===================
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<RecordActiveModel> _allRecords = [];
  List<RecordActiveModel> get allRecords => _allRecords;

  List<RecordActiveModel> _filteredRecords = [];
  List<RecordActiveModel> get filteredRecords => _filteredRecords;

  // =================== FILTER STATE ===================
  String _jobNumberFilter = '';
  String _employeeFinishFilter = '';
  String _runStatusFilter = '';

  bool _isFilterActive = false;
  bool get isFilterActive => _isFilterActive;

  String get jobNumberFilter => _jobNumberFilter;
  String get employeeFinishFilter => _employeeFinishFilter;
  String get runStatusFilter => _runStatusFilter;

  // =================== LOAD RECORD LIST ===================
  Future<void> loadRecords({
    String jobnumber = '',
    String idEmployeeFinish = '',
    String runStatus = '',
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final data = await service.fetchActiveRecords(
        jobnumber: jobnumber,
        idEmployeeFinish: idEmployeeFinish,
        runStatus: runStatus,
      );

      _allRecords = data;
      _filteredRecords = data;

      _jobNumberFilter = jobnumber;
      _employeeFinishFilter = idEmployeeFinish;
      _runStatusFilter = runStatus;

      _isFilterActive = jobnumber.isNotEmpty || idEmployeeFinish.isNotEmpty;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // =================== FILTER FUNCTION ===================
  void setFilter({
    String jobNumber = '',
    String employeeFinishId = '',
    String runStatus = '',
  }) {
    _jobNumberFilter = jobNumber;
    _employeeFinishFilter = employeeFinishId;
    _runStatusFilter = runStatus;

    _filteredRecords = _allRecords.where((record) {
      final matchesJobNumber = _jobNumberFilter.isEmpty ||
          record.jobnumbers.any((j) =>
              j.jobNumber.toLowerCase() == _jobNumberFilter.toLowerCase());

      final matchesEmployeeFinish = _employeeFinishFilter.isEmpty ||
          record.idEmployeeFinish == _employeeFinishFilter;

      final matchesRunStatus = _runStatusFilter.isEmpty ||
          _runStatusFilter.split(',').contains(record.runStatus);

      return matchesJobNumber && matchesEmployeeFinish && matchesRunStatus;
    }).toList();

    _isFilterActive = true;
    notifyListeners();
  }

  void clearFilter() {
    _jobNumberFilter = '';
    _employeeFinishFilter = '';
    _runStatusFilter = '';
    _filteredRecords = _allRecords;
    _isFilterActive = false;
    notifyListeners();
  }

  // =================== REFRESH ===================
  Future<void> refresh() async {
    try {
      await loadRecords(
        jobnumber: _jobNumberFilter,
        idEmployeeFinish: _employeeFinishFilter,
        runStatus: _runStatusFilter,
      );
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

// ================= DELETE RECORD =================
  Future<void> deleteRecord(String idRecord) async {
    try {
      // panggil service
      bool success = await service.deleteRecord(idRecord);

      if (success) {
        // hapus dari list lokal supaya langsung update UI
        _allRecords.removeWhere((record) => record.idRecord == idRecord);
        _filteredRecords.removeWhere((record) => record.idRecord == idRecord);
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
