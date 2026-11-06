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
  State<StopGridView> createState() => _StopGridViewState();
}

class _StopGridViewState extends State<StopGridView> {
  final ValueNotifier<Set<int>> _selectedPendingIds =
      ValueNotifier<Set<int>>(<int>{});
  late final PendingProvider _pendingProvider;
  int _lastPendingRevision = 0;

  @override
  void initState() {
    super.initState();
    _pendingProvider = context.read<PendingProvider>();
    _lastPendingRevision = _pendingProvider.pendingRevision;
    _pendingProvider.addListener(_handlePendingRevisionChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearSelection();
      _pendingProvider.fetchPending(widget.idProses);
    });
  }

  @override
  void dispose() {
    _pendingProvider.removeListener(_handlePendingRevisionChanged);
    _selectedPendingIds.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StopGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idProses != widget.idProses) {
      _clearSelection();
      _pendingProvider.fetchPending(widget.idProses);
    }
  }

  void _handlePendingRevisionChanged() {
    if (!mounted || _pendingProvider.pendingRevision == _lastPendingRevision) {
      return;
    }

    _lastPendingRevision = _pendingProvider.pendingRevision;
    _clearSelection();
  }

  void _clearSelection() {
    if (_selectedPendingIds.value.isEmpty) return;
    _selectedPendingIds.value = <int>{};
  }

  bool _isSelected(RecordPendingModel item, Set<int> selectedIds) =>
      selectedIds.contains(item.idPending);

  List<RecordPendingModel> _currentSelectedItems(
      List<RecordPendingModel> latestItems, Set<int> selectedIds) {
    return latestItems
        .where((item) => selectedIds.contains(item.idPending))
        .toList();
  }

  void _toggleSelection(RecordPendingModel item) {
    final nextSelection = Set<int>.from(_selectedPendingIds.value);
    if (!nextSelection.add(item.idPending)) {
      nextSelection.remove(item.idPending);
    }
    _selectedPendingIds.value = nextSelection;
  }

  String _normalizeEmployeeId(String? idEmployee) =>
      (idEmployee ?? '').trim().toUpperCase();

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

    // 9 (bcode) + 10 (jobnumber) + 2 (total jobnumber) + 3-5 (qty) = 24-26 char
    if (!RegExp(r'^[a-zA-Z0-9]{9}[0-9]{10}[0-9]{2}[0-9]{3,5}$')
        .hasMatch(code)) {
      if (!mounted) return;
      CustomSnackbar.show(context, "Invalid QR Code format.", isSuccess: false);
      return;
    }

    if (!mounted) return;
    _clearSelection();
    context.read<PendingProvider>().scannedJobNumber =
        code.substring(9, 19).trim();
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
    _clearSelection();
    context.read<PendingProvider>().scannedEmployeeFinishId = code;
  }

  // ── ON CONTINUE PRESSED ────────────────────────────────────────────────
  Future<void> _onContinuePressed() async {
    final prov = context.read<PendingProvider>();
    final selectedItems =
        _currentSelectedItems(prov.filteredPending, _selectedPendingIds.value);

    if (selectedItems.isEmpty) {
      await showWarningDialog(context, "Belum ada data yang dipilih.");
      return;
    }

    final firstEmployeeId =
        _normalizeEmployeeId(selectedItems.first.idEmployee);
    final sameEmployee = firstEmployeeId.isNotEmpty &&
        selectedItems.every(
            (item) => _normalizeEmployeeId(item.idEmployee) == firstEmployeeId);

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

    final codereason = selectedItems.first.idReason;
    if (reasonMessages.containsKey(codereason)) {
      await showWarningDialog(context, reasonMessages[codereason]!);
      return;
    }

    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => DialogConfirmMassRunning(
          selectedItems: selectedItems,
          idProses: widget.idProses,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 160),
        reverseTransitionDuration: const Duration(milliseconds: 120),
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
          ValueListenableBuilder<Set<int>>(
            valueListenable: _selectedPendingIds,
            builder: (context, selectedIds, _) {
              final selectedItems =
                  _currentSelectedItems(filteredList, selectedIds);

              return StopGridTopRow(
                widthApp: widthApp,
                prov: prov,
                selectedItems: selectedItems,
                onScanJobNumber: _scanAndFilterJobNumber,
                onScanEmployee: _scanAndFilterEmployee,
                onClear: _clearSelectionAndFilter,
                onContinue: _onContinuePressed,
              );
            },
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const StopGridEmptyState()
                : ValueListenableBuilder<Set<int>>(
                    valueListenable: _selectedPendingIds,
                    builder: (context, selectedIds, _) {
                      return GridView.builder(
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
                          return RepaintBoundary(
                            key: ValueKey(item.idPending),
                            child: StopGridItem(
                              item: item,
                              isSelected: _isSelected(item, selectedIds),
                              idProses: widget.idProses,
                              onTap: () => _toggleSelection(item),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _clearSelectionAndFilter() {
    _clearSelection();
    context.read<PendingProvider>().clearFilter();
  }
}
