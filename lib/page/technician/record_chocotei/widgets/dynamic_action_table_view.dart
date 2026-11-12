import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/technician/record_chocotei/model/action_record.dart';
import 'package:google_fonts/google_fonts.dart';

class DynamicActionTableView extends StatelessWidget {
  const DynamicActionTableView({
    super.key,
    required this.heightBody,
    required this.screenWidth,
    required this.actions,
    required this.onDelete,
    required this.onStart,
    required this.onFinish,
  });

  final double heightBody;
  final double screenWidth;
  final List<ActionRecord> actions;
  final ValueChanged<ActionRecord> onDelete;
  final ValueChanged<ActionRecord> onStart;
  final ValueChanged<ActionRecord> onFinish;

  @override
  Widget build(BuildContext context) {
    final codeWidth = screenWidth * 0.12;
    final actionWidth = screenWidth * 0.40;
    final startWidth = screenWidth * 0.16;
    final finishWidth = screenWidth * 0.16;
    final statusWidth = screenWidth * 0.16;

    return Container(
      padding: const EdgeInsets.all(2),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: heightBody * 0.14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4)],
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4)],
        ),
        child: SizedBox(
          height: (heightBody * 0.55).clamp(260.0, 560.0).toDouble(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 32,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: screenWidth),
                child: DataTable(
                  columnSpacing: 0,
                  horizontalMargin: 0,
                  headingRowHeight: 50,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 76,
                  headingRowColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  columns: [
                    DataColumn(label: _headerCell('KODE', codeWidth)),
                    DataColumn(label: _headerCell('ACTION TAKEN', actionWidth)),
                    DataColumn(label: _headerCell('START', startWidth)),
                    DataColumn(label: _headerCell('FINISH', finishWidth)),
                    DataColumn(label: _headerCell('STATUS', statusWidth)),
                  ],
                  rows: actions.isEmpty
                      ? [
                          const DataRow(
                            cells: [
                              DataCell(SizedBox.shrink()),
                              DataCell(
                                Text(
                                  'Belum ada action yang dipilih',
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                              ),
                              DataCell(SizedBox.shrink()),
                              DataCell(SizedBox.shrink()),
                              DataCell(SizedBox.shrink()),
                            ],
                          ),
                        ]
                      : actions.map((action) {
                          final index = actions.indexOf(action);
                          final rowColor = index.isEven
                              ? Colors.white
                              : const Color(0xFFF8FAFC);

                          return DataRow(
                            key: ValueKey(action.code),
                            color: WidgetStatePropertyAll(rowColor),
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: codeWidth,
                                  child: Text(
                                    action.code,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey.shade800,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: actionWidth,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          action.label,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Hapus action',
                                        visualDensity: VisualDensity.compact,
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red.shade700,
                                          size: 20,
                                        ),
                                        onPressed: () => onDelete(action),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(
                                _actionButton(
                                  label: 'START',
                                  time: action.startTime,
                                  enabled: action.startTime == null,
                                  onTap: () => onStart(action),
                                  width: startWidth,
                                ),
                              ),
                              DataCell(
                                _actionButton(
                                  label: 'FINISH',
                                  time: action.finishTime,
                                  enabled: action.startTime != null &&
                                      action.finishTime == null,
                                  onTap: () => onFinish(action),
                                  width: finishWidth,
                                ),
                              ),
                              DataCell(_statusCell(action.status, statusWidth)),
                            ],
                          );
                        }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      height: 50,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Color(0xFF0D47A1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required DateTime? time,
    required bool enabled,
    required VoidCallback onTap,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            height: 44,
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [Colors.blueAccent, Color(0xFF0D47A1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              color: enabled ? null : Colors.blueGrey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: enabled ? onTap : null,
              child: Center(
                child: Text(
                  time != null ? '$label\n${_fmt(time)}' : label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: enabled ? Colors.white : Colors.blueGrey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusCell(String status, double width) {
    final isDone = status == 'SELESAI';
    final isProcess = status == 'PROSES';

    return SizedBox(
      width: width,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isDone
              ? const LinearGradient(
                  colors: [Colors.blueAccent, Color(0xFF0D47A1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isDone
              ? null
              : isProcess
                  ? Colors.blue.shade50
                  : Colors.blueGrey.shade50,
          border: Border.all(
            color: isDone || isProcess
                ? Colors.blue.shade600
                : Colors.blueGrey.shade200,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDone
                ? Colors.white
                : isProcess
                    ? Colors.blue.shade700
                    : Colors.blueGrey.shade500,
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
