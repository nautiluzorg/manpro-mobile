import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/model/ng_operator_model.dart';
import 'workdayover_action_buttons.dart';
import 'workdayover_ng_data_table.dart';
import 'package:flutter_provider_data/utils/logger.dart';

/// Konten utama halaman "continue same operator": foto + tabel info
/// record, tabel data NG, lalu tombol-tombol aksi di bawahnya.
class WorkdayOverMainContent extends StatelessWidget {
  final PendingProvider prov;
  final List<NgOperatorModel> ngItems;

  final VoidCallback onCancel;
  final VoidCallback onConfirmScan;
  final VoidCallback onSubmit;
  final VoidCallback onContinueNewOperator;

  const WorkdayOverMainContent({
    super.key,
    required this.prov,
    required this.ngItems,
    required this.onCancel,
    required this.onConfirmScan,
    required this.onSubmit,
    required this.onContinueNewOperator,
  });

  @override
  Widget build(BuildContext context) {
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
            // ── AREA OPERATOR & TABLE ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── FOTO OPERATOR + INFO ─────────────────────────────
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
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
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
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.employeeName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.nrp,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          data.section.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          data.division,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ── TABLE INFORMASI ──────────────────────────────────
                  Expanded(
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(4),
                        1: FlexColumnWidth(6),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        for (int i = 0; i < 11; i++)
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
                                    'QTY SHOOT TOTAL',
                                    'QTY SHOOT FINISHED',
                                    'QTY SHOOT REMAINING',
                                    'EMPLOYEE CONFIRM',
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
                                child: i == 10
                                    ? Row(
                                        children: [
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
                                          const Spacer(),
                                          if (prov.isEmployeeScanned)
                                            const Row(
                                              children: [
                                                Text(
                                                  "CONFIRMED",
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
                                    : Text(
                                        [
                                          ": ${data.jobnumber}",
                                          ": ${data.drawingNumber}",
                                          ": ${data.machineName}",
                                          ": ${data.qty}",
                                          ": ${formatDateTime(data.startPending)}",
                                          ": ${data.reason}",
                                          ": ${getStopDuration(data.startPending)}",
                                          ": ${data.shootQty}",
                                          ": ${data.lastQtyShoot}",
                                          ": ${data.sisaShoot}",
                                        ][i],
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: i == 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: i == 5
                                              ? Colors.red
                                              : i == 9
                                                  ? Colors.orange.shade800
                                                  : Colors.black,
                                        ),
                                      ),
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

            // ── DATA NG (READ-ONLY, di atas action buttons) ────────────
            WorkdayOverNgDataTable(
              ngItems: ngItems,
            ),

            const SizedBox(height: 12),

            WorkdayOverActionButtons(
              prov: prov,
              onCancel: onCancel,
              onConfirmScan: onConfirmScan,
              onSubmit: onSubmit,
              onContinueNewOperator: onContinueNewOperator,
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
