import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:flutter_provider_data/provider/jobnumber_provider.dart';

import 'package:flutter_provider_data/provider/ng_provider.dart';

class NgTableView extends StatelessWidget {
  const NgTableView({
    super.key,
    required this.heightBody,
    required this.screenWidth,
  });

  final double heightBody;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: double.infinity,
      height: heightBody * 0.15,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Hanya untuk tablet (layar lebar)
          if (constraints.maxWidth <= 600) {
            return const SizedBox.shrink();
          }

          return Container(
            width: double.infinity,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4)],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Stack(
                    children: [
                      // Background gradient untuk header
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blueAccent,
                                Colors.blue.shade900,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Consumer<NGProvider>(
                          builder: (context, ngProvider, _) {
                            final jobProvider = Provider.of<JobNumberProvider>(
                              context,
                              listen: false,
                            );

                            final ngTableData = ngProvider.ngTableData;

                            return DataTable(
                              columnSpacing: 0.2,
                              horizontalMargin: 0,
                              headingRowHeight: 50,
                              dataRowMinHeight: 45,
                              headingRowColor: const WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                              columns: [
                                DataColumn(
                                  label: Container(
                                    width: screenWidth * 0.05,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'NO',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    width: screenWidth * 0.4,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'NG NAME',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    width: screenWidth * 0.3,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'DRAW NO',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    width: screenWidth * 0.1,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'QTY',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    width: screenWidth * 0.1,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'DELETE',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              rows: ngTableData.asMap().entries.map((entry) {
                                final index = entry.key;
                                final data = entry.value;

                                final rowColor = (index % 2 == 0)
                                    ? Colors.white
                                    : const Color(0xFFEFF3FF);

                                return DataRow(
                                  key: ValueKey(data['id_ng']),
                                  color: WidgetStatePropertyAll(rowColor),
                                  cells: [
                                    DataCell(
                                      Center(
                                        child: Text('${index + 1}'),
                                      ),
                                    ),
                                    DataCell(
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Text(
                                            data['ng_name'] ?? 'Unknown',
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Consumer<JobNumberProvider>(
                                          builder: (context, jobProvider, _) {
                                            return Text(jobProvider.drawNumber);
                                          },
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text('${data['qty'] ?? 0}'),
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
                                          onPressed: () {
                                            ngProvider.deleteNG(
                                              data['id_ng'],
                                              jobProvider,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
