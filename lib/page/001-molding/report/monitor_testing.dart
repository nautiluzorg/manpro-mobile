import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
// import 'package:flutter_provider_data/page/001-molding/menu_sub_testing.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/page/menu.dart';

class MonitorTesting extends StatefulWidget {
  final String title;
  final String idProses;

  const MonitorTesting({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<MonitorTesting> createState() => _MonitorTestingState();
}

class _MonitorTestingState extends State<MonitorTesting> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<TestingProvider>().fetchOnProgressTesting();
    });
  }

  @override
  Widget build(BuildContext context) {
    final myAppBar = customSubAppBar(
      context: context,
      title: 'RECORD PROSES MOLDING',
      kode: widget.idProses,
      proses: "MOULDING",
      navigateToBuilder: (kode, proses) => Menu(kode: kode, proses: proses),
    );

/*
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
            'LIST MOLDING TESTING',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => MenuSubTesting(
                    title: widget.title,
                    idProses: widget.idProses,
                  ),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
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
*/
    return Scaffold(
      appBar: myAppBar,
      body: Column(
        children: [
          _buildTopActionBar(context),
          Expanded(
            child: Consumer<TestingProvider>(
              builder: (context, provider, _) {
                if (provider.isOnProgressLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.onProgressError != null) {
                  return Center(
                    child: Text(
                      provider.onProgressError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final data = provider.onProgressTesting;

                if (data == null || data.results.isEmpty) {
                  return const Center(child: Text("No data available."));
                }

                final records = data.results;

                return HorizontalDataTable(
                  leftHandSideColumnWidth: 260,
                  rightHandSideColumnWidth: 1060,
                  isFixedHeader: true,
                  headerWidgets: _buildHeaders(),
                  leftSideItemBuilder: (context, index) =>
                      _buildLeftRow(records, index),
                  rightSideItemBuilder: (context, index) =>
                      _buildRightRow(records, index),
                  itemCount: records.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI PARTS =================

  Widget _buildTopActionBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            child: Row(
              children: const [
                Icon(Icons.search_sharp),
                SizedBox(width: 8),
                Text('JOBNUMBER'),
              ],
            ),
          ),
          const SizedBox(width: 20),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            child: Row(
              children: const [
                Icon(Icons.search_sharp),
                SizedBox(width: 8),
                Text('TECHNICIAN'),
              ],
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade800,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30), // Stadium look
            ),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide.none, // border sudah diganti gradient
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'BACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildHeaders() {
    return [
      _buildHeaderContainer(
        width: 260,
        child: Row(
          children: const [
            SizedBox(
              width: 60,
              child: Center(
                child: Text(
                  "NO",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10), // space icon
            Expanded(
              child: Text(
                "JOBNUMBER",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      buildHeader("TECHNICIAN", 220),
      buildHeader("MACHINE", 120),
      buildHeader("LOT NO", 100),
      buildHeader("MOLD NO", 100),
      buildHeader("QTY TEST", 120),
      buildHeader("START TIME", 220),
      buildHeader("DRAW NO", 160),
    ];
  }

  Widget _buildHeaderContainer({required double width, required Widget child}) {
    return Container(
      width: width,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigoAccent, Colors.indigo.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: child,
    );
  }

  Widget _buildLeftRow(List records, int index) {
    final record = records[index];
    final rowColor = index % 2 == 0 ? Colors.grey.shade100 : Colors.white;

    return Container(
      width: 260,
      height: 55,
      color: rowColor,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.orange.shade400,
                Colors.orange.shade800,
              ],
            ).createShader(bounds),
            child: const Icon(
              Icons.label_important,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 4),

          /// JOBNUMBER fleksibel
          Expanded(
            child: Text(
              record.details.isNotEmpty ? record.details.first.jobnumber : '-',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightRow(List records, int index) {
    final record = records[index];
    final rowColor = index % 2 == 0 ? Colors.grey.shade100 : Colors.white;

    final photoUrl =
        "${AppConfig.baseUrl}/media/img/employee/${record.employee.idEmployee}.png";

    return Container(
      color: rowColor,
      height: 55,
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    photoUrl,
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 35,
                      height: 35,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.employee.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 62, 134, 175),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          cellText(record.machine.nmMc, 120),
          cellText(record.details.first.lotnumber.toString(), 100),
          cellText(record.details.first.moldnumber.toString(), 100),
          cellText(record.details.first.moldcavity.toString(), 120),
          cellText(formatDateTime(record.startTime ?? '-'), 220),
          cellText(record.details.first.drawingNumber.toString(), 160),
        ],
      ),
    );
  }

  Widget buildHeader(String title, double width) {
    return Container(
      width: width,
      height: 55,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigoAccent, Colors.indigo.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget cellText(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}




/*
class MonitorTesting extends StatefulWidget {
  final String title;
  final String idProses;

  const MonitorTesting({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<MonitorTesting> createState() => _MonitorTestingState();
}

class _MonitorTestingState extends State<MonitorTesting> {
  late Future<MonitorTestingModel> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = fetchRecords();
  }

  Future<MonitorTestingModel> fetchRecords() async {
    final url = "${AppConfig.baseUrl}/api/onprogress-testing/";
    debugPrint("Fetching data from: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return MonitorTestingModel.fromJson(body);
    } else {
      throw Exception("Failed to fetch data (status ${response.statusCode})");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Membuat AppBar dengan gradasi
    final myAppBar = PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight), // Ukuran AppBar
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade800], // Gradasi warna
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          title: Text(
            'LIST MOLDING TESTING',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.w600, // bisa bold atau semi-bold
            ),
          ),

          leading: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MenuSubTesting(
                          title: widget.title, idProses: widget.idProses),
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
          backgroundColor:
              Colors.transparent, // Menjadikan background AppBar transparan
        ),
      ),
    );

    return Scaffold(
      appBar: myAppBar,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.only(bottom: 8.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search_sharp),
                        SizedBox(width: 8),
                        Text('JOBNUMBER'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.person_search),
                        SizedBox(width: 8),
                        Text('TECHNICIAN'),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // ✅ Tombol STOP aktif hanya jika ada checkbox dicentang
                  const SizedBox(width: 20),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => MenuSubTesting(
                              title: widget.title, idProses: widget.idProses),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 800),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      side: BorderSide(color: Colors.blue.shade700),
                      shape: const StadiumBorder(),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_back_ios_new, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'BACK',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
        ),
        FutureBuilder<MonitorTestingModel>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
              return const Center(child: Text("No data available."));
            }

            final records = snapshot.data!.results;

            return Expanded(
              child: HorizontalDataTable(
                leftHandSideColumnWidth: 320, // lebar gabungan No + JOBNUMBER
                rightHandSideColumnWidth: 1060,
                isFixedHeader: true,

                // ===== HEADER =====
                headerWidgets: [
                  // Header kiri (No + JOBNUMBER)
                  Container(
                    width: 320,
                    height: 55,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(
                          width: 80,
                          child: Center(
                            child: Text(
                              "NO",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: Text(
                            "JOBNUMBER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Header kanan

                  buildHeader("TECHNICIAN", 240),
                  buildHeader("MACHINE", 120),
                  buildHeader("LOT", 100),
                  buildHeader("MOLD", 100),
                  buildHeader("CAVITY", 120),
                  buildHeader("START TIME", 220),
                  buildHeader("DRAW NO", 160),
                ],
                // ===== LEFT SIDE =====
                leftSideItemBuilder: (context, index) {
                  final record = records[index];
                  final rowColor =
                      index % 2 == 0 ? Colors.grey.shade100 : Colors.white;

                  return Container(
                    width: 320,
                    height: 55,
                    color: rowColor,
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          alignment: Alignment.center,
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.orange.shade400,
                              Colors.orange.shade800
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                          child: const Icon(
                            Icons.label_important,
                            color: Colors
                                .white, // warna ini akan digantikan oleh gradient
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 200,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            record.details.isNotEmpty
                                ? record.details.first.jobnumber
                                : '-',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },

                // ===== RIGHT SIDE =====
                rightSideItemBuilder: (context, index) {
                  final record = records[index];
                  final rowColor =
                      index % 2 == 0 ? Colors.grey.shade100 : Colors.white;

                  // Path foto employee
                  final photoUrl =
                      "${AppConfig.baseUrl}/media/img/employee/${record.employee.idEmployee}.png";

                  return Container(
                    color: rowColor,
                    height: 55,
                    child: Row(
                      children: [
                        // TECHNICIAN dengan foto
                        Container(
                          width: 240,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  photoUrl,
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 35,
                                    height: 35,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.person, size: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  record.employee.fullName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 62, 134, 175),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // MACHINE
                        cellText(record.machine.nmMc, 120),
                        cellText(
                            record.details.first.lotnumber.toString(), 100),
                        cellText(
                            record.details.first.moldnumber.toString(), 100),
                        cellText(
                            record.details.first.moldcavity.toString(), 120),

                        cellText(formatDateTime(record.startTime ?? '-'), 220),

                        cellText(
                            record.details.first.drawingNumber.toString(), 160),
                      ],
                    ),
                  );
                },

                itemCount: records.length,
              ),
            );
          },
        )
      ]),
    );
  }

  Widget buildHeader(String title, double width) {
    return Container(
      width: width,
      height: 55,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget cellText(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

*/