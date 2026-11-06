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
  static const double _pagePadding = 16;
  static const double _sectionGap = 20;
  static const double _labelGap = 10;
  static const double _maxContentWidth = 900;
  static const double _buttonHeight = 80;

  // ===== Ukuran card list =====
  static const double _itemHeight = 200; // tinggi tiap card
  static const double _itemGap = 10; // jarak antar card
  static const double _itemPadding = 12;
  static const double _photoSize = 140; // = _itemHeight - 2 * _itemPadding
  static const double _photoRadius = 12;

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

    final confirmId = prov.confirmedEmployee.idEmployee.trim().toUpperCase();

    return items.every(
      (r) => r.idEmployee.trim().toUpperCase() == confirmId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customDialogAppBar(title: "CONTINUE PENDING MOLDING"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_pagePadding),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: _maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel(
                          "DAFTAR JOBNUMBER YANG AKAN DI-RUNNING:",
                        ),
                        const SizedBox(height: _labelGap),
                        _buildSelectedItemsList(),
                        const SizedBox(height: _sectionGap),
                        const _SectionLabel("KONFIRMASI OPERATOR:"),
                        const SizedBox(height: _labelGap),
                        Consumer<PendingProvider>(
                          builder: (context, prov, _) =>
                              _buildEmployeeConfirmBox(prov),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  /// List ke bawah, tiap card memenuhi lebar layar (tinggi tetap 100).
  /// Ikut scroll halaman (tidak punya scroll sendiri).
  Widget _buildSelectedItemsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: widget.selectedItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: _itemGap),
      itemBuilder: (context, index) {
        return SizedBox(
          height: _itemHeight,
          width: double.infinity,
          child: RepaintBoundary(
            child: _buildItemCard(widget.selectedItems[index]),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        _pagePadding,
        12,
        _pagePadding,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Row(
            children: [
              Expanded(child: _buildCancelButton(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildConfirmButton(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildSubmitButton(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeConfirmBox(PendingProvider prov) {
    final hasEmployee = prov.hasConfirmedEmployee;
    final imageUrl = "${AppConfig.baseUrl}/media/img/employee/"
        "${hasEmployee ? '${prov.confirmedEmployee.idEmployee}.png' : 'employee.png'}";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasEmployee ? Colors.green.shade50 : const Color(0xFFF9FAFB),
        border: Border.all(
          color: hasEmployee ? Colors.green.shade300 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasEmployee
                  ? Image.network(
                      imageUrl,
                      cacheWidth: 128,
                      cacheHeight: 128,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.qr_code_scanner,
                      size: 32,
                      color: Colors.grey,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CONFIRMED BY",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasEmployee
                      ? prov.confirmedEmployee.fullName
                      : "BELUM DIKONFIRMASI",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: hasEmployee ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (hasEmployee)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      color: Colors.green.shade700, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "CONFIRMED",
                    style: GoogleFonts.poppins(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            const Icon(Icons.info_outline_rounded,
                color: Colors.grey, size: 24),
        ],
      ),
    );
  }

  Widget _buildItemCard(RecordPendingModel r) {
    final imageUrl =
        "${AppConfig.baseUrl}/media/img/employee/${r.idEmployee}.png";

    return Container(
      padding: const EdgeInsets.all(_itemPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_photoRadius),
            child: Image.network(
              imageUrl,
              width: _photoSize,
              height: _photoSize,
              cacheWidth: 192,
              cacheHeight: 192,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: _photoSize,
                height: _photoSize,
                color: Colors.white24,
                alignment: Alignment.center,
                child: const Icon(Icons.person, size: 38, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.employeeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                _buildInfoLine("JOBNUMBER", r.jobnumber ?? '-'),
                _buildInfoLine("MACHINE", r.machineName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Lebar kolom label supaya titik dua dan nilai rata seperti tabel
  static const double _infoLabelWidth = 104;

  Widget _buildInfoLine(String label, String value) {
    final labelStyle = GoogleFonts.poppins(
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w500,
      color: Colors.white70,
    );

    return Row(
      children: [
        // Kolom 1: label (lebar tetap)
        SizedBox(
          width: _infoLabelWidth,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
        ),
        // Kolom 2: titik dua (lebar tetap)
        SizedBox(
          width: 14,
          child: Text(":", style: labelStyle),
        ),
        // Kolom 3: nilai (melebar mengisi sisa)
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      height: _buttonHeight,
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
            fontSize: 20,
            color: Colors.red.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      height: _buttonHeight,
      child: buildCustomButton(
        text: "CONFIRM",
        height: _buttonHeight,
        fontSize: 20,
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
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Selector<PendingProvider, bool>(
      selector: (_, prov) =>
          prov.confirmedEmployee.idEmployee.isNotEmpty && !prov.isSubmitting,
      builder: (context, canSubmit, _) {
        return SizedBox(
          height: _buttonHeight,
          child: buildCustomButton(
            text: "SUBMIT",
            height: _buttonHeight,
            fontSize: 20,
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

                      if (!context.mounted) return;

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

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Colors.blueGrey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
