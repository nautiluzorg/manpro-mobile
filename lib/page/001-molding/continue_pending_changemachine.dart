import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinuePendingChangeMachine extends StatefulWidget {
  final String idPending;
  final void Function(bool)? onSuccess;

  const ContinuePendingChangeMachine({
    Key? key,
    required this.idPending,
    this.onSuccess,
  }) : super(key: key);

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
      // prov.clearConfirmedEmployee();
      // prov.resetEmployeeScan();
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

    Widget _headerText(String text) => Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              decoration: TextDecoration.none),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent,
            Colors.blue.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _headerText(data.idRecord),
          _headerText(data.customer),
          _headerText(data.productCategory),
          _headerText(data.productType),
        ],
      ),
    );
  }

  // ================= MAIN CONTENT =================

  Widget _buildMainContent(PendingProvider prov) {
    final data = prov.pendingDetail.first;

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
                  // FOTO OPERATOR + INFO
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.20,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.18,
                              height: MediaQuery.of(context).size.width * 0.18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.green.shade100
                                        .withValues(alpha: 0.3),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigo.withValues(alpha: 0.2),
                                    spreadRadius: 4,
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1.5),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  "${AppConfig.baseUrl}/media/img/employee/${data.idEmployee}.png",
                                  width:
                                      MediaQuery.of(context).size.width * 0.16,
                                  height:
                                      MediaQuery.of(context).size.width * 0.16,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.employeeName,
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.nrp,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          data.section.toUpperCase(),
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          data.division,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              // TODO: aksi scan QR / buka scanner
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.indigoAccent,
                                    Colors.indigo.shade900
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigo.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // TABLE INFORMASI

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(4),
                            1: FlexColumnWidth(6),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            for (int i = 0; i < 9; i++)
                              TableRow(
                                decoration: BoxDecoration(
                                  color: i.isEven
                                      ? Colors.indigo.shade200.withValues(
                                          alpha: 0.15) // baris genap
                                      : Colors.white,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      [
                                        'JOB NUMBER',
                                        'DRAW NO',
                                        'PREVIOUS MACHINE',
                                        'QTY',
                                        'TIME STOP',
                                        'PENDING REASON',
                                        'STOP DURATION',
                                        'NEXT MACHINE',
                                        'EMPLOYEE COMFIRM',
                                      ][i],
                                      style: GoogleFonts.poppins(
                                        fontWeight: i == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),

                                    // ================= VALUE =================
                                    child: i == 8
                                        // -------- EMPLOYEE CONFIRM --------
                                        ? Row(
                                            children: [
                                              Text(
                                                ": ${prov.isEmployeeScanned ? prov.employeeName : "BELUM CONFIRM"}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: prov
                                                          .isEmployeeScanned
                                                      ? FontWeight
                                                          .bold // ✅ BOLD SAAT CONFIRMED
                                                      : FontWeight.normal,
                                                  color: prov.isEmployeeScanned
                                                      ? Colors.green
                                                      : Colors.black,
                                                ),
                                              ),
                                              const Spacer(),
                                              if (prov.isEmployeeScanned)
                                                Row(
                                                  children: const [
                                                    Text(
                                                      "CONFIRMED",
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 18,
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          )

                                        // -------- NEXT MACHINE --------
                                        : i == 7
                                            ? Row(
                                                children: [
                                                  Text(
                                                    ": ${prov.nextMachineName.isNotEmpty ? prov.nextMachineName.toUpperCase() : "BELUM DI TAMBAHKAN"}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      fontWeight: prov
                                                              .nextMachineName
                                                              .isNotEmpty
                                                          ? FontWeight
                                                              .bold // ✅ BOLD SAAT ADDED
                                                          : FontWeight.normal,
                                                      color: prov
                                                              .nextMachineName
                                                              .isNotEmpty
                                                          ? Colors.green
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  if (prov.nextMachineName
                                                      .isNotEmpty)
                                                    Row(
                                                      children: const [
                                                        Text(
                                                          "ADDED",
                                                          style: TextStyle(
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        Icon(
                                                          Icons.check_circle,
                                                          color: Colors.green,
                                                          size: 18,
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              )

                                            // -------- NORMAL ROW --------
                                            : Text(
                                                [
                                                  ": ${data.jobnumber}",
                                                  ": ${data.drawingNumber}",
                                                  ": ${data.machineName}",
                                                  ": ${data.qty}",
                                                  ": ${formatDateTime(data.startPending)}",
                                                  ": ${data.reason}",
                                                  ": ${getStopDuration(data.startPending)}",
                                                ][i],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: i == 0
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: i == 5
                                                      ? Colors.red
                                                      : Colors.black,
                                                ),
                                              ),
                                  ),
                                ],
                              ),
                          ],
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
              child: _buildActionButtons(prov),
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

  // ================= ACTION BUTTONS =================

  Widget _buildActionButtons(PendingProvider prov) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ---------------- CANCEL ----------------
        Expanded(
          child: SizedBox(
            height: 80,
            child: OutlinedButton(
              onPressed: () {
                prov.resetEmployeeState();
                prov.clearNextMachine();
                context.read<MachineProvider>().clearMachine();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'CANCEL',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // ---------------- ADD MACHINE ----------------
        Expanded(
          child: SizedBox(
            height: 80,
            child: buildCustomButton(
              text: 'NEW MC',
              height: 80,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.deepOrange.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              onPressed: () async {
                // 1️⃣ Scan QR code
                final scannedCode = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const MobileScannerPage()),
                );

                if (!mounted ||
                    scannedCode == null ||
                    scannedCode.isEmpty ||
                    scannedCode == "-1") {
                  return;
                }

                // ✅ Ambil provider setelah memastikan widget masih mounted
                final machineProv = context.read<MachineProvider>();
                final pendingProv = context.read<PendingProvider>();

                // 2️⃣ Validasi dan ambil detail mesin dari MachineProvider
                final errorMessage = await machineProv.scanMachine(scannedCode);

                if (!mounted) {
                  return;
                } // cek mounted lagi sebelum update UI/provider

                if (errorMessage != null) {
                  CustomSnackbar.show(context, errorMessage, isSuccess: false);
                  return;
                }

                // 3️⃣ Ambil data mesin dari MachineProvider
                final machineData = machineProv.machine;

                // 4️⃣ Update PendingProvider dengan data mesin yang benar
                pendingProv.setNextMachine(
                  id: machineData.idMc,
                  name: machineData.nmMc,
                );

                CustomSnackbar.show(
                    context, "Mesin berhasil dipilih: ${machineData.nmMc}",
                    isSuccess: true);
              },
            ),
          ),
        ),

        const SizedBox(width: 8),

        // ---------------- CONFIRM ----------------

        Expanded(
          child: SizedBox(
            height: 80,
            child: Builder(
              builder: (context) {
                final bool isEnabled =
                    prov.hasNextMachine && !prov.isSubmitting;

                return buildCustomButton(
                  text: 'CONFIRM',
                  height: 80,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  gradient: LinearGradient(
                    colors: isEnabled
                        ? [Colors.greenAccent, Colors.green.shade900]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  onPressed: isEnabled
                      ? () async {
                          final ctx = context; // ⬅ simpan context lokal

                          final code = await Navigator.push<String>(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => const MobileScannerPage(),
                            ),
                          );

                          if (!mounted ||
                              code == null ||
                              code.isEmpty ||
                              code == "-1") {
                            return;
                          }

                          final employeeProv = ctx.read<EmployeeProvider>();
                          final pendingProv = ctx.read<PendingProvider>();

                          final success = await employeeProv.scanEmployee(code);

                          if (!success) {
                            CustomSnackbar.show(
                              ctx,
                              employeeProv.errorMessage ?? "Scan failed",
                              isSuccess: false,
                            );
                            return;
                          }

                          pendingProv.attachEmployee(employeeProv.employee);
                        }
                      : null,
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 8),

        // ---------------- SUBMIT ----------------
        Expanded(
          child: SizedBox(
            height: 80,
            child: Builder(
              builder: (context) {
                final bool isEnabled =
                    prov.isEmployeeValid() && !prov.isSubmitting;

                return buildCustomButton(
                  text: 'SUBMIT',
                  height: 80,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  gradient: LinearGradient(
                    colors: isEnabled
                        ? [Colors.blueAccent, Colors.blue.shade900]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  onPressed: isEnabled
                      ? () async {
                          if (!prov.isEmployeeConfirmationValid) {
                            CustomSnackbar.show(context, "CONFIRM TIDAK SAMA",
                                isSuccess: false);
                            return;
                          }

                          final navigator =
                              Navigator.of(context, rootNavigator: true);
                          // SESUDAH
                          final idRecord = prov.pendingDetail.first
                              .idRecord; // ← ambil dari detail

                          final success = await prov.updatePendingRecordMc(
                            idPending: int.parse(widget.idPending),
                            idRecord: idRecord, // ← pass id_record
                          );

                          if (!mounted) return;
                          // 🔥 TAMBAHAN: refresh list-nya di sini, gak gantung ke pop chain
                          if (success) {
                            await prov.fetchPending('001');
                          }

                          if (!mounted) return;
                          if (widget.onSuccess != null) {
                            widget.onSuccess!(success);
                          }

                          navigator.pop(success);
                        }
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
