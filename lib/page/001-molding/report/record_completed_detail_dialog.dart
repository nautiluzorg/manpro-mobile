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

  const RecordCompletedDetailDialog({Key? key, required this.recordId})
      : super(key: key);

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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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
      decoration:
          BoxDecoration(color: color ?? Colors.teal.shade400.withOpacity(0.9)),
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
                ? Colors.white.withOpacity(0.03)
                : Colors.white.withOpacity(0.06))
            : Colors.white.withOpacity(0.02),
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


























/*
class RecordCompletedDetailDialog extends StatefulWidget {
  final String recordId;

  const RecordCompletedDetailDialog({Key? key, required this.recordId})
      : super(key: key);

  @override
  State<RecordCompletedDetailDialog> createState() =>
      _RecordCompletedDetailDialogState();
}

class _RecordCompletedDetailDialogState
    extends State<RecordCompletedDetailDialog> {
  late Future<RecordFinishDetailModel> _futureRecord;

  @override
  void initState() {
    super.initState();
    _futureRecord = fetchRecordCompletedDetail(widget.recordId);
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        title: Text(
          'DETAIL RECORD ${widget.recordId}',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
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
              child: Text(
                'Failed to load data: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final record = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _jobNumberCard(record),
                const SizedBox(height: 16),
                _detailInfoCard(record),
                const SizedBox(height: 16),
                _operatorCard(record),
                const SizedBox(height: 16),
                _machinesCard(record),
                const SizedBox(height: 16),
                _ngCard(record),
                const SizedBox(height: 16),
                _downtimeCard(record),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===================== CARDS =====================
  Widget _jobNumberCard(RecordFinishDetailModel record) {
    return _glassCard(
      color: Colors.blue.shade700.withValues(alpha: 0.2),
      child: Text(
        'JOB NUMBER ${record.detailsRecord.isNotEmpty ? record.detailsRecord.first.jobnumber : "-"}',
        style: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _detailInfoCard(RecordFinishDetailModel record) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('DETAIL INFORMATION', color: Colors.tealAccent),
          const SizedBox(height: 12),
          _infoRowTriple(
            'Job Code',
            record.batchNumber,
            'Lot Number',
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.lotnumber
                : '-',
            'Total Job',
            record.totalJobnumber,
          ),
          _infoRowTriple(
            'Start Time',
            formatDateTime(record.startTime),
            'Finish Time',
            formatDateTime(record.finishTime),
            'Status',
            record.runStatus.toUpperCase(),
          ),
          _infoRowTriple(
            'Mix Lot',
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.mixLotNo
                : '-',
            'Mold No',
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.moldnumber
                : '-',
            'Mold Cavity',
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.moldcavity.toString()
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _operatorCard(RecordFinishDetailModel record) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('OPERATORS', color: Colors.greenAccent),
          const SizedBox(height: 12),
          ...record.recordShoots.map((shoot) => _employeeTile(
                name: shoot.fullName,
                role: shoot.idEmployeeFinish,
                imageUrl:
                    '${AppConfig.baseUrl}/media/img/employee/${shoot.idEmployeeFinish}.png',
                extra: _statusBadge(record.runStatus),
              )),
          if (record.recordShoots.isEmpty)
            const Center(
                child: Text('-', style: TextStyle(color: Colors.white60))),
        ],
      ),
    );
  }

  Widget _machinesCard(RecordFinishDetailModel record) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('MACHINES', color: Colors.orangeAccent),
          const SizedBox(height: 12),
          ...record.recordMachines.map((m) => _infoRow(m.idMc, m.nmMc)),
          if (record.recordMachines.isEmpty)
            const Center(
                child: Text('-', style: TextStyle(color: Colors.white60))),
        ],
      ),
    );
  }

  Widget _ngCard(RecordFinishDetailModel record) {
    return _glassCard(
      color: Colors.red.shade700.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('DETAIL NG', color: Colors.redAccent),
          const SizedBox(height: 12),
          ...record.recordNgs
              .map((ng) => _infoRow(ng.ngName, ng.qty.toString())),
          if (record.recordNgs.isEmpty)
            const Center(
                child: Text('-', style: TextStyle(color: Colors.white60))),
        ],
      ),
    );
  }

  Widget _downtimeCard(RecordFinishDetailModel record) {
    return _glassCard(
      color: Colors.orange.shade700.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('DOWNTIME', color: Colors.orangeAccent),
          const SizedBox(height: 12),
          ...record.recordPendings.map((p) => _infoRow(
                p.reason.nameReason,
                '${formatDateTime(p.startPending)} - ${formatDateTime(p.finishPending)} (${p.totalPending} min)',
              )),
          if (record.recordPendings.isEmpty)
            const Center(
                child: Text('-', style: TextStyle(color: Colors.white60))),
        ],
      ),
    );
  }

  // ===================== REUSABLE WIDGETS =====================
  Widget _glassCard({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, {Color color = Colors.white}) {
    return Text(
      title,
      style: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w600, color: color),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70),
              )),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowTriple(
      String l1, String v1, String l2, String v2, String l3, String v3) {
    return Row(
      children: [
        Expanded(child: _infoRow(l1, v1)),
        const SizedBox(width: 12),
        Expanded(child: _infoRow(l2, v2)),
        const SizedBox(width: 12),
        Expanded(child: _infoRow(l3, v3)),
      ],
    );
  }

  Widget _employeeTile(
      {required String name,
      required String role,
      required String imageUrl,
      required Widget extra}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(imageUrl,
                width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500))),
          extra,
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _statusColor(String status) {
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
}





class RecordCompletedDetailDialog extends StatefulWidget {
  final String recordId;

  const RecordCompletedDetailDialog({Key? key, required this.recordId})
      : super(key: key);

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
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text(
          'DETAIL RECORD ${widget.recordId}',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
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
                child: Text('Failed to load data: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final record = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // JOB NUMBER Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'JOB NUMBER ${record.detailsRecord.isNotEmpty ? record.detailsRecord.first.jobnumber : "-"}',
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(221, 30, 83, 85)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // 🔹 DETAIL TABLES (JOB CODE, BCODE, START QTY, MIX LOT, TOTAL TIME)
                buildDetailTables(record),

                const SizedBox(height: 10),

                // 🔹 TABLE OPERATOR
                buildOperatorCard(record),

                const SizedBox(height: 10),

                // 🔹 TABLE MACHINES
                buildMachinesCard(record),

                const SizedBox(height: 10),

                // 🔹 DETAIL NG
                buildNgCard(record),

                const SizedBox(height: 5),

                // 🔹 DETAIL DOWNTIME
                buildDowntimeCard(record),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDetailTables(RecordFinishDetailModel record) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(children: [
        // JOB CODE Table
        buildSingleTable(
          headers: [
            'JOB CODE',
            'LOT NUMBER',
            'TOTAL JOB',
            'START TIME',
            'FINISH TIME'
          ],
          data: [
            record.batchNumber,
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.lotnumber
                : '-',
            record.totalJobnumber,
            formatDateTime(record.startTime),
            formatDateTime(record.finishTime),
          ],
        ),

        const SizedBox(height: 10),

        // BCODE Table
        buildSingleTable(
          headers: ['BCODE', 'DRAWING NO', 'CATEGORY', 'TYPE', 'CUSTOMER'],
          data: [
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
          ],
        ),

        const SizedBox(height: 10),

        // START QTY Table
        buildSingleTable(
          headers: [
            'START QTY',
            'PROCESS',
            'RUN STATUS',
            'JOB STATUS',
            'MULTI OPERATOR'
          ],
          data: [
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.startQty.toString()
                : '-',
            record.proses.nameProses,
            record.runStatus.toUpperCase(),
            record.jobStatus.toUpperCase(),
            record.isMultiOperator ? "YES" : "NO"
          ],
        ),

        const SizedBox(height: 10),

        // MIX LOT Table
        buildSingleTable(
          headers: [
            'MIX LOT NUMBER',
            'MOLD NO',
            'MOLD CAVITY',
            'TOTAL SHOOT',
            'ACHIEVED'
          ],
          data: [
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.mixLotNo
                : '-',
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.moldnumber
                : '-',
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.moldcavity.toString()
                : '-',
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.shootQty.toString()
                : '-',
            '-'
          ],
        ),

        const SizedBox(height: 10),

        // TOTAL TIME Table
        buildSingleTableSpecial(
          headers: ['TOTAL TIME', 'CYCLE TIME', 'DOWN TIME', 'NG', 'GOOD'],
          data: [
            record.totalTime.toString(),
            record.cycleTime.toString(),
            record.totalPending.toString(),
            record.totalNg.toString(),
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord.first.finishQty.toString()
                : '0',
          ],
        ),
      ]),
    );
  }

  Table buildSingleTable(
      {required List<String> headers, required List<String> data}) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(180),
        1: FixedColumnWidth(120),
        2: FixedColumnWidth(120),
        3: FixedColumnWidth(180),
        4: FixedColumnWidth(180),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        _buildTableRowHeader(headers, backgroundColor: Colors.blue.shade50),
        _buildTableRowData(data),
      ],
    );
  }

  Table buildSingleTableSpecial(
      {required List<String> headers, required List<String> data}) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(200),
        1: FixedColumnWidth(200),
        2: FixedColumnWidth(200),
        3: FixedColumnWidth(90),
        4: FixedColumnWidth(100),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        _buildTableRowHeaderSpecial(headers),
        _buildTableRowData(data),
      ],
    );
  }

  Widget buildOperatorCard(RecordFinishDetailModel record) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.blue.shade100,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade400]),
            ),
            child: const Text(
              'OPERATOR',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 0.5),
            ),
          ),
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: const [
                Expanded(
                    flex: 3,
                    child: Text('OPERATOR NAME',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blueGrey))),
                Expanded(
                    flex: 2,
                    child: Text('SHOOT QTY',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blueGrey))),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          record.recordShoots.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: record.recordShoots.length,
                  itemBuilder: (context, index) {
                    final shoot = record.recordShoots[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.white
                            : Colors.blue.shade50.withAlpha(51),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
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
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              shoot.shootQty.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: const [
                      Expanded(
                          flex: 3,
                          child: Text('-',
                              style: TextStyle(color: Colors.black54))),
                      Expanded(
                          flex: 2,
                          child: Text('-',
                              style: TextStyle(color: Colors.black54))),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  // 🔹 TABLE MACHINES
  Widget buildMachinesCard(RecordFinishDetailModel record) {
    List<List<String>> machineRows = record.recordMachines.isNotEmpty
        ? record.recordMachines.map((m) {
            return [m.idMc, m.nmMc];
          }).toList()
        : [
            ['-', '-']
          ];

    return GenericTableCard(
      title: 'MACHINES',
      headers: ['ID MACHINE', 'NAME MACHINE'],
      rows: machineRows,
      special: true,
      headerColors: [
        Colors.teal.shade200,
        Colors.teal.shade200,
      ],
      headerTextColors: [
        Colors.white,
        Colors.white,
      ],
    );
  }

  Widget buildNgCard(RecordFinishDetailModel record) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: const Text(
              'DETAIL NG',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2)
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                _buildTableRowHeader(['NG NAME', 'QTY']),
                if (record.recordNgs.isNotEmpty)
                  ...record.recordNgs.map((ng) =>
                      _buildTableRowDataSpecial([ng.ngName, ng.qty.toString()]))
                else
                  _buildTableRowDataSpecial(['-', '-']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDowntimeCard(RecordFinishDetailModel record) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: const Text(
              'DOWNTIME',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(300),
                1: FixedColumnWidth(180),
                2: FixedColumnWidth(180),
                3: FixedColumnWidth(120),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                _buildTableRowHeader(
                    ['REASON', 'START PENDING', 'FINISH PENDING', 'DOWNTIME']),
                if (record.recordPendings.isNotEmpty)
                  ...record.recordPendings
                      .map((pending) => _buildTableRowDataSpecial([
                            pending.reason.nameReason,
                            formatDateTime(pending.startPending),
                            formatDateTime(pending.finishPending),
                            pending.totalPending.toString(),
                          ]))
                else
                  _buildTableRowDataSpecial(['-', '-', '-', '-']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRowHeader(List<String> headers,
      {Color backgroundColor = const Color.fromARGB(255, 197, 196, 196)}) {
    return TableRow(
      decoration: BoxDecoration(color: backgroundColor),
      children: headers
          .map((h) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  h,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ))
          .toList(),
    );
  }

  TableRow _buildTableRowData(List<String> data) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: data
          .map((d) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                ),
              ))
          .toList(),
    );
  }

  TableRow _buildTableRowHeaderSpecial(List<String> headers) {
    return TableRow(
      decoration:
          BoxDecoration(color: const Color.fromARGB(255, 184, 242, 245)),
      children: headers.map((h) {
        String? unit;
        if (h == 'TOTAL TIME' || h == 'CYCLE TIME' || h == 'DOWN TIME') {
          unit = "(Min)";
        } else if (h == 'NG' || h == 'GOOD') {
          unit = "(Pcs)";
        }

        if (unit != null) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  h,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              h,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          );
        }
      }).toList(),
    );
  }

  TableRow _buildTableRowDataSpecial(List<String> data) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: data
          .map((d) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  d,
                  textAlign: TextAlign.left,
                ),
              ))
          .toList(),
    );
  }
}

// 🔹 GENERIC TABLE CARD
class GenericTableCard extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;
  final bool special;
  final List<Color>? headerColors;
  final List<Color>? headerTextColors;

  const GenericTableCard({
    Key? key,
    required this.title,
    required this.headers,
    required this.rows,
    this.special = false,
    this.headerColors,
    this.headerTextColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              color: Colors.teal.shade200,
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {},
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.teal.shade200),
                  children: headers
                      .map((h) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              h,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ))
                      .toList(),
                ),
                ...rows.map((row) => TableRow(
                      decoration:
                          BoxDecoration(color: Colors.white.withAlpha(230)),
                      children: row
                          .map((d) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  d,
                                  textAlign: TextAlign.left,
                                ),
                              ))
                          .toList(),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


*/