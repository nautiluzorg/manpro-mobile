import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'no_leading_zero_formatter.dart';
import 'workdayover_ng_input_row.dart';
import 'workdayover_ng_added_table.dart';

/// Section "ADD QTY SHOOT & QTY NG": text field qty shoot, baris input NG,
/// dan tabel NG yang sudah ditambahkan.
class WorkdayOverNgSection extends StatelessWidget {
  final dynamic data; // pending detail (untuk nama employee lama)
  final TextEditingController qtyShootController;
  final NGProvider ngProvider;
  final String? selectedNgId;
  final int qtyNg;
  final List<Map<String, dynamic>> addedNgItems;
  final ValueChanged<NgDropdownModel> onNgSelected;
  final VoidCallback onIncrementNg;
  final VoidCallback onDecrementNg;
  final VoidCallback onAddNg;
  final void Function(int index) onDeleteNg;

  const WorkdayOverNgSection({
    super.key,
    required this.data,
    required this.qtyShootController,
    required this.ngProvider,
    required this.selectedNgId,
    required this.qtyNg,
    required this.addedNgItems,
    required this.onNgSelected,
    required this.onIncrementNg,
    required this.onDecrementNg,
    required this.onAddNg,
    required this.onDeleteNg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── QTY SHOOT ─────────────────────────────────────────────
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'ADD QTY SHOOT & QTY NG FOR ',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey.shade700,
                    letterSpacing: 0.4,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.orangeAccent,
                        Colors.deepOrange.shade900,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: Text(
                      data.employeeName.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: qtyShootController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              NoLeadingZeroFormatter(),
            ],
            decoration: InputDecoration(
              hintText: 'Input Qty Shoot',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.normal,
                fontSize: 13,
              ),
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          // ── NG ROW ────────────────────────────────────────────────
          WorkdayOverNgInputRow(
            ngProvider: ngProvider,
            selectedNgId: selectedNgId,
            qtyNg: qtyNg,
            onNgSelected: onNgSelected,
            onIncrement: onIncrementNg,
            onDecrement: onDecrementNg,
            onAdd: onAddNg,
          ),

          // ── TABEL NG YANG SUDAH DI-ADD ───────────────────────────
          if (addedNgItems.isNotEmpty) ...[
            const SizedBox(height: 10),
            WorkdayOverNgAddedTable(
              ngItems: addedNgItems,
              onDelete: onDeleteNg,
            ),
          ],
        ],
      ),
    );
  }
}
