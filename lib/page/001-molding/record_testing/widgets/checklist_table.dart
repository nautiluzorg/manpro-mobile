import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/checklist_data.dart';

/// Generic checklist table used by both "MOLD SETUP" and "VACUM JIG SETUP".
///
/// In the original file these were two ~500-line blocks of copy-pasted
/// TableRows that only differed in text content and which provider
/// getter/setter they called. This widget keeps the exact same visuals and
/// behavior; only the item text (`items`) and the checkbox wiring
/// (`isChecked` / `onToggle`) change per section.
///
/// Row striping note: the original code alternated the background using
/// `1 % 2 == 1` written directly per-row (a literal, not `index % 2`) —
/// every odd-numbered row (1st, 3rd, 5th, ...) had the tint block, every
/// even-numbered row had none. `index.isEven` below reproduces that exact
/// rendered result.
class ChecklistTable extends StatelessWidget {
  final List<ChecklistItem> items;
  final bool Function(int index) isChecked;
  final void Function(int index, bool value) onToggle;

  const ChecklistTable({
    super.key,
    required this.items,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey, width: 0.6),
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(5),
        3: FlexColumnWidth(1),
      },
      children: [
        _headerRow(),
        for (int i = 0; i < items.length; i++) _itemRow(i, items[i]),
      ],
    );
  }

  TableRow _headerRow() {
    return TableRow(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigoAccent, Colors.indigo.shade900],
        ),
      ),
      children: [
        _headerCell('NO'),
        _headerCell('ITEM'),
        _headerCell('REMARK'),
        _headerCell('JUDGMENT'),
      ],
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  TableRow _itemRow(int index, ChecklistItem data) {
    final bool striped = index.isEven; // see class doc for why
    final bool checked = isChecked(index);

    return TableRow(
      decoration: BoxDecoration(
        color: striped
            ? Colors.blueGrey.shade50.withValues(alpha: 0.5)
            : Colors.white,
      ),
      children: [
        _cell(
          Center(child: Text('${index + 1}', textAlign: TextAlign.center)),
        ),
        _cell(
          Align(alignment: Alignment.centerLeft, child: Text(data.item)),
        ),
        _cell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final remark in data.remarks) Text(remark)],
          ),
        ),
        _cell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1.5,
                child: Checkbox(
                  value: checked,
                  activeColor: Colors.orangeAccent.shade700,
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  onChanged: (value) => onToggle(index, value!),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: checked ? FontWeight.bold : FontWeight.w500,
                  color:
                      checked ? Colors.orangeAccent.shade700 : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableCell _cell(Widget child) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: SizedBox(
        height: 90,
        child: Padding(padding: const EdgeInsets.all(6), child: child),
      ),
    );
  }
}
