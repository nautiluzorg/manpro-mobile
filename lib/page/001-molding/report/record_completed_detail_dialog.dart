import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_finish_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:http/http.dart' as http;
// import 'package:google_fonts/google_fonts.dart';

String formatDateTime(String? dateTimeStr) {
  if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
  try {
    final dt = DateTime.parse(dateTimeStr);
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  } catch (e) {
    return dateTimeStr;
  }
}

class RecordCompletedDetailDialog extends StatefulWidget {
  final String recordId;

  const RecordCompletedDetailDialog({super.key, required this.recordId});

  @override
  State<RecordCompletedDetailDialog> createState() =>
      _RecordCompletedDetailDialogState();
}

class _RecordCompletedDetailDialogState
    extends State<RecordCompletedDetailDialog> {
  late Future<RecordFinishDetailModel> _futureRecord;

  Future<RecordFinishDetailModel> fetchRecordCompletedDetail(
      String idRecord) async {
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/recordcompleted-detail/$idRecord/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return RecordFinishDetailModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load record detail');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureRecord = fetchRecordCompletedDetail(widget.recordId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        title: Text(
          'DETAIL RECORD ${widget.recordId}',
          style: const TextStyle(fontSize: 20.0, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30.0),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: FutureBuilder<RecordFinishDetailModel>(
        future: _futureRecord,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load data: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent)));
          } else if (!snapshot.hasData) {
            return const Center(
                child: Text('No data available',
                    style: TextStyle(color: Colors.white70)));
          }

          final record = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // JOB NUMBER Card
                ColorCard(
                  child: Text(
                    'JOB NUMBER ${record.detailsRecord.isNotEmpty ? record.detailsRecord.first.jobnumber : "-"}',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent),
                  ),
                ),

                const SizedBox(height: 5),

                // DETAIL TABLES
                buildDetailTables(record),

                const SizedBox(height: 10),

                // TABLE OPERATOR
                buildOperatorCard(record),

                const SizedBox(height: 10),

                // TABLE MACHINES
                buildMachinesCard(record),

                const SizedBox(height: 10),

                // DETAIL NG
                buildNgCard(record),

                const SizedBox(height: 5),

                // DETAIL DOWNTIME
                buildDowntimeCard(record),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===================== Helper Widget =====================
  Widget ColorCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return Colors.greenAccent;
      case 'pending':
        return Colors.redAccent;
      case 'testing':
        return Colors.orangeAccent;
      case 'available':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  TableRow buildTableHeader(List<String> headers, {Color? color}) {
    return TableRow(
      decoration: BoxDecoration(
          color: color ?? Colors.teal.shade400.withValues(alpha: 0.9)),
      children: headers
          .map((h) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  h,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ))
          .toList(),
    );
  }

  TableRow buildTableRow(List<String> data,
      {bool striped = false, int index = 0}) {
    return TableRow(
      decoration: BoxDecoration(
        color: striped
            ? (index % 2 == 0
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.06))
            : Colors.white.withValues(alpha: 0.02),
      ),
      children: data
          .map((d) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ))
          .toList(),
    );
  }

  // ===================== Detail Tables =====================
  Widget buildDetailTables(RecordFinishDetailModel record) {
    return ColorCard(
      child: Column(
        children: [
          // JOB CODE
          Table(
            border: TableBorder.all(color: Colors.grey.shade700),
            columnWidths: const {
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
              4: FlexColumnWidth()
            },
            children: [
              buildTableHeader([
                'JOB CODE',
                'LOT NUMBER',
                'TOTAL JOB',
                'START TIME',
                'FINISH TIME'
              ], color: Colors.blue.shade700),
              buildTableRow([
                record.batchNumber,
                record.detailsRecord.isNotEmpty
                    ? record.detailsRecord.first.lotnumber
                    : '-',
                record.totalJobnumber,
                formatDateTime(record.startTime),
                formatDateTime(record.finishTime),
              ], striped: true),
            ],
          ),

          const SizedBox(height: 10),

          // BCODE Table
          Table(
            border: TableBorder.all(color: Colors.grey.shade700),
            children: [
              buildTableHeader(
                  ['BCODE', 'DRAWING NO', 'CATEGORY', 'TYPE', 'CUSTOMER'],
                  color: Colors.teal.shade400),
              buildTableRow([
                record.detailsRecord.isNotEmpty
                    ? record.detailsRecord.first.bcode.bcode
                    : '-',
                record.detailsRecord.isNotEmpty
                    ? record.detailsRecord.first.bcode.drawingNumber
                    : '-',
                record.detailsRecord.isNotEmpty
                    ? record.detailsRecord.first.bcode.productCategory
                    : '-',
                record.detailsRecord.isNotEmpty
                    ? record.detailsRecord.first.bcode.productType
                    : '-',
                record.detailsRecord.isNotEmpty
                    ? record.detailsRecord.first.bcode.companyName
                    : '-',
              ], striped: true),
            ],
          ),

          const SizedBox(height: 10),

          // START QTY Table
          Table(
            border: TableBorder.all(color: Colors.grey.shade700),
            children: [
              buildTableHeader([
                'START QTY',
                'PROCESS',
                'RUN STATUS',
                'JOB STATUS',
                'MULTI OPERATOR'
              ], color: Colors.orange.shade300),
              buildTableRow([
                record.detailsRecord.isNotEmpty
                    ? record.detailsRecord.first.startQty.toString()
                    : '-',
                record.proses.nameProses,
                record.runStatus.toUpperCase(),
                record.jobStatus.toUpperCase(),
                record.isMultiOperator ? "YES" : "NO",
              ], striped: true),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== Operator, Machines, NG, Downtime =====================
  Widget buildOperatorCard(RecordFinishDetailModel record) {
    return ColorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OPERATOR',
              style: const TextStyle(
                  color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...record.recordShoots.map((shoot) {
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade100,
                  child: ClipOval(
                    child: Image.network(
                      '${AppConfig.baseUrl}/media/img/employee/${shoot.idEmployeeFinish}.png',
                      fit: BoxFit.cover,
                      width: 34,
                      height: 34,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    shoot.fullName,
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(shoot.shootQty.toString(),
                    style: const TextStyle(color: Colors.cyanAccent)),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget buildMachinesCard(RecordFinishDetailModel record) {
    List<List<String>> machineRows = record.recordMachines.isNotEmpty
        ? record.recordMachines.map((m) => [m.idMc, m.nmMc]).toList()
        : [
            ['-', '-']
          ];

    return ColorCard(
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade700),
        children: [
          buildTableHeader(['ID MACHINE', 'NAME MACHINE'],
              color: Colors.purple.shade400),
          ...machineRows
              .asMap()
              .entries
              .map((e) => buildTableRow(e.value, striped: true, index: e.key)),
        ],
      ),
    );
  }

  Widget buildNgCard(RecordFinishDetailModel record) {
    return ColorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DETAIL NG',
              style: const TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold)),
          Table(
            border: TableBorder.all(color: Colors.grey.shade700),
            children: [
              buildTableHeader(['NG NAME', 'QTY'], color: Colors.red.shade400),
              if (record.recordNgs.isNotEmpty)
                ...record.recordNgs.asMap().entries.map((e) => buildTableRow(
                    [e.value.ngName, e.value.qty.toString()],
                    striped: true, index: e.key))
              else
                buildTableRow(['-', '-']),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDowntimeCard(RecordFinishDetailModel record) {
    return ColorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DOWNTIME',
              style: const TextStyle(
                  color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          Table(
            border: TableBorder.all(color: Colors.grey.shade700),
            children: [
              buildTableHeader(
                  ['REASON', 'START PENDING', 'FINISH PENDING', 'DOWNTIME'],
                  color: Colors.orange.shade300),
              if (record.recordPendings.isNotEmpty)
                ...record.recordPendings
                    .asMap()
                    .entries
                    .map((e) => buildTableRow([
                          e.value.reason.nameReason,
                          formatDateTime(e.value.startPending),
                          formatDateTime(e.value.finishPending),
                          e.value.totalPending.toString(),
                        ], striped: true, index: e.key))
              else
                buildTableRow(['-', '-', '-', '-']),
            ],
          ),
        ],
      ),
    );
  }
}
