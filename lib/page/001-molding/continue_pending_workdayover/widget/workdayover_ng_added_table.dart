import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabel NG yang sudah di-ADD (nama NG, qty, tombol delete).
class WorkdayOverNgAddedTable extends StatelessWidget {
  final List<Map<String, dynamic>> ngItems;
  final void Function(int index) onDelete;

  const WorkdayOverNgAddedTable({
    super.key,
    required this.ngItems,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (ngItems.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(5),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1),
        },
        children: [
          // Header
          TableRow(
            children: [
              // NG NAME
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                  ),
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
              // QTY
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  'QTY',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // ACTION
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  'ACTION',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          // Rows
          ...ngItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final rowColor =
                index.isEven ? Colors.grey.shade100 : Colors.white;

            return TableRow(
              decoration: BoxDecoration(color: rowColor),
              children: [
                // NG NAME
                Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item['ng_name'] ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // QTY
                Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: Text(
                    '${item['qty']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // DELETE BUTTON
                Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red.shade400,
                    ),
                    onPressed: () => onDelete(index),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
