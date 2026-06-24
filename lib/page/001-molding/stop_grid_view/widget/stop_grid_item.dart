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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.jobnumber ?? '-',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isSelected ? Colors.grey.shade800 : Colors.blueGrey.shade600,
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
              color: isSelected ? Colors.green.shade700 : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          _buildTable(),
          const Spacer(),
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
          radius: 60,
          backgroundImage: NetworkImage(
            "${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png",
          ),
          onBackgroundImageError: (_, __) =>
              const Icon(Icons.person, size: 28, color: Colors.grey),
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
      height: 60,
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
            fontSize: 18,
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

      if (result == true) {
        pendingProvider.fetchPending(idProses);
        CustomSnackbar.show(
          context,
          "Record updated successfully!",
          isSuccess: true,
        );
      }
    } catch (e) {
      CustomSnackbar.showWithOverlay(
        overlay,
        "Terjadi kesalahan: $e",
        isSuccess: false,
      );
    }
  }
}
