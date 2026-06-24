import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';

class RecordMachineInfoTable extends StatelessWidget {
  const RecordMachineInfoTable({
    super.key,
    required this.heightBody,
    required this.widthApp,
    required this.isTablet,
  });

  final double heightBody;
  final double widthApp;
  final bool isTablet;

  TableRow _buildTableRow(
    String label,
    String value,
    BoxConstraints constraints,
    bool isTablet,
    Color rowColor,
  ) {
    return TableRow(
      decoration: BoxDecoration(color: rowColor),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: isTablet
                  ? constraints.maxWidth * 0.022
                  : constraints.maxWidth * 0.03,
              color: Colors.blue.shade900,
            ),
            maxLines: 1,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
          child: Text(
            ': $value',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: isTablet
                  ? constraints.maxWidth * 0.022
                  : constraints.maxWidth * 0.03,
              color: Colors.grey.shade800,
            ),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthApp,
      height: heightBody * 0.2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Consumer2<MachineProvider, JobNumberProvider>(
            builder: (context, machineProvider, jobProvider, child) {
              final machineData = machineProvider.machine;

              final List<List<String>> dataRows = [
                ['MACHINE', machineData.nmMc],
                ['MACHINE AREA', machineData.areaMc],
                ['CUSTOMER', jobProvider.customer],
                ['MOLD CAVITY', jobProvider.cavity],
                ['TOTAL SHOT', jobProvider.totalShoot.toString()],
                ['QTY LOT', jobProvider.qtyLot],
              ];

              return Container(
                width: constraints.maxWidth,
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    border: TableBorder(
                      bottom: const BorderSide(color: Colors.grey, width: 1.0),
                      horizontalInside:
                          const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    columnWidths: {
                      0: FlexColumnWidth(constraints.maxWidth * 0.4),
                      1: FlexColumnWidth(constraints.maxWidth * 0.6),
                    },
                    children: List.generate(dataRows.length, (index) {
                      final rowColor =
                          index % 2 == 0 ? Colors.grey[200]! : Colors.white;
                      return _buildTableRow(
                        dataRows[index][0],
                        dataRows[index][1],
                        constraints,
                        isTablet,
                        rowColor,
                      );
                    }),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
