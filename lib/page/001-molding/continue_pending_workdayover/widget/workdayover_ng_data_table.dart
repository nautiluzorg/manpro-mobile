import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/model/ng_operator_model.dart';

/// Tabel data NG — READ ONLY.
/// Cuma menampilkan data (No, NG Name & Qty), tidak ada tombol edit/delete.
class WorkdayOverNgDataTable extends StatelessWidget {
  final List<NgOperatorModel> ngItems;

  const WorkdayOverNgDataTable({
    super.key,
    required this.ngItems,
  });

  @override
  Widget build(BuildContext context) {
    // Kalau data kosong, tampilkan teks info aja.
    if (ngItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00C853), // Green Accent
                Color(0xFF00A86B), // Emerald
                Color(0xFF00897B), // Teal
              ],
            ).createShader(
              Rect.fromLTWH(
                0,
                0,
                bounds.width,
                bounds.height,
              ),
            );
          },
          child: Text(
            'PERFORMA OPERATOR OK — TIDAK ADA DATA NG',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.6), // NO
          1: FlexColumnWidth(3), // NG NAME
          2: FlexColumnWidth(1), // QTY
        },
        border: TableBorder(
          horizontalInside: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        children: [
          // =========================
          // HEADER
          // =========================
          TableRow(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueAccent,
                  Colors.blue.shade900,
                ],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Center(
                  child: Text(
                    'NO',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Text(
                  'NG NAME',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'QTY',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // =========================
          // DATA
          // =========================
          ...ngItems.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final item = entry.value;

              return TableRow(
                children: [
                  // NO
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  // NG NAME
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      item.ngName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // QTY
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${item.qty}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
