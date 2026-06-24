import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/service/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _service;

  EmployeeProvider({
    EmployeeService? service,
  }) : _service = service ?? EmployeeService();

  // =========================================================
  // PRIVATE STATE
  // =========================================================

  EmployeeModel _employee = EmployeeModel.empty;

  List<EmployeeModel> _employeeList = [];

  bool _isLoading = false;
  String? _errorMessage;

  // =========================================================
  // GETTERS
  // =========================================================

  EmployeeModel get employee => _employee;

  List<EmployeeModel> get employeeList => List.unmodifiable(_employeeList);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get hasEmployee => _employee.isValid;

  bool get canConfirm => hasEmployee && !_isLoading;

  // =========================================================
  // PRIVATE STATE HELPERS
  // =========================================================

  void _setLoading(bool value, {bool notify = true}) {
    _isLoading = value;

    if (notify) {
      notifyListeners();
    }
  }

  void _setEmployee(EmployeeModel value, {bool notify = true}) {
    _employee = value;

    if (notify) {
      notifyListeners();
    }
  }

  void _setEmployeeList(
    List<EmployeeModel> value, {
    bool notify = true,
  }) {
    _employeeList = value;

    if (notify) {
      notifyListeners();
    }
  }

  void _setError(
    String? message, {
    bool notify = true,
  }) {
    _errorMessage = message;

    if (notify) {
      notifyListeners();
    }
  }

  void _notify() {
    notifyListeners();
  }

  // =========================================================
  // PUBLIC METHODS
  // =========================================================

  void selectEmployee(EmployeeModel employee) {
    _setEmployee(employee);
  }

  void clearEmployee() {
    _employee = EmployeeModel.empty;
    _errorMessage = null;
    _isLoading = false;

    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  // =========================================================
  // SCAN EMPLOYEE
  // =========================================================

  Future<bool> scanEmployee(String code) async {
    // Reset state tanpa notify berkali-kali
    _employee = EmployeeModel.empty;
    _errorMessage = null;
    _isLoading = true;

    _notify();

    try {
      // VALIDASI FORMAT
      if (!RegExp(r'^\d{8}$').hasMatch(code)) {
        throw Exception(
          "Invalid QR Code format (must be 8 digits)",
        );
      }

      // REQUEST API
      final data = await _service.getEmployeeDetail(code);

      // UPDATE SUCCESS STATE
      _employee = data;
      _errorMessage = null;

      return true;
    } catch (e) {
      _employee = EmployeeModel.empty;
      _errorMessage = e.toString();

      return false;
    } finally {
      _isLoading = false;

      _notify();
    }
  }

  // =========================================================
  // LOAD EMPLOYEE LIST
  // =========================================================

  Future<void> loadEmployees() async {
    _setLoading(true);
    _setError(null, notify: false);

    try {
      final result = await _service.getAllEmployees();

      _setEmployeeList(result, notify: false);
    } catch (e) {
      _setEmployeeList([], notify: false);

      _setError(
        "Error loading employees",
        notify: false,
      );
    } finally {
      _setLoading(false);
    }
  }

  // =========================================================
  // FIND EMPLOYEE BY NRP
  // =========================================================

  EmployeeModel? findEmployeeByNrp(String nrp) {
    try {
      return _employeeList.firstWhere(
        (e) => e.nrp == nrp,
      );
    } catch (_) {
      return null;
    }
  }

  // =========================================================
  // FILTER EMPLOYEE
  // =========================================================

  List<EmployeeModel> searchEmployees(String keyword) {
    if (keyword.trim().isEmpty) {
      return employeeList;
    }

    final query = keyword.toLowerCase();

    return _employeeList.where((employee) {
      return employee.fullName.toLowerCase().contains(query) ||
          employee.nrp.toLowerCase().contains(query) ||
          employee.section.toLowerCase().contains(query) ||
          employee.division.toLowerCase().contains(query);
    }).toList();
  }
}
