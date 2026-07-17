import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_pending_model.dart';
import 'package:flutter_provider_data/page/001-molding/stop_grid_view/widget/stop_grid_empty_state.dart';
import 'package:flutter_provider_data/page/001-molding/stop_grid_view/widget/stop_grid_item.dart';
import 'package:flutter_provider_data/page/001-molding/stop_grid_view/widget/stop_grid_top_row.dart';
import 'package:flutter_provider_data/page/001-molding/show_warning_dialog.dart';
import 'package:flutter_provider_data/page/001-molding/dialog_confirm_mass_running.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:provider/provider.dart';

class StopGridView extends StatefulWidget {
  final String title;
  final String idProses;

  const StopGridView({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  _StopGridViewState createState() => _StopGridViewState();
}

class _StopGridViewState extends State<StopGridView> {
  final List<RecordPendingModel> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PendingProvider>().fetchPending(widget.idProses);
    });
  }

  // ── OPEN SCANNER ───────────────────────────────────────────────────────
  Future<String?> _openScanner() async {
    final code = await Navigator.push<String>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MobileScannerPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (!mounted) return null;
    if (code == null || code.isEmpty || code == '-1') return null;
    return code;
  }

  // ── SCAN JOB NUMBER ────────────────────────────────────────────────────
  Future<void> _scanAndFilterJobNumber() async {
    final code = await _openScanner();
    if (code == null) return;

    if (!RegExp(r'^[a-zA-Z0-9]{9}[0-9]{10}[0-9]{5}$').hasMatch(code)) {
      if (!mounted) return;
      CustomSnackbar.show(context, "Invalid QR Code format.", isSuccess: false);
      return;
    }

    if (!mounted) return;
    setState(() {
      context.read<PendingProvider>().scannedJobNumber =
          code.substring(9, 19).trim();
    });
  }

  // ── SCAN EMPLOYEE ──────────────────────────────────────────────────────
  Future<void> _scanAndFilterEmployee() async {
    final code = await _openScanner();
    if (code == null) return;

    if (code.length != 8) {
      if (!mounted) return;
      CustomSnackbar.show(context, "Yang discan bukan ID Employee",
          isSuccess: false);
      return;
    }

    if (!mounted) return;
    setState(() {
      context.read<PendingProvider>().scannedEmployeeFinishId = code;
    });
  }

  // ── ON CONTINUE PRESSED ────────────────────────────────────────────────
  Future<void> _onContinuePressed() async {
    if (_selectedItems.isEmpty) {
      await showWarningDialog(context, "Belum ada data yang dipilih.");
      return;
    }

    final firstEmployee = _selectedItems.first.employeeName;
    final sameEmployee =
        _selectedItems.every((item) => item.employeeName == firstEmployee);

    if (!sameEmployee) {
      await showWarningDialog(
        context,
        "HARAP PILIH OPERATOR YANG SAMA AGAR PROSES DAPAT DI LANJUTKAN",
      );
      return;
    }

    const reasonMessages = {
      '02': 'REASON WORKDAY OVER TIDAK BISA DI RUNNING DARI MENU INI',
      '03': 'REASON CHANGE OPERATOR TIDAK BISA DI RUNNING DARI MENU INI',
      '06': 'REASON CHANGE MACHINE TIDAK BISA DI RUNNING DARI MENU INI',
    };

    final codereason = _selectedItems.first.idReason;
    if (reasonMessages.containsKey(codereason)) {
      await showWarningDialog(context, reasonMessages[codereason]!);
      return;
    }

    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => DialogConfirmMassRunning(
          selectedItems: _selectedItems,
          idProses: widget.idProses,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final widthApp = MediaQuery.of(context).size.width;
    final prov = context.watch<PendingProvider>();

    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    if (prov.hasError) {
      return Center(child: Text('Error: ${prov.errorMessage}'));
    }

    final filteredList = prov.filteredPending;

    return Scaffold(
      body: Column(
        children: [
          StopGridTopRow(
            widthApp: widthApp,
            prov: prov,
            selectedItems: _selectedItems,
            onScanJobNumber: _scanAndFilterJobNumber,
            onScanEmployee: _scanAndFilterEmployee,
            onContinue: _onContinuePressed,
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const StopGridEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return StopGridItem(
                        item: item,
                        isSelected: _selectedItems.contains(item),
                        idProses: widget.idProses,
                        onTap: () {
                          setState(() {
                            _selectedItems.contains(item)
                                ? _selectedItems.remove(item)
                                : _selectedItems.add(item);
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
