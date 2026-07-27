import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ContinuePending extends StatefulWidget {
  final String idPending;
  final String idProses;
  final void Function(bool)? onSuccess;

  const ContinuePending({
    Key? key,
    required this.idPending,
    required this.idProses,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<ContinuePending> createState() => _ContinuePendingState();
}

class _ContinuePendingState extends State<ContinuePending> {
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
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(6),
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
                                    color: Colors.green.shade300
                                        .withValues(alpha: 0.4),
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
                        const SizedBox(height: 8),
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
                            for (int i = 0; i < 8; i++)
                              TableRow(
                                decoration: BoxDecoration(
                                  color: i.isEven
                                      ? Colors.grey.shade200
                                      : Colors.white,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      [
                                        'JOB NUMBER',
                                        'DRAW NO',
                                        'MACHINE',
                                        'QTY',
                                        'TIME STOP',
                                        'PENDING REASON',
                                        'STOP DURATION',
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
                                    child: i == 7
                                        ? Row(
                                            children: [
                                              // Nama employee di kiri
                                              Text(
                                                ": ${prov.isEmployeeScanned ? prov.employeeName : "BELUM CONFIRM"}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  color: prov.isEmployeeScanned
                                                      ? Colors.green
                                                      : Colors.black,
                                                ),
                                              ),
                                              const Spacer(), // supaya CONFIRMED + icon ke kanan paling ujung
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
                // prov.resetEmployeeScan();
                prov.resetEmployeeState();

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

        // ---------------- CONFIRM ----------------
        Expanded(
          child: SizedBox(
            height: 80,
            child: buildCustomButton(
              text: 'CONFIRM',
              height: 80,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              gradient: LinearGradient(
                colors: [
                  Colors.greenAccent,
                  Colors.green.shade600,
                  Colors.green.shade900
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              onPressed: () async {
                final ctx = context; // ⬅ aman sebelum async gap
                final overlay = Overlay.of(ctx, rootOverlay: true);

                final employeeProv = ctx.read<EmployeeProvider>();
                final pendingProv = ctx.read<PendingProvider>();

                final code = await Navigator.push<String>(
                  ctx,
                  MaterialPageRoute(builder: (_) => const MobileScannerPage()),
                );

                if (!ctx.mounted) return;
                if (code == null || code.isEmpty || code == "-1") return;

                // 🔥 Scan employee lewat EmployeeProvider
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

                // 🔥 Employee valid → simpan ke PendingProvider
                pendingProv.attachEmployee(employeeProv.employee);
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
                        ? [
                            Colors.blueAccent,
                            Colors.blue.shade600,
                            Colors.blue.shade900
                          ]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  onPressed: isEnabled
                      ? () async {
                          // ✅ Ini aman — ScaffoldMessenger dipakai SEBELUM await
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
                          // ✅ Simpan reference sebelum await
                          final navigator =
                              Navigator.of(context, rootNavigator: true);

                          final success = await prov.updatePendingRecordNormal(
                            int.parse(widget.idPending),
                          );

                          if (!mounted) return;
                          // 🔥 TAMBAHAN: refresh list-nya di sini, gak gantung ke pop chain
                          if (success) {
                            await prov.fetchPending(widget.idProses);
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
