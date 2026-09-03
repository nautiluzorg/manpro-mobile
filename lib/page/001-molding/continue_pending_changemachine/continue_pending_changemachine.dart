import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
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

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PendingProvider>();

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
                          _buildMainContent(prov),
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

  Widget _buildMainContent(PendingProvider prov) {
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PendingMachineInfoTable(
                          data: data,
                          prov: prov,
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
                prov: prov,
                idPending: widget.idPending,
                onSuccess: widget.onSuccess,
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
