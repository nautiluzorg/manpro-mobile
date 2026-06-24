// lib/providers/ng_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/service/ng_service.dart';

class NGProvider with ChangeNotifier {
  final NGService _ngService = NGService();

  // --- NG Dropdown ---
  List<NgDropdownModel> _listNG = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedForThisRecord = false;

  // --- NG Table Data ---
  List<Map<String, dynamic>> dataNG = [];
  List<Map<String, dynamic>> ngTableData = [];

  // --- Input NG (dialog) ---
  String? selectedNgCode;
  String? selectedNgItem;
  final TextEditingController quantityNgController = TextEditingController();

  // --- NG Item Dialog Quantity ---
  List<NgItemInput> ngItemInputs = [];

  // --- GETTER ---
  bool get isSubmitEnabled {
    final qty = int.tryParse(quantityNgController.text) ?? 0;
    return selectedNgCode != null && selectedNgItem != null && qty > 0;
  }

  List<NgDropdownModel> get listNG => _listNG;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoadedForThisRecord => _hasLoadedForThisRecord;

  // --- SETTER ---
  set hasLoadedForThisRecord(bool value) {
    _hasLoadedForThisRecord = value;
    notifyListeners();
  }

  // --- NUM BLOCK HANDLER ---
  void appendNum(String num) {
    if ((int.tryParse(quantityNgController.text + num) ?? 0) < 1000) {
      quantityNgController.text += num;
      notifyListeners(); // update tombol Submit
    }
  }

  void backspace() {
    if (quantityNgController.text.isNotEmpty) {
      quantityNgController.text = quantityNgController.text
          .substring(0, quantityNgController.text.length - 1);
      notifyListeners(); // update tombol Submit
    }
  }

  void clearQty() {
    quantityNgController.clear();
    notifyListeners(); // update tombol Submit
  }

  /// Panggil ini setiap kali dropdown atau quantity berubah
  void notifySubmitStateChanged() {
    // Hanya notify supaya Consumer rebuild
    notifyListeners();
  }

  // --- CRUD NG Dialog ---
  void increaseQty(int index) {
    ngItemInputs[index].quantity++;
    ngItemInputs[index].controller.text =
        ngItemInputs[index].quantity.toString();
    notifyListeners();
  }

  void decreaseQty(int index) {
    if (ngItemInputs[index].quantity > 0) {
      ngItemInputs[index].quantity--;
      ngItemInputs[index].controller.text =
          ngItemInputs[index].quantity.toString();
      notifyListeners();
    }
  }

  void updateQtyFromTextField(int index, String value) {
    ngItemInputs[index].quantity = int.tryParse(value) ?? 0;
    notifyListeners();
  }

  bool get isAnyQtyMoreThanZero {
    return ngItemInputs.any((element) => element.quantity > 0);
  }

  // --- NG LIST FETCH ---
  Future<void> loadNGList({
    required String productType,
    required String idProses,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _listNG = await _ngService.fetchNGList(
        productType: productType,
        idProses: idProses,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CRUD NG TABLE ---
  void addOrUpdateNG({
    required String code,
    required String name,
    required int quantity,
    required String idRecord,
    required String idEmployee,
    required String jobNumber,
    required int qtyShoot,
  }) {
    final existingIndex = dataNG.indexWhere((row) => row['id_ng'] == code);
    if (existingIndex != -1) {
      dataNG[existingIndex]['qty'] += quantity;
    } else {
      dataNG.add({
        'id_ng': code,
        'ng_name': name,
        'qty': quantity,
        'id_record': idRecord,
        'id_employee': idEmployee,
        'jobnumber': jobNumber,
        'qty_shoot': qtyShoot,
      });
    }

    ngTableData = List.from(dataNG);
    _syncTableData();
    notifyListeners();
  }

  void deleteNG(String idNg, JobNumberProvider jobProvider) {
    // Hapus dari data utama
    dataNG.removeWhere((item) => item['id_ng'] == idNg);

    // Copy ulang ke tableData
    ngTableData = List.from(dataNG);

    // Hitung total NG baru
    int totalNG = getTotalNG();
    _syncTableData();

    // Update Qty Actual
    jobProvider.updateQtyActualBasedOnNG(totalNG);

    notifyListeners();
  }

  void clearAll() {
    dataNG.clear();
    ngTableData.clear();
    selectedNgCode = null;
    selectedNgItem = null;
    quantityNgController.clear();
    notifyListeners();
  }

  int getTotalNG() {
    return ngTableData.fold<int>(
      0,
      (sum, item) {
        final qty = int.tryParse(item['qty']?.toString() ?? '0') ?? 0;
        return sum + qty;
      },
    );
  }

  void clearNGList() {
    _listNG = [];
    _hasLoadedForThisRecord = false;
    notifyListeners();
  }

  void _syncTableData() {
    ngTableData = List.from(dataNG);
    notifyListeners();
  }

  void submitNgItems({
    required String idRecord,
    required String idEmployee,
    required String jobNumber,
    required int qtyShoot,
  }) {
    for (var ngInput in ngItemInputs) {
      if (ngInput.quantity > 0) {
        addOrUpdateNG(
          code: ngInput.ngItem.idNg,
          name: ngInput.ngItem.ngName,
          quantity: ngInput.quantity,
          idRecord: idRecord,
          idEmployee: idEmployee,
          jobNumber: jobNumber,
          qtyShoot: qtyShoot,
        );
      }
    }

    // reset quantity setelah submit
    for (var ngInput in ngItemInputs) {
      ngInput.quantity = 0;
      ngInput.controller.text = '0';
    }

    notifyListeners();
  }
}

class NgItemInput {
  final NgDropdownModel ngItem; // ubah dari NgItem ke NgDropdownModel
  int quantity;
  final TextEditingController controller;

  NgItemInput({
    required this.ngItem,
    this.quantity = 0,
  }) : controller = TextEditingController();
}
