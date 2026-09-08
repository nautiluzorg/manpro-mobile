import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:provider/provider.dart';
import 'widget/machine_header_row.dart';
import 'widget/employee_photo_column.dart';
import 'widget/pending_machine_info_table.dart';
import 'widget/change_machine_action_buttons.dart';

class ContinuePendingChangeMachine extends StatefulWidget {
  final String idPending;
  final void Function(bool)? onSuccess;

  const ContinuePendingChangeMachine({
    super.key,
    required this.idPending,
    this.onSuccess,
  });

  @override
  State<ContinuePendingChangeMachine> createState() =>
      _ContinuePendingChangeMachineState();
}

class _ContinuePendingChangeMachineState
    extends State<ContinuePendingChangeMachine> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = context.read<PendingProvider>();
      prov.resetPendingDetail();
      prov.resetEmployeeScanState();
      prov.clearNextMachine();
      await prov.fetchPendingDetail(widget.idPending);
    });
  }

  Future<void> _handleScanEmployee() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );

    if (!mounted ||
        scannedCode == null ||
        scannedCode.isEmpty ||
        scannedCode == '-1') {
      return;
    }

    final employeeProvider = context.read<EmployeeProvider>();
    final success = await employeeProvider.scanEmployee(scannedCode);

    if (!mounted) return;

    if (!success) {
      CustomSnackbar.show(
        context,
        employeeProvider.errorMessage ?? 'Scan failed',
        isSuccess: false,
      );
      return;
    }

    context.read<PendingProvider>().attachEmployee(employeeProvider.employee);
  }

  Future<void> _handleScanMachine() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );

    if (!mounted ||
        scannedCode == null ||
        scannedCode.isEmpty ||
        scannedCode == '-1') {
      return;
    }

    final machineProvider = context.read<MachineProvider>();
    final pendingProvider = context.read<PendingProvider>();
    final errorMessage = await machineProvider.scanMachine(scannedCode);

    if (!mounted) return;

    if (errorMessage != null) {
      CustomSnackbar.show(context, errorMessage, isSuccess: false);
      return;
    }

    final machine = machineProvider.machine;
    final validationError =
        await machineProvider.validateMachineDropdown(machine.idMc);

    if (!mounted) return;

    if (validationError != null) {
      CustomSnackbar.show(context, validationError, isSuccess: false);
      return;
    }

    pendingProvider.setNextMachine(id: machine.idMc, name: machine.nmMc);
  }

  void _handleCancel() {
    context.read<PendingProvider>()
      ..resetEmployeeState()
      ..clearNextMachine();
    context.read<MachineProvider>().clearMachine();
    Navigator.pop(context);
  }

  Future<void> _handleSubmit() async {
    final pendingProvider = context.read<PendingProvider>();
    final navigator = Navigator.of(context);
    final idRecord = pendingProvider.pendingDetail.first.idRecord;

    final success = await pendingProvider.updatePendingRecordMc(
      idPending: int.parse(widget.idPending),
      idRecord: idRecord,
    );

    if (!mounted) return;

    widget.onSuccess?.call(success);
    navigator.pop(success);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PendingProvider>();
    final isScanningEmployee = context.select<EmployeeProvider, bool>(
      (provider) => provider.isLoading,
    );

    if (prov.isLoading || prov.pendingDetail.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: customDialogAppBar(title: "CONTINUE RUNNING"),
      ),
      body: SafeArea(
        child: prov.isLoading || prov.pendingDetail.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildHeader(prov),
                          const SizedBox(height: 12),
                          _buildMainContent(prov, isScanningEmployee),
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

  // ================= HEADER =================
  Widget _buildHeader(PendingProvider prov) {
    final data = prov.pendingDetail.first;

    return MachineHeaderRow(
      idRecord: data.idRecord,
      customer: data.customer,
      productCategory: data.productCategory,
      productType: data.productType,
    );
  }

  // ================= MAIN CONTENT =================

  Widget _buildMainContent(
    PendingProvider prov,
    bool isScanningEmployee,
  ) {
    final data = prov.pendingDetail.first;

    // Kalau sudah scan employee baru, pakai data dari nextOperator.
    // Kalau belum, fallback ke data pending asli.
    final displayId = prov.isNextOperatorReady
        ? prov.nextOperator.idEmployee
        : data.idEmployee;
    final displayName =
        prov.isNextOperatorReady ? prov.nameNextOperator : data.employeeName;
    final displayNrp =
        prov.isNextOperatorReady ? prov.nrpNextOperator : data.nrp;
    final displaySection =
        prov.isNextOperatorReady ? prov.secNextOperator : data.section;
    final displayDivision =
        prov.isNextOperatorReady ? prov.divNextOperator : data.division;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AREA OPERATOR & TABLE
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmployeePhotoColumn(
                    idEmployee: displayId,
                    employeeName: displayName,
                    nrp: displayNrp,
                    section: displaySection,
                    division: displayDivision,
                    imageUrl:
                        '${AppConfig.baseUrl}/media/img/employee/$displayId.png',
                    isScanning: isScanningEmployee,
                    onScan: _handleScanEmployee,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PendingMachineInfoTable(
                          data: data,
                          isEmployeeScanned: prov.isEmployeeScanned,
                          employeeName: prov.employeeName,
                          nextMachineName: prov.nextMachineName,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ================= ACTION BUTTONS FULL-WIDTH =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ChangeMachineActionButtons(
                canSubmit: prov.hasNextMachine && !prov.isSubmitting,
                onCancel: _handleCancel,
                onScanMachine: _handleScanMachine,
                onSubmit: _handleSubmit,
              ),
            ),

            const SizedBox(height: 8),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
