// ===================== PAGE =====================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/ng_summary_model.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/page/001-molding/report/recordng.dart';
import 'package:intl/intl.dart';
import 'package:flutter_provider_data/page/menu.dart';

class NgSummaryPage extends StatefulWidget {
  final String title;
  final String idProses;

  const NgSummaryPage({super.key, required this.title, required this.idProses});

  @override
  _NgSummaryPageState createState() => _NgSummaryPageState();
}

class _NgSummaryPageState extends State<NgSummaryPage> {
  late Future<List<NgSummaryModel>> futureNgSummary;
  final TextEditingController _dateRangeController = TextEditingController();
  bool _buttonsEnabled = true;
  DateTime? _startDate;
  DateTime? _endDate;

  final DateFormat formatter = DateFormat("dd MMMM yyyy");

  final Map<String, Color> sliceColors = {};

  @override
  void initState() {
    super.initState();
    futureNgSummary = fetchNgSummary();
    // fetchData();
  }

  void fetchData() {
    futureNgSummary = fetchNgSummary(
      startDate: _startDate,
      endDate: _endDate,
    );
    setState(() {});
  }

  Future<List<NgSummaryModel>> fetchNgSummary({
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

    final uri = Uri.parse('${AppConfig.baseUrl}/api/ng-summary/')
        .replace(queryParameters: queryParams);

    debugPrint('Fetch NG Summary URI: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => NgSummaryModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load NG summary: ${response.statusCode}');
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

  Widget buildPieChart(List<NgSummaryModel> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: List.generate(data.length, (index) {
                final ng = data[index];
                return PieChartSectionData(
                  value: ng.totalQty.toDouble(),
                  title: ng.totalQty.toString(),
                  radius: 300, // perbesar lingkaran
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // angka qty jadi hitam
                  ),
                  color: brightColors[index % brightColors.length],
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 30, // kurangi biar pie lebih besar
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
                  "${data[index].ngName} (${data[index].totalQty})",
                  // pastikan di NgSummaryModel ada field ngName
                  style: const TextStyle(fontSize: 12),
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
      body: Column(children: [
        Container(
          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
          margin: EdgeInsets.only(bottom: 4.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300, // warna garis bawah
                width: 1, // ketebalan garis bawah
              ),
            ),
          ),
          child: OrientationBuilder(
            builder: (context, orientation) {
              final List<Widget> children = [
                Container(
                  decoration: BoxDecoration(
                    gradient: _buttonsEnabled
                        ? LinearGradient(
                            colors: [Colors.indigoAccent, Colors.blue.shade300],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          )
                        : LinearGradient(
                            colors: [Colors.grey, Colors.grey.shade700],
                          ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      navigateWithFade(
                        context,
                        RecordNg(
                          title: 'LIST DATA NG',
                          idProses: widget.idProses,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // penting!
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_sharp, size: 20, color: Colors.white),
                        SizedBox(width: 6),
                        Text('LIST DATA NG',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Container(
                  decoration: BoxDecoration(
                    gradient: _buttonsEnabled
                        ? LinearGradient(
                            colors: [Colors.blue, Colors.blue.shade300],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          )
                        : LinearGradient(
                            colors: [Colors.grey, Colors.grey.shade700],
                          ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ElevatedButton(
                    onPressed: _buttonsEnabled ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // penting!
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_chart, size: 20, color: Colors.white),
                        SizedBox(width: 6),
                        Text('PIE CHART',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Container(
                  decoration: BoxDecoration(
                    gradient: _buttonsEnabled
                        ? LinearGradient(
                            colors: [Colors.blue, Colors.blue.shade300],
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                          )
                        : LinearGradient(
                            colors: [Colors.grey, Colors.grey.shade700],
                          ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ElevatedButton(
                    onPressed: _buttonsEnabled ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // penting!
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_chart_outlined_rounded,
                            size: 20, color: Colors.white),
                        SizedBox(width: 6),
                        Text('BAR CHART',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Container(
                  decoration: BoxDecoration(
                    gradient: _buttonsEnabled
                        ? LinearGradient(
                            colors: [Colors.blue, Colors.blue.shade300],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          )
                        : LinearGradient(
                            colors: [Colors.grey, Colors.grey.shade700],
                          ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ElevatedButton(
                    onPressed: _buttonsEnabled ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // penting!
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_chart_sharp,
                            size: 20, color: Colors.white),
                        SizedBox(width: 6),
                        Text('LINE CHART',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ];

              return orientation == Orientation.portrait
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // ukuran Row sesuaikan child
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: children,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: children,
                    );
            },
          ),
        ),
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
                        fetchData(); // reload data default
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
                fetchData(); // fetch ulang data sesuai tanggal
              });
            }
          },
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0), // padding di dalam Expanded
            child: FutureBuilder<List<NgSummaryModel>>(
              future: futureNgSummary,
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
                      // ===================== SPACE UNTUK TITLE DI BAWAH TEXTFIELD =====================
                      const SizedBox(height: 24),

                      // ===================== PIE CHART TITLE =====================

                      Text(
                        _startDate != null && _endDate != null
                            ? "GRAPH PIE CHART DATA NG FROM ${formatter.format(_startDate!).toUpperCase()} TO  ${formatter.format(_endDate!).toUpperCase()}"
                            : "GRAPH PIE CHART DATA NG (ALL DATA)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===================== PIE CHART BESAR =====================
                      Expanded(
                        child:
                            buildPieChart(data), // panggil fungsi kamu di sini
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        )
      ]),
    );
  }
}
