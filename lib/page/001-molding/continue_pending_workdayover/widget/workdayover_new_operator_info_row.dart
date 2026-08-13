import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/utils/logger.dart';

/// Row kiri (foto + tombol scan QR operator baru) dan kanan
/// (tabel info record + tombol BACK/SUBMIT).
class WorkdayOverNewOperatorInfoRow extends StatelessWidget {
  final dynamic data; // pending detail lama
  final String scannedEmployeeId;
  final String scannedEmployeeName;
  final String scannedEmployeeSection;
  final String scannedEmployeeDivision;
  final bool qtyShootFilled;
  final VoidCallback onScanNewOperator;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const WorkdayOverNewOperatorInfoRow({
    super.key,
    required this.data,
    required this.scannedEmployeeId,
    required this.scannedEmployeeName,
    required this.scannedEmployeeSection,
    required this.scannedEmployeeDivision,
    required this.qtyShootFilled,
    required this.onScanNewOperator,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasScanned = scannedEmployeeId.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── FOTO OPERATOR + INFO ─────────────────────────────────
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
                            hasScanned
                                ? Colors.orange.shade100.withValues(alpha: 0.3)
                                : Colors.grey.shade300.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: hasScanned
                                ? Colors.orange.shade300.withValues(alpha: 0.4)
                                : Colors.grey.shade400.withValues(alpha: 0.3),
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
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: hasScanned
                            ? Image.network(
                                "${AppConfig.baseUrl}/media/img/employee/$scannedEmployeeId.png",
                                width: MediaQuery.of(context).size.width * 0.16,
                                height:
                                    MediaQuery.of(context).size.width * 0.16,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.grey,
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.16,
                                height:
                                    MediaQuery.of(context).size.width * 0.16,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  scannedEmployeeName.isEmpty
                      ? 'OPERATOR NAME'
                      : scannedEmployeeName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                Text(
                  scannedEmployeeId.isEmpty ? 'ID SAP' : scannedEmployeeId,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                Text(
                  scannedEmployeeSection.isEmpty
                      ? 'Section'
                      : scannedEmployeeSection.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                Text(
                  scannedEmployeeDivision.isEmpty
                      ? 'Division'
                      : scannedEmployeeDivision,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // ── BUTTON SCAN QR ─────────────────────────────────
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.blue.shade900],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
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
                      onPressed: onScanNewOperator,
                      child: const Icon(Icons.qr_code_scanner, size: 55),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT : DETAIL & FORM ────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TABLE INFORMASI ────────────────────────────
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(4),
                    1: FlexColumnWidth(6),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    for (int i = 0; i < 8; i++)
                      TableRow(
                        decoration: BoxDecoration(
                          color: i.isEven ? Colors.grey.shade200 : Colors.white,
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
                                'NEW OPERATOR',
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

                                // ── ROW OPERATOR ─────────
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          hasScanned
                                              ? ": $scannedEmployeeName"
                                              : ": BELUM SCAN",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            color: hasScanned
                                                ? Colors.green
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      if (hasScanned)
                                        Row(
                                          children: const [
                                            Text(
                                              "READY",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
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

                                // ── NORMAL ROW ───────────
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
                                      color: i == 5 ? Colors.red : Colors.black,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 70,
                        child: OutlinedButton(
                          onPressed: onBack,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(
                              color: Colors.red.shade700,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'BACK',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildCustomButton(
                        text: 'SUBMIT',
                        height: 70,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: hasScanned
                              ? [Colors.blueAccent, Colors.blue.shade900]
                              : [Colors.grey.shade400, Colors.grey.shade600],
                        ),
                        onPressed:
                            (!hasScanned || !qtyShootFilled) ? null : onSubmit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
