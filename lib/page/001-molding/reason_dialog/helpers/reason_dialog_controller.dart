import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';

/// Controller terpusat untuk mengelola state lokal ReasonSelectedDialog.
class ReasonDialogController extends ChangeNotifier {
  String? selectedNgCode;
  String? selectedNgName;
  NgDropdownModel? selectedNgItemObject;
  final List<Map<String, String>> ngDataList = [];

  final TextEditingController ngQtyController = TextEditingController();
  final TextEditingController currentShootQtyController =
      TextEditingController();
  final TextEditingController shootRemainController = TextEditingController();

  bool isAddButtonEnabled = false;

  void validateInputs() {
    final isDropdownSelected = selectedNgItemObject != null;
    final isQtyValid = ngQtyController.text.trim().isNotEmpty &&
        int.tryParse(ngQtyController.text.trim()) != null &&
        int.parse(ngQtyController.text.trim()) > 0;

    isAddButtonEnabled = isDropdownSelected && isQtyValid;
    notifyListeners();
  }

  void resetNgState() {
    ngDataList.clear();
    selectedNgItemObject = null;
    selectedNgCode = null;
    selectedNgName = null;
    ngQtyController.clear();
    isAddButtonEnabled = false;
    notifyListeners();
  }

  void addOrUpdateNgItem({
    required String idNg,
    required String ngName,
    required int qty,
    required String jobnumber,
    required String idEmployee,
    required String nmEmployee,
    required String idRecord,
  }) {
    final existingIndex =
        ngDataList.indexWhere((item) => item['id_ng'] == idNg);
    if (existingIndex != -1) {
      final existingQty =
          int.tryParse(ngDataList[existingIndex]['qty'] ?? '0') ?? 0;
      ngDataList[existingIndex]['qty'] = (existingQty + qty).toString();
    } else {
      ngDataList.add({
        'id_ng': idNg,
        'ngName': ngName,
        'qty': qty.toString(),
        'idRecord': idRecord,
        'idEmployee': idEmployee,
        'nmEmployee': nmEmployee,
        'jobnumber': jobnumber,
      });
    }

    selectedNgItemObject = null;
    selectedNgCode = null;
    selectedNgName = null;
    ngQtyController.clear();
    validateInputs();
  }

  void removeNgItemAt(int index) {
    if (index >= 0 && index < ngDataList.length) {
      ngDataList.removeAt(index);
      notifyListeners();
    }
  }

  void setSelectedNgItem(NgDropdownModel? item) {
    selectedNgItemObject = item;
    selectedNgCode = item?.idNg;
    selectedNgName = item?.ngName;
    notifyListeners();
  }

  void incrementNgQty() {
    int current = int.tryParse(ngQtyController.text) ?? 0;
    if (current < 99999) current++;
    ngQtyController.text = current.toString();
    validateInputs();
  }

  void decrementNgQty() {
    int current = int.tryParse(ngQtyController.text) ?? 0;
    if (current > 0) current--;
    ngQtyController.text = current.toString();
    validateInputs();
  }

  List<Map<String, dynamic>> mapNgDataForSubmit() {
    return ngDataList
        .where((item) => item["id_ng"] != null)
        .map((item) => {
              "id_ng": item["id_ng"],
              "qty": int.tryParse(item["qty"] ?? "0") ?? 0,
              "id_employee_finish": item["idEmployee"] ?? '',
              "nm_employee_finish": item["nmEmployee"] ?? '',
              "jobnumber": item["jobnumber"] ?? '',
            })
        .toList();
  }

  int getShootQty() {
    return int.tryParse(currentShootQtyController.text.trim()) ?? 0;
  }

  bool get isShootQtyValid => currentShootQtyController.text.trim().isNotEmpty;

  @override
  void dispose() {
    ngQtyController.dispose();
    currentShootQtyController.dispose();
    shootRemainController.dispose();
    super.dispose();
  }
}
