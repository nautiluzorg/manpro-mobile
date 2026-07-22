import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';

/// "MACHINE PARAMETER" table: MC Temperature (upper/lower range fields),
/// MC Curing, MC Pressure, MC Setting.
///
/// Extracted verbatim from record_testing.dart. This table's rows aren't
/// interchangeable like the checklist tables (each row has a different
/// input shape), so it stays a dedicated widget rather than being
/// generalized further.
class MachineParameterTable extends StatelessWidget {
  final TextEditingController mcTempUpperCtrl;
  final TextEditingController mcTempLowerCtrl;
  final TextEditingController mcTempLowUpperCtrl;
  final TextEditingController mcTempLowLowerCtrl;
  final TextEditingController mcCuringCtrl;
  final TextEditingController mcPressureCtrl;
  final TextEditingController mcSettingsCtrl;

  /// Called whenever the upper temperature-range inputs change, so the
  /// caller can persist `"$upper-$lower"` into TestingProvider.mcTempUpper
  /// exactly like the original `_saveTemp`.
  final VoidCallback onTempUpperChanged;

  /// Same as above but for the lower temperature-range inputs
  /// (TestingProvider.mcTempLower / original `_saveTempLower`).
  final VoidCallback onTempLowerChanged;

  const MachineParameterTable({
    super.key,
    required this.mcTempUpperCtrl,
    required this.mcTempLowerCtrl,
    required this.mcTempLowUpperCtrl,
    required this.mcTempLowLowerCtrl,
    required this.mcCuringCtrl,
    required this.mcPressureCtrl,
    required this.mcSettingsCtrl,
    required this.onTempUpperChanged,
    required this.onTempLowerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TestingProvider>(
      builder: (context, provid, _) {
        return Table(
          border: TableBorder.all(color: Colors.grey, width: 0.6),
          columnWidths: const {
            0: FixedColumnWidth(40),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(3),
          },
          children: [
            _headerRow(),
            _row1Temperature(),
            _row2Curing(provid),
            _row3Pressure(provid),
            _row4Settings(provid),
          ],
        );
      },
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
        _headerCell("NO"),
        _headerCell("ITEM"),
        _headerCell("ITEM DETAIL"),
        _headerCell("ACTUAL"),
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

  Widget _numberField(TextEditingController controller, VoidCallback onChanged) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 14),
      decoration: const InputDecoration(
        hintText: "0",
        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  TableRow _row1Temperature() {
    return TableRow(
      decoration: BoxDecoration(
          color: Colors.blueGrey.shade50.withValues(alpha: 0.5)),
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text("1",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text("MC TEMPERATURE",
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("TEMPERATURE UPPER (°C)",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 30),
                  Text("TEMPERATURE LOWER (°C)",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: _numberField(mcTempUpperCtrl, onTempUpperChanged)),
                      const SizedBox(width: 8),
                      const Text("-",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField(mcTempLowerCtrl, onTempUpperChanged)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _numberField(mcTempLowUpperCtrl, onTempLowerChanged)),
                      const SizedBox(width: 8),
                      const Text("-",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField(mcTempLowLowerCtrl, onTempLowerChanged)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _row2Curing(TestingProvider provid) {
    return TableRow(children: [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text("2", textAlign: TextAlign.center),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text("MC CURING"),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text("CURING TIME (seconds)"),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: TextField(
            controller: mcCuringCtrl,
            onChanged: (value) => provid.mcCuring = value,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: "0",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
      ),
    ]);
  }

  TableRow _row3Pressure(TestingProvider provid) {
    return TableRow(
        decoration: BoxDecoration(
            color: Colors.blueGrey.shade50.withValues(alpha: 0.5)),
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text("3", textAlign: TextAlign.center),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text("MC PRESSURE"),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text("PRESSURE (kfg/cm²)"),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: TextField(
                controller: mcPressureCtrl,
                onChanged: (value) => provid.mcPressure = value,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "0",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ),
        ]);
  }

  TableRow _row4Settings(TestingProvider provid) {
    return TableRow(children: [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text("4", textAlign: TextAlign.center),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text("MC SETTING"),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text("SETTING"),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: TextField(
            controller: mcSettingsCtrl,
            onChanged: (value) => provid.mcSettings = value,
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\- ]')),
            ],
            decoration: const InputDecoration(
              hintText: "0 0 0-0 0 0 0 0",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
      ),
    ]);
  }
}
