import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/reason_dropdown_model.dart';
import 'package:flutter_provider_data/service/reason_service.dart';

class ReasonProvider with ChangeNotifier {
  final ReasonService _service = ReasonService();

  List<ReasonDropdownModel> _reasons = [];
  bool _isLoading = false;
  String? _errorMessage;
  ReasonDropdownModel? _selectedReason;

  String? _lastIdProses;

  // ===== GETTER =====
  List<ReasonDropdownModel> get reasons => _reasons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReasonDropdownModel? get selectedReason => _selectedReason;

  // ===== SETTER =====
  void setSelectedReason(ReasonDropdownModel? reason) {
    if (_selectedReason == reason) return;
    _selectedReason = reason;
    notifyListeners();
  }

  // ===== LOAD DATA (FIXED & SAFE) =====
  Future<void> loadReasonData({required String idProses}) async {
    if (_isLoading) return;
    if (_lastIdProses == idProses && _reasons.isNotEmpty) return;

    _lastIdProses = idProses;
    _isLoading = true;
    _errorMessage = null;

    // ✅ PENTING: tunda notify ke frame berikutnya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final result = await _service.fetchReasonList(idProses: idProses);
      _reasons = result;
    } catch (e) {
      _errorMessage = e.toString();
      _reasons = [];
    } finally {
      _isLoading = false;

      // ✅ notify juga harus aman
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // ===== RESET =====
  void clearReason({bool clearCache = false}) {
    _selectedReason = null;

    if (clearCache) {
      _reasons = [];
      _lastIdProses = null;
    }

    notifyListeners();
  }
}
