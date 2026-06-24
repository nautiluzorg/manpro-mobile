import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_provider_data/page/001-molding/report/recordng.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_provider_data/config/app_config.dart';

class TotalNgChartPage extends StatefulWidget {
  final String title;
  final String idProses;

  const TotalNgChartPage(
      {super.key, required this.title, required this.idProses});

  @override
  State<TotalNgChartPage> createState() => _TotalNgChartPageState();
}

class _TotalNgChartPageState extends State<TotalNgChartPage> {
  List<NgPerEmployee> data = [];
  bool isLoading = true;
  bool _buttonsEnabled = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData({String? startDate, String? endDate}) async {
    setState(() {
      isLoading = true;
    });

    String url = '${AppConfig.baseUrl}/api/record-ng-employee/';
    if (startDate != null && endDate != null) {
      url += '?start_date=$startDate&end_date=$endDate';
    }

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        data = jsonData.map((e) => NgPerEmployee.fromJson(e)).toList();
      } else {
        data = [];
      }
    } catch (e) {
      data = [];
      debugPrint('Error fetching data: $e');
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> barColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
    ];

    final myAppBar = PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
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
            style: const TextStyle(
                color: Colors.white, fontSize: 20.0, fontFamily: "Montserrat"),
          ),
          leading: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      RecordNg(title: widget.title, idProses: widget.idProses),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const curve = Curves.easeIn;
                    var tween =
                        Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(
                      curve: curve,
                    ));
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
          Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade100, Colors.grey.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(0),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 136, 135, 135)
                        .withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // JOB button
                  SizedBox(
                    width: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _buttonsEnabled
                            ? LinearGradient(
                                colors: [
                                  Colors.lightBlue.shade100,
                                  Colors.blue.shade500
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search,
                                size: 20,
                                color: _buttonsEnabled
                                    ? Colors.white
                                    : Colors.black54),
                            const SizedBox(width: 4),
                            Text('JOB',
                                style: TextStyle(
                                    color: _buttonsEnabled
                                        ? Colors.white
                                        : Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Operator button
                  SizedBox(
                    width: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _buttonsEnabled
                            ? LinearGradient(
                                colors: [
                                  Colors.teal.shade100,
                                  Colors.teal.shade400
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search,
                                size: 20,
                                color: _buttonsEnabled
                                    ? Colors.white
                                    : Colors.black54),
                            const SizedBox(width: 4),
                            Text('OPT',
                                style: TextStyle(
                                    color: _buttonsEnabled
                                        ? Colors.white
                                        : Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // REPORT NG button (tidak push ke halaman yang sama)
                  SizedBox(
                    width: 140,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _buttonsEnabled
                            ? LinearGradient(
                                colors: [
                                  Colors.indigo.shade100,
                                  Colors.indigo.shade400
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: ElevatedButton(
                        onPressed: _buttonsEnabled ? () {} : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.find_in_page,
                                size: 20,
                                color: _buttonsEnabled
                                    ? Colors.white
                                    : Colors.black54),
                            const SizedBox(width: 4),
                            Text('REPORT NG',
                                style: TextStyle(
                                    color: _buttonsEnabled
                                        ? Colors.white
                                        : Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceBetween,
                        maxY: data.isNotEmpty
                            ? (data
                                        .map((e) => e.totalNg)
                                        .reduce((a, b) => a > b ? a : b) *
                                    1.2)
                                .toDouble()
                            : 10.0,
                        barGroups: List.generate(data.length, (index) {
                          final ng = data[index];
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: ng.totalNg.toDouble(),
                                color: barColors[index % barColors.length],
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString());
                              },
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (data.isEmpty) return const Text('');
                                final idx =
                                    value.toInt().clamp(0, data.length - 1);
                                return Transform.rotate(
                                  angle: -0.5,
                                  child: Text(data[idx].employeeName,
                                      style: const TextStyle(fontSize: 10)),
                                );
                              },
                              reservedSize: 60,
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () => fetchData(),
      ),
    );
  }
}

class NgPerEmployee {
  final String employeeName;
  final int totalNg;

  NgPerEmployee({required this.employeeName, required this.totalNg});

  factory NgPerEmployee.fromJson(Map<String, dynamic> json) {
    return NgPerEmployee(
      employeeName: json['id_employee_finish__full_name'] ?? 'Unknown',
      totalNg: json['total_ng'] ?? 0,
    );
  }
}
