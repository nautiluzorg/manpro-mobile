import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_completed_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:http/http.dart' as http;

String formatDateTime(String? dateTimeStr) {
  if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
  try {
    final dt = DateTime.parse(dateTimeStr);
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  } catch (e) {
    return dateTimeStr;
  }
}

class BatchSummaryDetail extends StatefulWidget {
  final String batchNumber;

  const BatchSummaryDetail({Key? key, required this.batchNumber})
      : super(key: key);

  @override
  State<BatchSummaryDetail> createState() => _BatchSummaryDetailState();
}

class _BatchSummaryDetailState extends State<BatchSummaryDetail> {
  late Future<List<RecordCompletedModel>> _futureRecords;

  Future<List<RecordCompletedModel>> fetchRecordCompletedDetail(
      String batchNumber) async {
    final url = Uri.parse(
        '${AppConfig.baseUrl}/api/record-list-completed/?batch_number=$batchNumber');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List results = jsonData['results']; // ambil 'results'
      return results.map((e) => RecordCompletedModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load record detail');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureRecords = fetchRecordCompletedDetail(widget.batchNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text('DETAIL JOBCODE ${widget.batchNumber}',
            style: const TextStyle(fontSize: 20.0, color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30.0),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: FutureBuilder<List<RecordCompletedModel>>(
        future: _futureRecords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final records = snapshot.data!;

          records.sort((a, b) =>
              int.parse(a.lotNumber).compareTo(int.parse(b.lotNumber)));

          final double headingRowHeight = 50;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Stack(
              children: [
                // Gradient di belakang heading
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: headingRowHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // DataTable asli
                DataTable(
                  headingRowHeight: headingRowHeight,
                  headingTextStyle: const TextStyle(color: Colors.white),
                  columns: const [
                    DataColumn(label: Text('JOBNUMBER')),
                    DataColumn(label: Text('LOT')),
                    DataColumn(label: Text('OPERATOR')),
                    DataColumn(label: Text('MACHINE')),
                    DataColumn(label: Text('START QTY')),
                    DataColumn(label: Text('GOOD')),
                    DataColumn(label: Text('NG')),
                    DataColumn(label: Text('TOTAL TIME')),
                    DataColumn(label: Text('DOWNTIME')),
                    DataColumn(label: Text('CYCLETIME')),
                  ],
                  rows: records.map((record) {
                    return DataRow(cells: [
                      DataCell(Text(record.jobNumber.toString())),
                      DataCell(Text(record.lotNumber)),
                      DataCell(Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              '${AppConfig.baseUrl}/media/img/employee/${record.idEmployeeFinish}.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 30),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(record.operatorName),
                        ],
                      )),
                      DataCell(Text(record.machineName)),
                      DataCell(Text(record.startQty.toString())),
                      DataCell(Text(record.good.toString())),
                      DataCell(Text(record.ng.toString())),
                      DataCell(Text(record.totalTime.toString())),
                      DataCell(Text(record.downtime.toString())),
                      DataCell(Text(record.cycleTime.toString())),
                    ]);
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
