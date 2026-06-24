import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_pending_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

// ===============================
// File: confirm_dialog_page.dart
// ===============================
class DialogConfirmMassRunning extends StatefulWidget {
  final List<RecordPendingModel> selectedItems;
  final String idProses;

  const DialogConfirmMassRunning({
    super.key,
    required this.selectedItems,
    required this.idProses,
  });

  @override
  State<DialogConfirmMassRunning> createState() =>
      _DialogConfirmMassRunningState();
}

class _DialogConfirmMassRunningState extends State<DialogConfirmMassRunning> {
  @override
  void initState() {
    super.initState();

    /// Reset SEMUA state scan saat dialog dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingProv = context.read<PendingProvider>();

      pendingProv.resetEmployeeScanState();
      pendingProv.clearNextMachine();
      pendingProv.resetNextOperatorState();
    });
  }

  bool _isEmployeeConfirmationValid(
    List<RecordPendingModel> items,
    PendingProvider prov,
  ) {
    if (!prov.hasConfirmedEmployee) return false;

    final confirmId = prov.confirmedEmployee.idEmployee;

    return items.every(
      (r) => r.idEmployee == confirmId, // ← ganti di sini
    );
  }

  @override
  Widget build(BuildContext context) {
    final myAppBar = customDialogAppBar(
      title: "OPERATOR CONFIRM",
    );
    final maxGridHeight = MediaQuery.of(context).size.height * 0.4;

    return Scaffold(
      appBar: myAppBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          children: [
            Text(
              "LIST JOBNUMBER YANG AKAN DI RUNNING",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height:
                  (widget.selectedItems.length / 2).ceil() * 160 > maxGridHeight
                      ? maxGridHeight
                      : (widget.selectedItems.length / 2).ceil() * 160,
              child: GridView.builder(
                padding: const EdgeInsets.all(4),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 kolom
                  childAspectRatio: 2.5, // lebih besar dan panjang
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: widget.selectedItems.length,
                itemBuilder: (context, index) {
                  final r = widget.selectedItems[index];
                  return _buildItemCard(r); // gunakan fungsi item card
                },
              ),
            ),
            const SizedBox(height: 10),
            Consumer<PendingProvider>(
              builder: (context, prov, _) {
                return _buildEmployeeConfirmBox(prov);
              },
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildCancelButton(context),
                const SizedBox(width: 12),
                _buildConfirmButton(context),
                const SizedBox(width: 12),
                _buildSubmitButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeConfirmBox(PendingProvider prov) {
    final hasEmployee = prov.hasConfirmedEmployee;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueGrey.shade50,
            Colors.blue.shade50.withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(color: Colors.blueGrey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.shade300.withValues(alpha: 0.35),
            blurRadius: 5,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL
          Text(
            "OPERATOR CONFIRM :",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              // FOTO
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: NetworkImage(
                      "${AppConfig.baseUrl}/media/img/employee/"
                      "${hasEmployee ? '${prov.confirmedEmployee.idEmployee}.png' : 'employee.png'}",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // NAMA
              Expanded(
                child: Text(
                  hasEmployee ? prov.confirmedEmployee.fullName : "-",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
              ),

              // ===== STATUS CONFIRMED =====
              if (hasEmployee)
                Row(
                  children: [
                    Text(
                      "CONFIRMED",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Contoh fungsi build item card
  Widget _buildItemCard(RecordPendingModel r) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueGrey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // FOTO OPERATOR
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blueGrey.shade200, width: 1.5),
              image: DecorationImage(
                image: NetworkImage(
                  "${AppConfig.baseUrl}/media/img/employee/${r.idEmployee}.png", // ← ganti di sini
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(4), // label
                1: FlexColumnWidth(4), // value
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                _buildTableRow("NAMA", r.employeeName),
                _buildTableRow("MACHINE", r.machineName),
                _buildTableRow("JOBNUMBER", r.jobnumber.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ================== Table Row Builder ==================
  TableRow _buildTableRow(String label, String value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          "$label:",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    ]);
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 70,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade800, width: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          "CANCEL",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.red.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 70,
      child: buildCustomButton(
        text: "CONFIRM",
        height: 70,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        gradient: LinearGradient(
          colors: [
            Colors.greenAccent,
            Colors.green.shade500,
            Colors.green.shade900,
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
              employeeProv.errorMessage ?? "Employee scan failed",
              isSuccess: false,
            );
            return;
          }

          // 🔥 Employee valid → simpan ke PendingProvider
          pendingProv.attachEmployee(employeeProv.employee);
        },
      ),
    );

/*
    SizedBox(
      width: 180,
      height: 70,
      child: buildCustomButton(
        text: "CONFIRM",
        height: 70,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        gradient: LinearGradient(
          colors: [
            Colors.greenAccent,
            Colors.green.shade500,
            Colors.green.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        onPressed: () async {
          final pendingProvider = context.read<PendingProvider>();

          final code = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => const MobileScannerPage()),
          );

          if (!context.mounted ||
              code == null ||
              code.isEmpty ||
              code == "-1") {
            return;
          }

          final success = await pendingProvider.scanEmployee(code);

          if (!context.mounted) return;

          if (!success) {
            CustomSnackbar.show(
              context,
              pendingProvider.errorMessage ?? "Employee scan failed",
              isSuccess: false,
            );
          }
        },
      ),
    );
*/
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Selector<PendingProvider, bool>(
      selector: (_, prov) =>
          prov.confirmedEmployee.idEmployee.isNotEmpty && !prov.isSubmitting,
      builder: (context, canSubmit, _) {
        return SizedBox(
          width: 180,
          height: 70,
          child: buildCustomButton(
            text: "SUBMIT",
            height: 70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.blue.shade600,
                Colors.blue.shade900,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            onPressed: canSubmit
                ? () async {
                    final prov = context.read<PendingProvider>();
                    final isValid = _isEmployeeConfirmationValid(
                        widget.selectedItems, prov);

                    if (!isValid) {
                      CustomSnackbar.show(
                        context,
                        "CONFIRMASI TIDAK VALID",
                        isSuccess: false,
                      );
                      return;
                    }

                    final success =
                        await prov.submitMassRecords(widget.selectedItems);

                    if (!context.mounted) return;

                    if (success) {
                      await prov.reload(widget.idProses);
                      widget.selectedItems.clear();
                      Navigator.pop(context);
                      CustomSnackbar.show(
                        context,
                        "Submit berhasil!",
                        isSuccess: true,
                      );
                    } else {
                      CustomSnackbar.show(
                        context,
                        prov.errorMessage ?? "Submit gagal",
                        isSuccess: false,
                      );
                    }
                  }
                : null,
          ),
        );
      },
    );
  }
}
