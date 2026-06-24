import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/downtime_summary_model.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:intl/intl.dart';
import 'package:flutter_provider_data/page/menu.dart';

class DowntimeSummaryPage extends StatefulWidget {
  final String title;
  final String idProses;

  const DowntimeSummaryPage(
      {super.key, required this.title, required this.idProses});

  @override
  _DowntimeSummaryPageState createState() => _DowntimeSummaryPageState();
}

class _DowntimeSummaryPageState extends State<DowntimeSummaryPage> {
  late Future<List<DowntimeSummaryModel>> futureSummary;
  // final TextEditingController _dateRangeController = TextEditingController();
  // bool _buttonsEnabled = true;
  DateTime? _startDate;
  DateTime? _endDate;

  final DateFormat formatter = DateFormat("dd MMMM yyyy");

  String formatMinutesToHours(int minutes) {
    final hours = minutes ~/ 60; // bagi bulat
    final mins = minutes % 60; // sisa menit
    return "${hours}h ${mins}m";
  }

  @override
  void initState() {
    super.initState();
    futureSummary = fetchSummary();
  }

  void fetchData() {
    futureSummary = fetchSummary(
      startDate: _startDate,
      endDate: _endDate,
    );
    setState(() {});
  }

  Future<List<DowntimeSummaryModel>> fetchSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Map<String, String> queryParams = {};

    if (startDate != null) {
      queryParams['start_date'] =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null) {
      queryParams['end_date'] =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/api/pending-summary/')
        .replace(queryParameters: queryParams);

    debugPrint('Fetch Downtime Summary URI: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData
          .map((item) => DowntimeSummaryModel.fromJson(item))
          .toList();
    } else {
      throw Exception(
          'Failed to load downtime summary: ${response.statusCode}');
    }
  }

  // ===================== RANDOM BRIGHT COLOR =====================

  List<Color> brightColors = [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.yellowAccent,
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
    Colors.amberAccent,
    Colors.deepOrangeAccent,
    Colors.lightGreenAccent,
    Colors.lightBlueAccent,
    Colors.limeAccent,
    Colors.indigoAccent,
    Colors.deepPurpleAccent,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
    Colors.green,
    Colors.blue,
  ];

  Widget buildPieChart(List<DowntimeSummaryModel> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: List.generate(data.length, (index) {
                final item = data[index];
                return PieChartSectionData(
                  value: item.totalPending.toDouble(),
                  title: formatMinutesToHours(item.totalPending),

                  radius: 300, // perbesar lingkaran
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900, // angka jadi hitam
                  ),
                  color: brightColors[index % brightColors.length],
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),

        const SizedBox(height: 200),

        // ===================== LEGEND =====================
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(data.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: brightColors[index % brightColors.length],
                    shape: BoxShape.rectangle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${data[index].reasonName} "
                  "(TOTAL: ${formatMinutesToHours(data[index].totalPending)}, CASES: ${data[index].totalCase})",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⬇️ aku biarkan AppBar + Button row sama seperti code kamu
    // cuma ganti futureNgSummary → futureSummary
    final myAppBar = PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
                color: Colors.white, fontSize: 20.0, fontFamily: "Montserrat"),
          ),
          leading: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      Menu(kode: widget.idProses, proses: "MOULDING"),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const curve = Curves.easeIn;
                    var tween = Tween<double>(begin: 0.0, end: 1.0)
                        .chain(CurveTween(curve: curve));
                    var opacityAnimation = animation.drive(tween);

                    return FadeTransition(
                      opacity: opacityAnimation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
    return Scaffold(
      appBar: myAppBar,
      body: Column(
        children: [
          // ===================== Date Picker =====================
/*
          TextField(
            controller: _dateRangeController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'SELECT DATE RANGE',
              prefixIcon: const Icon(Icons.calendar_month_outlined),
              suffixIcon: _dateRangeController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                          _dateRangeController.clear();
                          fetchData();
                        });
                      },
                    )
                  : null,
            ),
            onTap: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                currentDate: DateTime.now(),
                saveText: 'Select',
              );

              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = picked.end;
                  _dateRangeController.text =
                      '${picked.start.day.toString().padLeft(2, '0')}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.year} TO '
                      '${picked.end.day.toString().padLeft(2, '0')}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.year}';
                  fetchData();
                });
              }
            },
          ),

          */
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<DowntimeSummaryModel>>(
                future: futureSummary,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  } else {
                    final data = snapshot.data!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          _startDate != null && _endDate != null
                              ? "GRAPH PIE CHART DOWNTIME FROM ${formatter.format(_startDate!).toUpperCase()} TO ${formatter.format(_endDate!).toUpperCase()}"
                              : "GRAPH PIE CHART DOWNTIME (ALL DATA)",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: buildPieChart(data)),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
