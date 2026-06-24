import 'dart:async';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/reason_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';

class MassReasonController extends ChangeNotifier {
  // ← tambah ini

  String idEmployeeConfirm = '';
  String nameEmployeeConfirm = 'NAMA OPERATOR';
  String photoEmployeeConfirm = 'employee.png';
  bool isEmployeeConfirmed = false;
  bool _loaded = false;

  bool get loaded => _loaded;
  bool get isConfirmEnabled => true;

  void onCancel(VoidCallback navigatePop, BuildContext context) {
    context.read<ReasonProvider>().setSelectedReason(null);
    navigatePop();
  }

  Future<Map<String, String>?> handleConfirmQr(BuildContext context) async {
    try {
      final qrCode = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MobileScannerPage()),
      );

      if (qrCode == null) return null;

      final runningProv = context.read<RunningProvider>();
      final scanned = await runningProv.validateEmployee(qrCode);

      if (scanned != null) {
        idEmployeeConfirm = scanned['id']!;
        nameEmployeeConfirm = scanned['name']!;
        photoEmployeeConfirm = scanned['photo']!;
        isEmployeeConfirmed = true;
        notifyListeners(); // ← tambah ini
      }

      return scanned;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(context, e.toString(), isSuccess: false);
      }
      return null;
    }
  }

  bool validateSubmit(List<dynamic> selectedItems, dynamic reasonProvider) {
    if (!isEmployeeConfirmed) return false;
    if (selectedItems.isEmpty) return false;

    final wrongConfirm = selectedItems.any(
      (item) => item.activeEmployee?.idEmployee != idEmployeeConfirm,
    );
    return !wrongConfirm;
  }

  void reset() {
    idEmployeeConfirm = '';
    nameEmployeeConfirm = 'NAMA OPERATOR';
    photoEmployeeConfirm = 'employee.png';
    isEmployeeConfirmed = false;
    _loaded = false;
    notifyListeners(); // ← tambah ini
  }

  void setLoaded(bool value) {
    _loaded = value;
  }
}

/*
import 'dart:async';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/reason_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';

class MassReasonController {
  // All original state variables
  String idEmployeeConfirm = '';
  String nameEmployeeConfirm = 'NAMA OPERATOR';
  String photoEmployeeConfirm = 'employee.png';
  bool isEmployeeConfirmed = false;
  bool _loaded = false;

  // Getters for UI
  bool get loaded => _loaded;
  bool get isConfirmEnabled => true; // Always true like original

  // Original _onCancel method
  void onCancel(VoidCallback navigatePop, BuildContext context) {
    context.read<ReasonProvider>().setSelectedReason(null);
    navigatePop();
  }

  // Original QR scan + confirm logic
  Future<Map<String, String>?> handleConfirmQr(
    BuildContext context,
  ) async {
    try {
      final qrCode = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MobileScannerPage()),
      );

      if (qrCode == null) return null;

      final runningProv = context.read<RunningProvider>();
      final scanned = await runningProv.validateEmployee(qrCode);

      if (scanned != null) {
        idEmployeeConfirm = scanned['id']!;
        nameEmployeeConfirm = scanned['name']!;
        photoEmployeeConfirm = scanned['photo']!;
        isEmployeeConfirmed = true;
      }

      return scanned;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(context, e.toString(), isSuccess: false);
      }
      return null;
    }
  }

  // MARK: Submit validation logic (moved to helper later)
  bool validateSubmit(
    List<dynamic> selectedItems, // RecordRunningModel
    dynamic reasonProvider,
  ) {
    if (!isEmployeeConfirmed) return false;
    if (selectedItems.isEmpty) return false;

    // Original validation: all operators match confirm employee
    final wrongConfirm = selectedItems.any(
      (item) => item.activeEmployee?.idEmployee != idEmployeeConfirm,
    );

    return !wrongConfirm;
  }

  // Reset method for controller reuse
  void reset() {
    idEmployeeConfirm = '';
    nameEmployeeConfirm = 'NAMA OPERATOR';
    photoEmployeeConfirm = 'employee.png';
    isEmployeeConfirmed = false;
    _loaded = false;
  }

  void setLoaded(bool value) {
    _loaded = value;
  }
}
*/
