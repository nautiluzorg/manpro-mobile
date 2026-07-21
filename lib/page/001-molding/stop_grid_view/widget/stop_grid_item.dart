import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/record_pending_model.dart';
import 'package:flutter_provider_data/page/001-molding/show_running_dialog.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StopGridItem extends StatelessWidget {
  final RecordPendingModel item;
  final bool isSelected;
  final String idProses;
  final VoidCallback onTap;

  const StopGridItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.idProses,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          _buildCard(context),
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
        ],
      ),
    );
  }

  // ── CARD ───────────────────────────────────────────────────────────────
  Widget _buildCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  Colors.green.shade200.withValues(alpha: 0.6),
                  Colors.green.shade100.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.green.shade400.withValues(alpha: 0.3)
                : Colors.grey.shade300.withValues(alpha: 0.2),
            blurRadius: isSelected ? 14 : 6,
            spreadRadius: isSelected ? 3 : 1,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isSelected ? Colors.lightGreen.shade500 : Colors.transparent,
          width: isSelected ? 3 : 1,
        ),
      ),
      // Konten (judul, foto, nama, tabel) dibungkus Expanded + scroll,
      // tombol CONTINUE ditaruh DI LUAR Expanded. Efeknya:
      // 1) kalau konten lebih tinggi dari cell grid, dia scroll (bukan
      //    overflow),
      // 2) posisi tombol CONTINUE selalu konsisten di semua card, karena
      //    Expanded selalu ngisi sisa ruang yang sama besar (GridView
      //    sudah menyamakan tinggi tiap cell).
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.jobnumber ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.grey.shade800
                          : Colors.blueGrey.shade600,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  _buildOperatorPhoto(),
                  const SizedBox(height: 6),
                  Text(
                    item.employeeName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.green.shade700 : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  _buildTable(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildContinueButton(context),
        ],
      ),
    );
  }

  // ── OPERATOR PHOTO ─────────────────────────────────────────────────────
  Widget _buildOperatorPhoto() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.green.shade300.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.1),
            ],
            stops: const [0.4, 1.0],
          ),
          border: Border.all(color: Colors.green.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade400.withValues(alpha: 0.25),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          // Dikecilkan dari 60 -> 42 supaya total tinggi konten lebih
          // ringkas dan lebih jarang butuh scroll di cell grid kecil.
          radius: 42,
          backgroundImage: NetworkImage(
            "${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png",
          ),
          onBackgroundImageError: (_, __) =>
              const Icon(Icons.person, size: 24, color: Colors.grey),
        ),
      ),
    );
  }

  // ── TABLE ──────────────────────────────────────────────────────────────
  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(6),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _tableRow('MACHINE', item.machineName),
          const TableRow(children: [SizedBox(height: 4), SizedBox(height: 2)]),
          _tableRow('DRAW NO', item.drawingNumber),
          const TableRow(children: [SizedBox(height: 4), SizedBox(height: 2)]),
          _tableRow('REASON', item.reason ?? '-', color: Colors.red.shade700),
        ],
      ),
    );
  }

  TableRow _tableRow(String label, String value, {Color? color}) {
    return TableRow(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            ': $value',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey.shade900,
            ),
          ),
        ),
      ],
    );
  }

  // ── CONTINUE BUTTON ────────────────────────────────────────────────────
  Widget _buildContinueButton(BuildContext context) {
    return Container(
      // Dikecilkan dari 60 -> 50 supaya hemat tinggi.
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          colors: isSelected
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : [Colors.greenAccent, Colors.green.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ElevatedButton(
        onPressed: isSelected ? null : () => _onContinue(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          "CONTINUE",
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── ON CONTINUE ────────────────────────────────────────────────────────
  Future<void> _onContinue(BuildContext context) async {
    final pendingProvider =
        Provider.of<PendingProvider>(context, listen: false);
    final overlay = Overlay.of(context, rootOverlay: true);

    try {
      final result = await showRunningDialog(
        context,
        item.idPending.toString(),
        item.idReason.toString(),
        idProses,
        item.productType,
      );

      if (!context.mounted) return;

      if (result == true) {
        pendingProvider.fetchPending(idProses);
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          "Record updated successfully!",
          isSuccess: true,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackbar.showWithOverlay(
        overlay,
        "Terjadi kesalahan: $e",
        isSuccess: false,
      );
    }
  }
}
