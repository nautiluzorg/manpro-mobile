import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionTableView extends StatelessWidget {
  const ActionTableView({
    super.key,
    required this.heightBody,
    required this.screenWidth,
    required this.actions,
    required this.onDelete,
  });

  final double heightBody;
  final double screenWidth;
  final List<String> actions;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: heightBody * 0.14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF1),
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth,
              minHeight: heightBody * 0.14 - 4,
            ),
            child: DataTable(
              columnSpacing: 0.2,
              horizontalMargin: 0,
              headingRowHeight: 50,
              dataRowMinHeight: 45,
              headingRowColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              columns: [
                DataColumn(label: _headerCell('NO', screenWidth * 0.12)),
                DataColumn(label: _headerCell('ACTION', screenWidth * 0.68)),
                DataColumn(label: _headerCell('DELETE', screenWidth * 0.20)),
              ],
              rows: [
                ...actions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final action = entry.value;
                  final rowColor =
                      index.isEven ? Colors.white : const Color(0xFFEFFAF1);

                  return DataRow(
                    key: ValueKey(action),
                    color: WidgetStatePropertyAll(rowColor),
                    cells: [
                      DataCell(Center(child: Text('${index + 1}'))),
                      DataCell(
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            action,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            onPressed: () => onDelete(action),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                if (actions.isEmpty)
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
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent.shade700, Colors.green.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
