import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
// import 'package:flutter_provider_data/utils/custom_button.dart'; // customDialogAppBar
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';

import 'widget/workdayover_main_content.dart';
import 'widget/workdayover_header_bar.dart';
import 'widget/workdayover_new_operator_panel.dart';

/// Halaman "Continue Pending - Workday Over".
///
/// File ini murni orchestrator: menyimpan state (controller, hasil scan,
/// item NG) dan mendelegasikan seluruh tampilan ke widget-widget di
/// folder `widget/`.
class ContinuePendingWorkdayOver extends StatefulWidget {
  final String idPending;
  final String idProses;
  final String productType;

  final void Function(bool)? onSuccess;

  const ContinuePendingWorkdayOver({
    Key? key,
    required this.idPending,
    required this.idProses,
    required this.productType,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<ContinuePendingWorkdayOver> createState() =>
      _ContinuePendingWorkdayOverState();
}

class _ContinuePendingWorkdayOverState
    extends State<ContinuePendingWorkdayOver> {
  // ── State untuk New Operator Form ──────────────────────────────────

  bool _showNewOperatorForm = false;

  final TextEditingController _qtyShootController = TextEditingController();
  final TextEditingController _ngController = TextEditingController();
  String _scannedEmployeeId = '';
  String _scannedEmployeeName = '';
  String _scannedEmployeeSection = '';
  String _scannedEmployeeDivision = '';
  String? _selectedNgId;
  String? _selectedNgName;
  int _qtyNg = 0;

  final List<Map<String, dynamic>> _addedNgItems = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pendingProv = context.read<PendingProvider>();
      final ngProvider = context.read<NGProvider>();

      pendingProv.resetPendingDetail();
      pendingProv.resetEmployeeScanState();
      pendingProv.clearNextMachine();

      // ← jalankan parallel, tidak saling tunggu
      await Future.wait([
        pendingProv.fetchPendingDetail(widget.idPending),
        ngProvider.loadNGList(
          productType: widget.productType,
          idProses: widget.idProses,
        ),
      ]);
    });
  }

  @override
  void dispose() {
    _qtyShootController.dispose();
    _ngController.dispose();
    super.dispose();
  }

  // ── Reset form new operator ───────────────────────────────────────
  void _resetNewOperatorForm() {
    setState(() {
      _showNewOperatorForm = false;
      _qtyShootController.clear();
      _ngController.clear();
      _scannedEmployeeId = '';
      _scannedEmployeeName = '';
      _scannedEmployeeSection = '';
      _scannedEmployeeDivision = '';
      _selectedNgId = null;
      _selectedNgName = null;
      _qtyNg = 0;
      _addedNgItems.clear();
    });
  }

  // ── Handlers: view "same operator" ──────────────────────────────────

  void _handleCancel(PendingProvider prov) {
    prov.resetEmployeeState();
    Navigator.pop(context);
  }

  Future<void> _handleConfirmScan(
    BuildContext ctx,
    PendingProvider pendingProv,
    EmployeeProvider employeeProv,
  ) async {
    final overlay = Overlay.of(ctx, rootOverlay: true);

    final code = await Navigator.push<String>(
      ctx,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );

    if (!ctx.mounted) return;
    if (code == null || code.isEmpty || code == "-1") return;

    // Scan employee lewat EmployeeProvider
    final success = await employeeProv.scanEmployee(code);

    if (!ctx.mounted) return;

    if (!success) {
      CustomSnackbar.showWithOverlay(
        overlay,
        employeeProv.errorMessage ?? "Scan failed",
        isSuccess: false,
      );
      return;
    }

    // Employee valid → simpan ke PendingProvider
    pendingProv.attachEmployee(employeeProv.employee);
  }

  Future<void> _handleSubmit(PendingProvider prov) async {
    if (!prov.isEmployeeConfirmationValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("CONFIRM TIDAK SAMA"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);

    final success = await prov.updatePendingWorkdayOver(
      idPending: int.parse(widget.idPending),
      idEmployee: prov.confirmedEmployee.idEmployee,
    );

    if (!mounted) return;

    // Refresh list di sini, gak gantung ke pop chain
    if (success) {
      await prov.fetchPending(widget.idProses);
    }

    if (!mounted) return;

    widget.onSuccess?.call(success);
    navigator.pop(success);
  }

  void _handleContinueNewOperator() {
    setState(() {
      _showNewOperatorForm = true;
    });
  }

  // ── Handlers: form new operator ─────────────────────────────────────

  Future<void> _handleScanNewOperator(PendingProvider prov) async {
    final data = prov.pendingDetail.first;

    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );

    if (!mounted) return;

    // ── VALIDASI HASIL SCAN ─────────────────────────────
    if (code == null || code.isEmpty || code == '-1') return;

    // ── VALIDASI FORMAT ID EMPLOYEE ────────────────────
    if (code.length != 8) {
      CustomSnackbar.show(context, 'QRCode bukan ID Employee',
          isSuccess: false);
      return;
    }

    // ── VALIDASI TIDAK BOLEH SCAN OPERATOR YANG SAMA ──
    if (code == data.idEmployee) {
      CustomSnackbar.show(
        context,
        'Operator baru tidak boleh sama dengan operator sebelumnya',
        isSuccess: false,
      );
      return;
    }

    final employeeProv = context.read<EmployeeProvider>();
    final success = await employeeProv.scanEmployee(code);

    if (!mounted) return;

    if (success) {
      setState(() {
        _scannedEmployeeId = employeeProv.employee.idEmployee;
        _scannedEmployeeName = employeeProv.employee.fullName;
        _scannedEmployeeSection = employeeProv.employee.section;
        _scannedEmployeeDivision = employeeProv.employee.division;
      });
    } else {
      CustomSnackbar.show(
        context,
        employeeProv.errorMessage ?? 'Scan gagal',
        isSuccess: false,
      );
    }
  }

  Future<void> _handleSubmitNewOperator(PendingProvider prov) async {
    final overlay = Overlay.of(context);

    try {
      final data = prov.pendingDetail.first;

      final success = await prov.continueWorkdayOverNewOperator(
        idRecord: data.idRecord,
        idEmployeeLama: data.idEmployee,
        idEmployeeBaru: _scannedEmployeeId,
        qtyShoot: int.parse(_qtyShootController.text),
        ngData: _addedNgItems,
      );

      if (!mounted) return;

      if (success) {
        widget.onSuccess?.call(true);

        CustomSnackbar.showWithOverlay(
          overlay,
          "Continue process berhasil",
          isSuccess: true,
        );

        // Close dialog + return true
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      CustomSnackbar.showWithOverlay(
        overlay,
        "Error: $e",
        isSuccess: false,
      );
    }
  }

  void _handleNgSelected(NgDropdownModel selected) {
    setState(() {
      _selectedNgId = selected.idNg;
      _selectedNgName = selected.ngName;
    });

    logPrint('Selected NG : ${selected.idNg} - ${selected.ngName}');
  }

  void _handleIncrementNg() => setState(() => _qtyNg++);

  void _handleDecrementNg() => setState(() {
        if (_qtyNg > 0) _qtyNg--;
      });

  void _handleAddNg() {
    setState(() {
      final existingIndex = _addedNgItems.indexWhere(
        (item) => item['id_ng'].toString() == _selectedNgId,
      );

      if (existingIndex != -1) {
        _addedNgItems[existingIndex]['qty'] =
            (_addedNgItems[existingIndex]['qty'] as int) + _qtyNg;
      } else {
        _addedNgItems.add({
          'id_ng': _selectedNgId,
          'ng_name': _selectedNgName,
          'qty': _qtyNg,
        });
      }

      _selectedNgId = null;
      _selectedNgName = null;
      _qtyNg = 0;
    });
  }

  void _handleDeleteNg(int index) {
    setState(() {
      _addedNgItems.removeAt(index);
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PendingProvider>();
    final ngProvider = context.watch<NGProvider>();
    final employeeProv = context.read<EmployeeProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: customDialogAppBar(
          title: _showNewOperatorForm
              ? "CONTINUE WORKDAY OVER WITH NEW OPERATOR"
              : "CONTINUE WORKDAY OVER WITH SAME OPERATOR",
        ),
      ),
      body: SafeArea(
        child: prov.isLoading || prov.pendingDetail.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          if (_showNewOperatorForm) ...[
                            WorkdayOverNewOperatorPanel(
                              prov: prov,
                              ngProvider: ngProvider,
                              qtyShootController: _qtyShootController,
                              scannedEmployeeId: _scannedEmployeeId,
                              scannedEmployeeName: _scannedEmployeeName,
                              scannedEmployeeSection: _scannedEmployeeSection,
                              scannedEmployeeDivision: _scannedEmployeeDivision,
                              selectedNgId: _selectedNgId,
                              qtyNg: _qtyNg,
                              addedNgItems: _addedNgItems,
                              onScanNewOperator: () =>
                                  _handleScanNewOperator(prov),
                              onBack: _resetNewOperatorForm,
                              onSubmitNewOperator: () =>
                                  _handleSubmitNewOperator(prov),
                              onNgSelected: _handleNgSelected,
                              onIncrementNg: _handleIncrementNg,
                              onDecrementNg: _handleDecrementNg,
                              onAddNg: _handleAddNg,
                              onDeleteNg: _handleDeleteNg,
                            ),
                          ] else ...[
                            WorkdayOverHeaderBar(
                                data: prov.pendingDetail.first),
                            const SizedBox(height: 12),
                            WorkdayOverMainContent(
                              prov: prov,
                              onCancel: () => _handleCancel(prov),
                              onConfirmScan: () => _handleConfirmScan(
                                context,
                                prov,
                                employeeProv,
                              ),
                              onSubmit: () => _handleSubmit(prov),
                              onContinueNewOperator: _handleContinueNewOperator,
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
