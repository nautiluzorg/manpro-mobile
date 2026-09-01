import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';

class PendingMachineInfoTable extends StatelessWidget {
  final dynamic data; // pending detail
  final PendingProvider prov;

  const PendingMachineInfoTable({
    super.key,
    required this.data,
    required this.prov,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(6),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (int i = 0; i < 9; i++)
          TableRow(
            decoration: BoxDecoration(
              color: i.isEven
                  ? Colors.indigo.shade200
                      .withValues(alpha: 0.15) // baris genap
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
                    fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
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
                              fontWeight: prov.isEmployeeScanned
                                  ? FontWeight.bold // ✅ BOLD SAAT CONFIRMED
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

                    // -------- NEXT MACHINE --------
                    : i == 7
                        ? Row(
                            children: [
                              Text(
                                ": ${prov.nextMachineName.isNotEmpty ? prov.nextMachineName.toUpperCase() : "BELUM DI TAMBAHKAN"}",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: prov.nextMachineName.isNotEmpty
                                      ? FontWeight.bold // ✅ BOLD SAAT ADDED
                                      : FontWeight.normal,
                                  color: prov.nextMachineName.isNotEmpty
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                              const Spacer(),
                              if (prov.nextMachineName.isNotEmpty)
                                Row(
                                  children: const [
                                    Text(
                                      "ADDED",
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
                              fontWeight:
                                  i == 0 ? FontWeight.bold : FontWeight.normal,
                              color: i == 5 ? Colors.red : Colors.black,
                            ),
                          ),
              ),
            ],
          ),
      ],
    );
  }
}
