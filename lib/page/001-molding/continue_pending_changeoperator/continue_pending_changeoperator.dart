import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:provider/provider.dart';

import 'widget/record_header_row.dart';
import 'widget/employee_photo_card.dart';
import 'widget/employee_info_section.dart';
import 'widget/employee_action_buttons.dart';
import 'widget/pending_detail_section.dart';
import 'widget/job_number_banner.dart';
import 'widget/next_operator_card.dart';
import 'widget/next_machine_info_table.dart';

import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';

class ContinuePendingChangeOperator extends StatefulWidget {
  final String idPending;
  final void Function(bool)? onSuccess;

  const ContinuePendingChangeOperator({
    super.key,
    required this.idPending,
    this.onSuccess,
  });

  @override
  State<ContinuePendingChangeOperator> createState() =>
      _ContinuePendingChangeOperatorState();
}

class _ContinuePendingChangeOperatorState
    extends State<ContinuePendingChangeOperator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = context.read<PendingProvider>();

      prov.resetPendingDetail();
      prov.clearNextMachine();
      prov.resetEmployeeScanState();

      await prov.loadPendingDetailWithNg(int.parse(widget.idPending));
    });
  }

  Future<void> _scanNextOperator() async {
    final ctx = context;
    final overlay = Overlay.of(ctx, rootOverlay: true);

    final employeeProv = ctx.read<EmployeeProvider>();
    final pendingProv = ctx.read<PendingProvider>();

    final code = await Navigator.push<String>(
      ctx,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );
    if (!ctx.mounted) return;
    if (code == null || code.isEmpty || code == "-1") return;

    // ✅ VALIDASI OPERATOR TIDAK BOLEH SAMA
    final currentOperatorId = pendingProv.ngDetail.idEmployee;
    if (code == currentOperatorId) {
      CustomSnackbar.showWithOverlay(
        overlay,
        "ID EMPLOYEE TIDAK BOLEH SAMA, HARUS OPERATOR BARU",
        isSuccess: false,
      );
      return;
    }

    // 🔥 Scan employee lewat EmployeeProvider
    final success = await employeeProv.scanEmployee(code);

    if (!ctx.mounted) return;

    if (!success) {
      CustomSnackbar.showWithOverlay(
        overlay,
        employeeProv.errorMessage ?? "Employee scan failed",
        isSuccess: false,
      );
      return;
    }

    // 🔥 Employee valid → simpan ke PendingProvider
    pendingProv.attachEmployee(employeeProv.employee);
  }

  @override
  Widget build(BuildContext context) {
    final myAppBar = customDialogAppBar(
      title: 'CONTINUE RUNNING',
    );

    return Scaffold(
      appBar: myAppBar,
      body: Consumer<PendingProvider>(
        builder: (context, provider, _) {
          if (provider.isNgLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.ngError != null) {
            return Center(child: Text('Error: ${provider.ngError}'));
          }

          if (provider.ngDetail.isEmpty) {
            return const Center(
                child: Text('TIDAK ADA MOLDING YANG STOP SAAT INI'));
          }

          final data = provider.ngDetail;

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          RecordHeaderRow(
                            idRecord: data.idRecord,
                            customer: data.customer,
                            productCategory: data.productCategory,
                            productType: data.productType,
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      EmployeePhotoCard(
                                        employeeId: data.idEmployee,
                                      ),
                                      const SizedBox(height: 12),
                                      EmployeeInfoSection(
                                        name: data.employeeName,
                                        nrp: data.nrp,
                                        division: data.division,
                                        section: data.section,
                                      ),
                                      const SizedBox(height: 24),
                                      EmployeeActionButtons(
                                        provider: provider,
                                        onSuccess: widget.onSuccess,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              PendingDetailSection(
                                data: data,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          JobNumberBanner(
                            jobNumber: data.jobnumber.toString(),
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    NextOperatorCard(
                                      photoUrl:
                                          "${AppConfig.baseUrl}/media/img/employee/${provider.photoNextOperator}",
                                      name: provider.nameNextOperator,
                                      nrp: provider.nrpNextOperator,
                                      division: provider.divNextOperator,
                                      section: provider.secNextOperator,
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blueAccent,
                                              Colors.blue.shade900
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.25),
                                              blurRadius: 8,
                                              offset: const Offset(2, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: _scanNextOperator,
                                          child: const Icon(
                                              Icons.qr_code_scanner,
                                              size: 55),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 7,
                                child: NextMachineInfoTable(
                                  sisaShoot: data.sisaShoot,
                                  machineName: data.machineName,
                                  nextOperatorName: provider.nameNextOperator,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:provider/provider.dart';

import 'widget/record_header_row.dart';
import 'widget/employee_photo_card.dart';
import 'widget/employee_info_section.dart';
import 'widget/employee_action_buttons.dart';
import 'widget/pending_detail_section.dart';
import 'widget/job_number_banner.dart';
import 'widget/next_operator_card.dart';
import 'widget/next_machine_info_table.dart';

import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';

class ContinuePendingChangeOperator extends StatefulWidget {
  final String idPending;
  final void Function(bool)? onSuccess;

  const ContinuePendingChangeOperator({
    super.key,
    required this.idPending,
    this.onSuccess,
  });

  @override
  State<ContinuePendingChangeOperator> createState() =>
      _ContinuePendingChangeOperatorState();
}

class _ContinuePendingChangeOperatorState
    extends State<ContinuePendingChangeOperator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = context.read<PendingProvider>();

      prov.resetPendingDetail();
      prov.clearNextMachine();
      prov.resetEmployeeScanState();

      await prov.loadPendingDetailWithNg(int.parse(widget.idPending));
    });
  }

  Future<void> _scanNextOperator() async {
    final ctx = context;
    final overlay = Overlay.of(ctx, rootOverlay: true);

    final employeeProv = ctx.read<EmployeeProvider>();
    final pendingProv = ctx.read<PendingProvider>();

    final code = await Navigator.push<String>(
      ctx,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );
    if (!ctx.mounted) return;
    if (code == null || code.isEmpty || code == "-1") return;

    // ✅ VALIDASI OPERATOR TIDAK BOLEH SAMA
    final currentOperatorId = pendingProv.ngDetail.idEmployee;
    if (code == currentOperatorId) {
      CustomSnackbar.showWithOverlay(
        overlay,
        "ID EMPLOYEE TIDAK BOLEH SAMA, HARUS OPERATOR BARU",
        isSuccess: false,
      );
      return;
    }

    // 🔥 Scan employee lewat EmployeeProvider
    final success = await employeeProv.scanEmployee(code);

    if (!ctx.mounted) return;

    if (!success) {
      CustomSnackbar.showWithOverlay(
        overlay,
        employeeProv.errorMessage ?? "Employee scan failed",
        isSuccess: false,
      );
      return;
    }

    // 🔥 Employee valid → simpan ke PendingProvider
    pendingProv.attachEmployee(employeeProv.employee);
  }

  @override
  Widget build(BuildContext context) {
    final myAppBar = customDialogAppBar(
      title: 'CONTINUE RUNNING',
    );

    return Scaffold(
      appBar: myAppBar,
      body: Consumer<PendingProvider>(
        builder: (context, provider, _) {
          if (provider.isNgLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.ngError != null) {
            return Center(child: Text('Error: ${provider.ngError}'));
          }

          if (provider.ngDetail.isEmpty) {
            return const Center(
                child: Text('TIDAK ADA MOLDING YANG STOP SAAT INI'));
          }

          final data = provider.ngDetail;

          return SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    RecordHeaderRow(
                      idRecord: data.idRecord,
                      customer: data.customer,
                      productCategory: data.productCategory,
                      productType: data.productType,
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                EmployeePhotoCard(
                                  employeeId: data.idEmployee,
                                ),
                                const SizedBox(height: 12),
                                EmployeeInfoSection(
                                  name: data.employeeName,
                                  nrp: data.nrp,
                                  division: data.division,
                                  section: data.section,
                                ),
                                const SizedBox(height: 24),
                                EmployeeActionButtons(
                                  provider: provider,
                                  onSuccess: widget.onSuccess,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        PendingDetailSection(
                          data: data,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    JobNumberBanner(
                      jobNumber: data.jobnumber.toString(),
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              NextOperatorCard(
                                photoUrl:
                                    "${AppConfig.baseUrl}/media/img/employee/${provider.photoNextOperator}",
                                name: provider.nameNextOperator,
                                nrp: provider.nrpNextOperator,
                                division: provider.divNextOperator,
                                section: provider.secNextOperator,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blueAccent,
                                        Colors.blue.shade900
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(2, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _scanNextOperator,
                                    child: const Icon(Icons.qr_code_scanner,
                                        size: 55),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 7,
                          child: NextMachineInfoTable(
                            sisaShoot: data.sisaShoot,
                            machineName: data.machineName,
                            nextOperatorName: provider.nameNextOperator,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
*/
