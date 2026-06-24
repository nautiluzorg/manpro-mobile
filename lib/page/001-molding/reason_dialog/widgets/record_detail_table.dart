import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_running_detail_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Tabel detail record (JOB NUMBER, BCODE, MACHINE, QTY, dll).
class RecordDetailTable extends StatelessWidget {
  final List<RecordRunningDetailModel> data;

  const RecordDetailTable({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Container(
        color: Colors.grey[90],
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FixedColumnWidth(20),
                          2: FlexColumnWidth(2),
                        },
                        children: [
                          _buildTableRow(
                            label: 'JOB NUMBER',
                            value: data[0].detailsRecord.isNotEmpty
                                ? data[0].detailsRecord[0].jobNumber
                                : '',
                            isBold: true,
                          ),
                          _buildTableRow(
                            label: 'BCODE',
                            value: data[0].detailsRecord.isNotEmpty
                                ? data[0].detailsRecord[0].bcode.bcode
                                : '',
                          ),
                          _buildTableRow(
                            label: 'MACHINE',
                            value: data[0].activeMachine.nmMc,
                          ),
                          _buildTableRow(
                            label: 'QTY',
                            value: data[0].detailsRecord.isNotEmpty
                                ? data[0].detailsRecord[0].startQty.toString()
                                : '',
                          ),
                          _buildTableRow(
                            label: 'QTY SHOOT',
                            value: data[0].detailsRecord.isNotEmpty
                                ? data[0].detailsRecord[0].shootQty.toString()
                                : '',
                          ),
                          _buildTableRow(
                            label: 'START TIME',
                            value: formatDateTime(data[0].startTime.toString()),
                          ),
                          _buildTableRow(
                            label: 'STATUS PROCESS',
                            value: data[0].runStatus.toUpperCase(),
                          ),
                          _buildTableRow(
                            label: 'CONFIRM OPERATOR',
                            valueWidget: Consumer<EmployeeProvider>(
                              builder: (context, empProv, _) {
                                return Text(
                                  empProv.employee.isValid
                                      ? empProv.employee.fullName
                                      : '',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.lightGreen,
                                    fontSize: 16,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow({
    required String label,
    String? value,
    Widget? valueWidget,
    bool isBold = false,
  }) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.blueGrey,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            ':',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.normal,
              color: Colors.blueGrey,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: valueWidget ??
              Text(
                value ?? '',
                style: GoogleFonts.poppins(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: Colors.blueGrey,
                  fontSize: 16,
                ),
              ),
        ),
      ],
    );
  }
}
