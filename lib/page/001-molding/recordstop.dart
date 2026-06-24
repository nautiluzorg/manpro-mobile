import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_pending_detail_model.dart';
import 'package:flutter_provider_data/model/record_pending_model.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/page/001-molding/recordstopmanage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/page_transition_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordStop extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordStop({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  _RecordStopState createState() => _RecordStopState();
}

class _RecordStopState extends State<RecordStop> {
  List<RecordPendingModel> _allPendingList = [];
  List<RecordPendingModel> _filteredList = [];
  String _scannedJobNumber = '';
  String _scannedEmployeeFinishId = '';
  bool get _isFilterActive =>
      _scannedJobNumber.isNotEmpty || _scannedEmployeeFinishId.isNotEmpty;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      List<RecordPendingModel> fetchedList =
          await fetchPendingList(widget.idProses);
      setState(() {
        _allPendingList = fetchedList;
        _filteredList = fetchedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterList() {
    setState(() {
      _filteredList = _allPendingList.where((item) {
        final jobMatch = _scannedJobNumber.isEmpty ||
            (item.jobnumber ?? '').toLowerCase() ==
                _scannedJobNumber.toLowerCase();
        final nikMatch = _scannedEmployeeFinishId.isEmpty ||
            item.idEmployee.toLowerCase() == // ← ganti di sini
                _scannedEmployeeFinishId.toLowerCase();
        return jobMatch && nikMatch;
      }).toList();
    });
  }

  Future<void> scanAndFilterJobNumber() async {
    try {
      // 📷 Step 1: Scan pakai MobileScannerPage
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration:
              const Duration(milliseconds: 300), // pop halus
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // 📌 Step 2: Validasi format QRCode (ubah regex sesuai kebutuhan)
      if (!RegExp(r'^[a-zA-Z0-9]{9}[0-9]{10}[0-9]{5}$').hasMatch(getcode)) {
        CustomSnackbar.show(
          context,
          "Invalid QR Code format.",
          isSuccess: false,
        );

        return;
      }

      // 🔹 Ambil 10 karakter dari index ke-9
      String joblot = getcode.substring(9, 19).trim();

      // ✅ Step 3: Update state dan filter list
      if (!mounted) return;
      setState(() {
        _scannedJobNumber = joblot;
        _filterList();
      });
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Error scanning: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> scanAndFilterEmployee() async {
    try {
      // 📷 Step 1: Scan pakai MobileScannerPage
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration:
              const Duration(milliseconds: 300), // pop halus
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // 📌 Step 2: Validasi QRCode Employee (8 digit)
      if (getcode.length != 8) {
        CustomSnackbar.show(
          context,
          "Yang discan bukan ID Employee",
          isSuccess: false,
        );

        return;
      }

      // ✅ Step 3: Update state dan filter list
      if (!mounted) return;
      setState(() {
        _scannedEmployeeFinishId = getcode;
        _filterList();
      });
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Error scanning operator: $e",
        isSuccess: false,
      );
    }
  }

  Future<List<RecordPendingModel>> fetchPendingList(String idProses) async {
    final url = Uri.parse(
        '${AppConfig.baseUrl}/api/record-pending-list/?status_pending=open&id_proses=$idProses');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((jsonItem) => RecordPendingModel.fromJson(jsonItem))
            .toList();
      } else {
        throw Exception(
            'Failed to load pending list (status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching pending list: $e');
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString)
          .toLocal(); // Parse UTC time and convert to local time

      // Format the DateTime to local Japan Standard Time (JST)
      return DateFormat('yyyy-MM-dd HH:mm')
          .format(dateTime); // Format to desired string format
    } catch (e) {
      return dateTimeString; // Return the original string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    // double widthApp = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(child: Text('Error: $_errorMessage'));
    }

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
            'MOLDING STOP',
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
          backgroundColor:
              Colors.transparent, // Menjadikan background AppBar transparan
        ),
      ),
    );

    // double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    return Scaffold(
        appBar: myAppBar,
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
                padding: const EdgeInsets.only(
                    bottom: 8.0), // Tambah padding bawah di sini
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed:
                            _isFilterActive ? null : scanAndFilterJobNumber,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.search_sharp),
                            SizedBox(width: 8),
                            Text('JOBNUMBER'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      OutlinedButton(
                        onPressed:
                            _isFilterActive ? null : scanAndFilterEmployee,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.person_search),
                            SizedBox(width: 8),
                            Text('OPERATOR'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      if (_scannedJobNumber.isNotEmpty ||
                          _scannedEmployeeFinishId.isNotEmpty)
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _scannedJobNumber = '';
                              _scannedEmployeeFinishId = '';
                              _filteredList = _allPendingList;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: BorderSide.none,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade400,
                                  Colors.red.shade800
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.clear, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'CLEAR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const Spacer(), // Spacer dorong widget selanjutnya ke kanan paling ujung

                      const SizedBox(width: 20),

                      OutlinedButton(
                        onPressed: () {
                          PageTransitionHelper.navigateReplaceWithTransition(
                            context,
                            RecordStopManage(
                                title: "MANAGE MOLDING STOP",
                                idProses: widget.idProses),
                            type: PageTransitionType.fade,
                            duration: 800,
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.list_alt),
                            SizedBox(width: 8),
                            Text('MANAGE'),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      Text(
                        'TOTAL DATA: ${_filteredList.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                )),
          ),
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Text(
                      'MOLDING STOP TIDAK ADA.',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      RecordPendingModel pending = _filteredList[index];

                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.black.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // --- HEADER GRADIENT ---
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.indigo.shade400,
                                      Colors.indigo.shade800
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      pending.idRecord,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      pending.nameProses,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      pending.bcode,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Flexible(
                                      child: Text(
                                        pending.productType,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // --- AREA OPERATOR & TABLE ---
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // FOTO OPERATOR
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.20,
                                      child: Column(
                                        children: [
                                          // Lingkaran foto dengan glow
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.18,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.18,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: RadialGradient(
                                                    colors: [
                                                      Colors.grey
                                                          .withOpacity(0.4),
                                                      Colors.white
                                                          .withOpacity(0.1),
                                                    ],
                                                    stops: const [0.5, 1.0],
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      spreadRadius: 4,
                                                      blurRadius: 14,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: ClipOval(
                                                  child: Image.network(
                                                    "${AppConfig.baseUrl}/media/img/employee/${pending.idEmployee}.png",
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.16,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.16,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __,
                                                            ___) =>
                                                        const Icon(Icons.person,
                                                            size: 70,
                                                            color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            pending.employeeName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            pending.nrp,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            pending.section.toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            pending.division,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // TABLE INFORMASI
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(4),
                                              1: FlexColumnWidth(6),
                                            },
                                            defaultVerticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            children: [
                                              for (int i = 0; i < 7; i++)
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: i.isEven
                                                        ? Colors.grey.shade200
                                                        : Colors.white,
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                        [
                                                          'JOB NUMBER',
                                                          'DRAW NO',
                                                          'MACHINE',
                                                          'QTY',
                                                          'SHOOT QTY',
                                                          'START TIME',
                                                          'STATUS'
                                                        ][i],
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight: i == 0
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                        [
                                                          ": ${pending.jobnumber}",
                                                          ": ${pending.drawingNumber}",
                                                          ": ${pending.machineName}",
                                                          ": ${pending.qty}",
                                                          ": ${pending.qty}",
                                                          ": ${_formatDateTime(pending.startPending)}",
                                                          ": ${pending.status.toUpperCase()}",
                                                        ][i],
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 15),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // BUTTON CONTINUE
                                          Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue.shade600,
                                                  Colors.blue.shade400
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                            child: ElevatedButton.icon(
                                              icon: const Icon(Icons.play_arrow,
                                                  size: 30),
                                              label: Text(
                                                "CONTINUE",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              onPressed: () {
                                                _showFullScreenDialog(
                                                    context,
                                                    pending.idPending
                                                        .toString(),
                                                    pending.idReason.toString(),
                                                    _formatDateTime);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),
                              // BOTTOM LINE
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      /*
                      Card(
                        elevation: 4,
                        child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child:
                                Column(children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          pending.idRecord,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          pending.nameProses,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          pending.bcode,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          pending.drawingNumber,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          pending.productType,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Image Section
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                // color: Colors.amber[50],
                                                width: double
                                                    .infinity, // Lebar penuh untuk container
                                                height: 120.0,

                                                child: Center(
                                                  child: LayoutBuilder(
                                                    builder:
                                                        (context, constraints) {
                                                      // Menghitung ukuran gambar berdasarkan persentase lebar layar
                                                      double imageWidth =
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.16; // 30% dari lebar layar
                                                      double imageHeight =
                                                          imageWidth; // Rasio gambar 1:1

                                                      return ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        child: Image.network(
                                                          "${AppConfig.baseUrl}/media/img/employee/${pending.idEmployee}.png",
                                                          width: imageWidth,
                                                          height: imageHeight,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                pending.employeeName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                pending.nrp,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                pending.section.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                pending.division,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Text Section
                                        Expanded(
                                          flex: 7,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  // Bagian kiri untuk Table
                                                  Expanded(
                                                    // flex: 7,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Table(
                                                        columnWidths: const {
                                                          0: FlexColumnWidth(
                                                              2), // Kolom pertama
                                                          1: FixedColumnWidth(
                                                              25), // Kolom untuk ":"
                                                          2: FlexColumnWidth(
                                                              3), // Kolom kedua
                                                        },
                                                        children: [
                                                          TableRow(
                                                            decoration: const BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        color: Colors
                                                                            .grey))),
                                                            children: [
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(
                                                                    'JOB NUMBER',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(':',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        6.0),
                                                                child: Text(
                                                                    pending
                                                                        .jobnumber
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                            ],
                                                          ),
                                                          TableRow(
                                                            decoration: const BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        color: Colors
                                                                            .grey))),
                                                            children: [
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(
                                                                    'DRAW NO',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.normal)),
                                                              ),
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(':',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        6.0),
                                                                child: Text(
                                                                    pending
                                                                        .drawingNumber,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.normal)),
                                                              ),
                                                            ],
                                                          ),
                                                          TableRow(
                                                            decoration: const BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        color: Colors
                                                                            .grey))),
                                                            children: [
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(
                                                                    'MACHINE',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(':',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        6.0),
                                                                child: Text(
                                                                    pending
                                                                        .machineName
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                            ],
                                                          ),
                                                          TableRow(
                                                            decoration: const BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        color: Colors
                                                                            .grey))),
                                                            children: [
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(
                                                                    'PENDING TIME',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(':',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        6.0),
                                                                child: Text(
                                                                    _formatDateTime(
                                                                        pending
                                                                            .startPending),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                            ],
                                                          ),
                                                          TableRow(
                                                            decoration: const BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        color: Colors
                                                                            .grey))),
                                                            children: [
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(
                                                                    'REASON',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(':',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        6.0),
                                                                child: Text(
                                                                    pending
                                                                        .reason,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                            ],
                                                          ),
                                                          TableRow(
                                                            decoration: const BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        color: Colors
                                                                            .grey))),
                                                            children: [
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(
                                                                    'QTY',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(':',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        6.0),
                                                                child: Text(
                                                                    pending.qty
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                            ],
                                                          ),
                                                          TableRow(
                                                            decoration: const BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        color: Colors
                                                                            .grey))),
                                                            children: [
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(
                                                                    'START TIME',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            6.0),
                                                                child: Text(':',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        6.0),
                                                                child: Text(
                                                                    _formatDateTime(
                                                                        pending
                                                                            .startPending), //disini ya waktu nya **************************************************************************************************************
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // Garis pemisah

                                                  // Bagian kanan untuk ElevatedButton
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        //Sampai sini ya *****
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue,
                                            Colors.blue.shade800
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: ElevatedButton.icon(
                                        icon: Icon(Icons.play_arrow, size: 30),
                                        label: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  12.0), // Tambah padding horizontal
                                          child: Text(
                                            "CONTINUE",
                                            style: TextStyle(fontSize: 25),
                                          ),
                                        ),
                                        onPressed: () {
                                          _showFullScreenDialog(
                                            context,
                                            pending.idPending.toString(),
                                            pending.idReason.toString(),
                                            _formatDateTime,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.0, vertical: 15.0),
                                        ),
                                      ),
                                    )
                                  ])
                                
                                
                               
                                
                                 










                                  ),
                      );

                      */
                    },
                  ),
          ),
        ])

//Sampai sini ya

        );
  }

  void _showFullScreenDialog(
    BuildContext context,
    String idPending,
    String idReason,
    String Function(String) formatDateTime,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // Tentukan target dialog berdasarkan idReason
          late final Widget targetDialog;

          if (idReason == '03') {
            targetDialog = ChangeOperatorDialog(
              idPending: idPending,
              formatDateTime: formatDateTime,
            );
          } else if (idReason == '06') {
            targetDialog = ChangeMachineDialog(
              idPending: idPending,
              formatDateTime: formatDateTime,
            );
          } else {
            targetDialog = NumBlockKeyboardDialog(
              idPending: idPending,
              formatDateTime: formatDateTime,
            );
          }

          return Dialog.fullscreen(
            backgroundColor: Colors.transparent,
            child: FadeTransition(
              opacity: animation,
              child: targetDialog,
            ),
          );
        },
        transitionDuration: const Duration(seconds: 1),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

///DARI SINI DI ULIK LAGI YA****************************

class NumBlockKeyboardDialog extends StatefulWidget {
  final String idPending;
  final String Function(String) formatDateTime;
  const NumBlockKeyboardDialog(
      {Key? key, required this.idPending, required this.formatDateTime})
      : super(key: key);

  @override
  _NumBlockKeyboardDialogState createState() => _NumBlockKeyboardDialogState();
}

class _NumBlockKeyboardDialogState extends State<NumBlockKeyboardDialog> {
  // Map<String, dynamic>? recordData;
  late Future<List<RecordPendingModel>> recordDetail;
  late String getCodeEmployee;
  late String idEmployee;
  String employeeName = "";
  String employeeIdConfirm = "";
  String storedEmployeeId = "";
  String code = "";
  String getcode = "";

  Future<List<RecordPendingModel>> fetchRecordData() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/pending-detail/${widget.idPending}/'),
    );

    // Memastikan status code adalah 200 (OK)
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('data')) {
        var dataList = jsonResponse['data'];
        if (dataList != null && dataList is List) {
          setState(() {
            storedEmployeeId = jsonResponse['data'][0]['idEmployee'];
          });
          return dataList
              .map(
                  (recordDetails) => RecordPendingModel.fromJson(recordDetails))
              .toList();
        } else {
          logPrint('Data is null or not a List: $dataList');
          return [];
        }
      } else {
        logPrint('No "data" key found, processing root level JSON.');

        return [RecordPendingModel.fromJson(jsonResponse)];
      }
    } else {
      // Menangani kesalahan jika status code bukan 200
      throw Exception('Failed to load records');
    }
  }

  Future<void> scanQrCodeEmployee() async {
    try {
      // 📷 Step 1: Scan pakai MobileScannerPage
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration:
              const Duration(milliseconds: 300), // pop halus
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // 📌 Step 2: Validasi QRCode Employee (8 digit)
      if (getcode.length != 8) {
        CustomSnackbar.show(
          context,
          "Wrong Employee QRCode",
          isSuccess: false,
        );

        return;
      }

      // 🔍 Step 3: Ambil detail employee dengan timeout
      final response = await http
          .get(Uri.parse("${AppConfig.baseUrl}/api/employee-detail/$getcode/"))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Request timed out. Please try again.");
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          employeeName = data['full_name'].toString();
          employeeIdConfirm = data['id_employee'].toString();
        });
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Employee not found. Please add Employee to Database.",
          isSuccess: false,
        );
      } else {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Error: ${response.statusCode} - ${response.reasonPhrase}",
          isSuccess: false,
        );
      }
    } on TimeoutException catch (_) {
      CustomSnackbar.show(
        context,
        "Request timed out. Please try again.",
        isSuccess: false,
      );
    } on SocketException catch (_) {
      CustomSnackbar.show(
        context,
        "Network error. Please check your internet connection and try again.",
        isSuccess: false,
      );
    } on FormatException catch (_) {
      CustomSnackbar.show(
        context,
        "Error parsing data from server.",
        isSuccess: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Unexpected error occurred: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> updateRecordPending(int idPending) async {
    final String url =
        '${AppConfig.baseUrl}/api/update-record-pending/$idPending/';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Tambahkan body kosong jika API membutuhkannya
      );

      logPrint("Response Status: ${response.statusCode}");
      logPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        logPrint('Success: ${responseData['message']}');

        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Successfully: ${responseData['message']}",
          isSuccess: true,
        );

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RecordStop(
              title: 'STOP',
              idProses: "001",
            ),
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
            transitionDuration: const Duration(milliseconds: 1200),
          ),
        );
      } else {
        try {
          final responseData = jsonDecode(response.body);
          logPrint('Error: ${responseData['error']}');

          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Error: ${responseData['error']}.",
            isSuccess: false,
          );
        } catch (e) {
          logPrint("Invalid JSON Response: ${response.body}");

          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Unexpected response format.",
            isSuccess: false,
          );
        }
      }
    } catch (error) {
      logPrint('Error: $error');

      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Request failed: $error",
        isSuccess: false,
      );
    }
  }

  void submitDataStop() {
    if (employeeIdConfirm.isEmpty) {
      CustomSnackbar.show(
        context,
        "Please scan Employee QRCode!",
        isSuccess: false,
      );

      return;
    } else if (employeeIdConfirm != storedEmployeeId) {
      CustomSnackbar.show(
        context,
        "Employee Confirm does not match!",
        isSuccess: false,
      );

      return;
    } else {
      // Jika validasi berhasil, panggil updateRecordPending
      updateRecordPending(int.parse(widget.idPending)); // Panggil fungsi update
    }
  }

  @override
  void initState() {
    super.initState();
    recordDetail = fetchRecordData();
    fetchRecordData().then((records) {
      // Jika data berhasil dimuat, setState untuk menyimpan storedEmployeeId
      setState(() {
        if (records.isNotEmpty) {
          storedEmployeeId =
              records[0].idEmployee; // Menyimpan idEmployee dari data pertama
        }
        // recordDetail = records; // Menyimpan data ke recordDetail
      });
    });
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    double heightApp = MediaQuery.of(context).size.height;
    // double paddingTop = MediaQuery.of(context).padding.top;
    bool isTablet = widthApp > 600;

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
          automaticallyImplyLeading: false,
          title: const Text(
            'ACTION TO RUNNING MOLDING',
            style: TextStyle(
                color: Colors.white, fontSize: 18.0, fontFamily: "Montserrat"),
          ),
          centerTitle: true,
          backgroundColor:
              Colors.transparent, // Menjadikan background AppBar transparan
        ),
      ),
    );
    // double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    return Scaffold(
      appBar: myAppBar,
      body: FutureBuilder<List<RecordPendingModel>>(
        future: recordDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Jika data sedang dimuat*******
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            //Jika terjadi kesalahan atau error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //Jika data kosong
            return const Center(child: Text("No Data Available"));
          } else {
            //Jika data sudah dimuat dan tidak kosong,kita bisa akses dan menampilkannya.
            final data = snapshot.data!; // Ambil data hasil future

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: isTablet
                    ? Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(data[0].idRecord,
                                style: TextStyle(fontSize: 16.0)),
                            Text(data[0].nameProses,
                                style: TextStyle(fontSize: 16.0)),
                            Text(data[0].drawingNumber,
                                style: TextStyle(fontSize: 16.0)),
                            Text(data[0].productType,
                                style: TextStyle(fontSize: 16.0)),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image Section
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Colors.grey), // Garis luar tabel
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Menghitung ukuran gambar berdasarkan persentase lebar layar
                                        double imageWidth =
                                            MediaQuery.of(context).size.width *
                                                0.16; // 30% dari lebar layar
                                        double imageHeight =
                                            imageWidth; // Rasio gambar 1:1

                                        return Align(
                                          alignment: Alignment.topCenter,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            child: Image.network(
                                              "${AppConfig.baseUrl}/media/img/employee/${data[0].idEmployee}.png",
                                              width: imageWidth,
                                              height: imageHeight,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data[0].employeeName,
                                    style: const TextStyle(
                                      fontSize:
                                          20.0, // Larger size for full name
                                      fontWeight: FontWeight
                                          .bold, // Bold style for emphasis
                                      color: Colors
                                          .black, // Optional: set text color
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 5.0), // Space between lines
                                  // NRP with smaller font size
                                  Text(
                                    data[0].nrp,
                                    style: TextStyle(
                                      fontSize: 14.0, // Smaller size for nrp
                                      color: Colors
                                          .grey[700], // Lighter color for nrp
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 5.0), // Space between lines
                                  // Section with medium size
                                  Text(
                                    data[0].section,
                                    style: TextStyle(
                                      fontSize: 16.0, // Medium size for section
                                      fontWeight: FontWeight
                                          .w400, // Slightly bold for section
                                      color:
                                          Colors.grey[700], // Darker text color
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 5.0), // Space between lines
                                  // Division with smaller font size
                                  Text(
                                    data[0].division,
                                    style: TextStyle(
                                      fontSize:
                                          16.0, // Smaller size for division
                                      fontWeight: FontWeight
                                          .w400, // Normal weight for division
                                      color: Colors
                                          .grey[700], // Lighter text color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Text Section
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Colors.white), // Garis luar tabel
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        // Bagian kiri untuk Table
                                        Expanded(
                                          flex: 7, // 70% dari total layar
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Table(
                                              columnWidths: const {
                                                0: FlexColumnWidth(
                                                    2), // Kolom pertama
                                                1: FixedColumnWidth(
                                                    20), // Kolom untuk ":"
                                                2: FlexColumnWidth(
                                                    2), // Kolom kedua
                                              },
                                              children: [
                                                TableRow(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text('JOB NUMBER',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(':',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          data[0]
                                                              .jobnumber
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                  ],
                                                ),
                                                TableRow(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(
                                                        'MACHINE',
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(':',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                        data[0].machineName,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                TableRow(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text('BCODE',
                                                          textAlign:
                                                              TextAlign.left),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(':',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child:
                                                          Text(data[0].bcode),
                                                    ),
                                                  ],
                                                ),
                                                TableRow(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text('QTY',
                                                          textAlign:
                                                              TextAlign.left),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(':',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(data[0]
                                                          .qty
                                                          .toString()),
                                                    ),
                                                  ],
                                                ),
                                                TableRow(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text('START TIME',
                                                          textAlign:
                                                              TextAlign.left),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(':',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          widget.formatDateTime(
                                                              data[0]
                                                                  .startTime)),
                                                    ),
                                                  ],
                                                ),
                                                TableRow(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(
                                                          'PENDING TIME',
                                                          textAlign:
                                                              TextAlign.left),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(':',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text((widget
                                                          .formatDateTime(data[
                                                                  0]
                                                              .startPending))),
                                                    ),
                                                  ],
                                                ),
                                                TableRow(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(
                                                          'PENDING REASON',
                                                          textAlign:
                                                              TextAlign.left),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(':',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text((data[0]
                                                          .reason
                                                          .toString())),
                                                    ),
                                                  ],
                                                ),
                                                TableRow(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(
                                                          'CONFIRM EMPLOYEE',
                                                          textAlign:
                                                              TextAlign.left),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(':',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Text(employeeName),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Garis pemisah
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //Sampai sini yaaaaaaaaaa
                          ],
                        ),
                        const SizedBox(width: 20.0),
                        Row(children: [
                          Expanded(
                            flex: 8,
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey), // Garis luar tabel
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                        child: Ink(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            5), // Sudut melengkung
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red,
                                            Colors.red.shade800
                                          ], // Warna gradien
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors
                                              .transparent, // Gunakan transparan karena gradien sudah di Ink
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                5), // Sudut melengkung
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical:
                                                  30), // Ukuran padding tombol
                                        ),
                                        onPressed: () {
                                          _closeDialog();
                                        },
                                        child: const Text(
                                          'CANCEL',
                                          style: TextStyle(
                                            fontSize: 25.0,
                                            color: Colors
                                                .white, // Warna teks putih
                                          ),
                                        ),
                                      ),
                                    )),
                                    const SizedBox(width: 10.0),
                                    Expanded(
                                        child: Ink(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            5), // Sudut melengkung
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue,
                                            Colors.blue.shade800
                                          ], // Warna gradien
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors
                                              .transparent, // Menggunakan transparan karena gradien sudah di Ink
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                5), // Sudut melengkung
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical:
                                                  30), // Ukuran padding tombol
                                        ),
                                        onPressed: () {
                                          // Panggil fungsi submitDataStop dengan data yang sesuai

                                          submitDataStop();
                                        },
                                        child: const Text(
                                          'SUBMIT',
                                          style: TextStyle(
                                            fontSize: 25.0,
                                            color: Colors
                                                .white, // Warna teks putih
                                          ),
                                        ),
                                      ),
                                    )),
                                  ],
                                )),
                          ),
                          Expanded(
                              flex: 2,
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey), // Garis luar tabel
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          5), // Sudut melengkung
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.blue.shade800
                                        ], // Warna gradien
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .transparent, // Transparan karena gradien ada di Ink
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              5), // Sudut melengkung
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical:
                                                25), // Ukuran padding tombol
                                      ),
                                      onPressed: () {
                                        scanQrCodeEmployee();
                                      },
                                      child: const Icon(
                                        Icons.qr_code,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  )))
                        ]),
                      ])
                    : Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              data[0].idProses,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              data[0].bcode,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              data[0].drawingNumber,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              data[0].productType,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Column(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      "${AppConfig.baseUrl}/static/img/employee/${data[0].idEmployee}.png",
                                      width: widthApp * 0.2,
                                      height: heightApp * 0.1,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.person,
                                                  size: 120,
                                                  color: Colors.grey),
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    data[0].employeeName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    data[0].nrp,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    data[0].section.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    data[0].division,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ]),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(3), // Kolom pertama

                                        1: FlexColumnWidth(7), // Kolom kedua
                                      },
                                      children: [
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('ID RECORD',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].idRecord}",
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('JOB NUMBER',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].jobnumber}",
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('BCODE',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(": ${data[0].bcode}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('MACHINE',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].machineName}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('QTY',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].qty.toString()}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('START TIME',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].startTime}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('STATUS',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].status.toUpperCase()}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('CONFIRM',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${employeeName.toString()}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Container pertama dengan lebar 70% dari layar
                            Flexible(
                              flex: 7, // 7 bagian dari 10
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      5), // Sudut melengkung
                                  border: Border.all(
                                      color: Colors.grey,
                                      width: 1), // Garis tepi
                                ),
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Tombol pertama
                                    Expanded(
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.red,
                                              Colors.red.shade200
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors
                                                .transparent, // Menggunakan background transparan
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                          onPressed: () {
                                            _closeDialog();
                                          },
                                          child: const Text(
                                            'CANCEL',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0),
                                    // Tombol kedua
                                    Expanded(
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue,
                                              Colors.blue.shade800
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                          onPressed: () {
                                            submitDataStop();
                                          },
                                          child: const Text(
                                            'SUBMIT',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Container kedua dengan lebar 30% dari layar
                            Flexible(
                              flex: 3, // 3 bagian dari 10
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                padding: EdgeInsets.all(5),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue,
                                        Colors.blue.shade800
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                    ),
                                    onPressed: () {
                                      scanQrCodeEmployee();
                                    },
                                    child: const Icon(
                                      Icons.qr_code,
                                      size: 26.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
              ),
            );
          }
        },
      ),
    );
  }
}

class ChangeOperatorDialog extends StatefulWidget {
  final String idPending;
  final String Function(String) formatDateTime;
  const ChangeOperatorDialog(
      {Key? key, required this.idPending, required this.formatDateTime})
      : super(key: key);

  @override
  _ChangeOperatorDialogState createState() => _ChangeOperatorDialogState();
}

class _ChangeOperatorDialogState extends State<ChangeOperatorDialog> {
  late Future<List<RecordPendingDetailModel>> _recordFuture;
  late String getCodeEmployee;
  late String idEmployee;
  String nameNextOperator = "";
  String idNextOperator = "";
  String storedEmployeeId = "";
  String code = "";
  String getCodeOperator = "";
  String nrpNextOperator = "";
  String divNextOperator = "";
  String secNextOperator = "";
  String photoNextOperator = "";

  Future<List<RecordPendingDetailModel>>
      fetchRecordPendingDetailWithNg() async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.baseUrl}/api/pending-detail-with-ng/${widget.idPending}/'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse.containsKey('data')) {
        var dataList = jsonResponse['data'];
        if (dataList != null && dataList is List) {
          return dataList
              .map((item) => RecordPendingDetailModel.fromJson(item))
              .toList();
        } else {
          logPrint('Data "data" null atau bukan List: $dataList');
          return [];
        }
      } else {
        logPrint('Tidak ada key "data", parsing dari root object.');
        return [RecordPendingDetailModel.fromJson(jsonResponse)];
      }
    } else {
      throw Exception(
          'Gagal memuat data record pending NG: ${response.statusCode}');
    }
  }

  Future<void> scanQrNextOperator() async {
    try {
      // 📷 Step 1: Scan pakai MobileScannerPage
      final getCodeOperator = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const MobileScannerPage()),
      );

      if (!mounted) return;
      if (getCodeOperator == null ||
          getCodeOperator.isEmpty ||
          getCodeOperator == "-1") return;

      // 📌 Step 2: Validasi QRCode Employee (8 digit)
      if (getCodeOperator.length != 8) {
        CustomSnackbar.show(
          context,
          "Wrong Employee QRCode",
          isSuccess: false,
        );

        return;
      }

      // 🔍 Step 3: Ambil detail employee dengan timeout
      final response = await http
          .get(Uri.parse(
              "${AppConfig.baseUrl}/api/employee-detail/$getCodeOperator/"))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Request timed out. Please try again.");
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          idNextOperator = data['id_employee'].toString();
          nameNextOperator = data['full_name'].toString();
          nrpNextOperator = data['nrp'].toString();
          divNextOperator = data['division'].toString();
          secNextOperator = data['section'].toString();
          photoNextOperator = "${data["id_employee"].toString()}.png";
        });
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Employee not found. Please add Employee to Database.",
          isSuccess: false,
        );
      } else {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Error: ${response.statusCode} - ${response.reasonPhrase}",
          isSuccess: false,
        );
      }
    } on TimeoutException catch (_) {
      CustomSnackbar.show(
        context,
        "Request timed out. Please try again.",
        isSuccess: false,
      );
    } on SocketException catch (_) {
      CustomSnackbar.show(
        context,
        "Network error. Please check your internet connection and try again.",
        isSuccess: false,
      );
    } on FormatException catch (_) {
      CustomSnackbar.show(
        context,
        "Error parsing data from server.",
        isSuccess: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Unexpected error occurred: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> updateRecordPendingWithNg({
    required int idPending,
    required String idEmployeeFinish,
  }) async {
    final String url =
        '${AppConfig.baseUrl}/api/update-record-pending-with-ng/';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_pending': idPending,
          'id_employee_finish': idEmployeeFinish,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Successfully: ${responseData['message']}.",
          isSuccess: true,
        );

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RecordStop(
              title: 'STOP',
              idProses: "001",
            ),
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
            transitionDuration: const Duration(milliseconds: 1200),
          ),
        );
      } else {
        try {
          final responseData = jsonDecode(response.body);

          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Error: ${responseData['error']}",
            isSuccess: false,
          );
        } catch (e) {
          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Unexpected response format.",
            isSuccess: false,
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Request failed: $error",
        isSuccess: false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _recordFuture = fetchRecordPendingDetailWithNg();

    idNextOperator = "";
    nameNextOperator = "NAME OPERATOR"; // default value
    nrpNextOperator = "NRP OPERATOR";
    divNextOperator = "DIVISION"; // default value
    secNextOperator = "SECTION"; // default value
    photoNextOperator = "employee.png";
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    double heightApp = MediaQuery.of(context).size.height;
    // double paddingTop = MediaQuery.of(context).padding.top;
    bool isTablet = widthApp > 600;

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
          automaticallyImplyLeading: false,
          title: const Text(
            'ACTION CHANGE OPERATOR TO CONTINUE',
            style: TextStyle(
                color: Colors.white, fontSize: 18.0, fontFamily: "Montserrat"),
          ),
          centerTitle: true,
          backgroundColor:
              Colors.transparent, // Menjadikan background AppBar transparan
        ),
      ),
    );
    // double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    return Scaffold(
      appBar: myAppBar,
      body: FutureBuilder<List<RecordPendingDetailModel>>(
        future: _recordFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Jika data sedang dimuat*******
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            //Jika terjadi kesalahan atau error

            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //Jika data kosong
            return const Center(child: Text("No Data Available"));
          } else {
            //Jika data sudah dimuat dan tidak kosong,kita bisa akses dan menampilkannya.
            final data = snapshot.data!; // Ambil data hasil future

            // final remainingShoot = data[0].totalShoot - data[0].currentShoot;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: isTablet
                    ? Column(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade800,
                                Colors.blue.shade600,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                data[0].idRecord,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                data[0].nameProses,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                data[0].drawingNumber,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                data[0].productType,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section

                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // FOTO KARYAWAN
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      alignment: Alignment.topCenter,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade100,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          )
                                        ],
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          double imageWidth =
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.16;
                                          double imageHeight = imageWidth;

                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              "${AppConfig.baseUrl}/media/img/employee/${data[0].idEmployee}.png",
                                              width: imageWidth,
                                              height: imageHeight,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // NAMA KARYAWAN
                                    Text(
                                      data[0].employeeName,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),

                                    // NRP
                                    Text(
                                      data[0].nrp,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),

                                    // SECTION
                                    Text(
                                      data[0].section,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),

                                    // DIVISION
                                    Text(
                                      data[0].division,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),

                                    // BUTTON CANCEL
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red.shade400,
                                            Colors.red.shade800,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.shade200
                                                .withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6,
                                          )
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _closeDialog();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 22),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.cancel,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              'CANCEL',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // BUTTON SUBMIT
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade800,
                                            Colors.blue.shade600,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.shade200
                                                .withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6,
                                          )
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (idNextOperator.isEmpty) {
                                            CustomSnackbar.show(
                                              context,
                                              "Please scan Employee QRCode!.",
                                              isSuccess: false,
                                            );

                                            return;
                                          }

                                          // Konversi dan validasi idPending
                                          int? id =
                                              int.tryParse(widget.idPending);
                                          if (id == null) {
                                            CustomSnackbar.show(
                                              context,
                                              "Invalid ID Pending format.",
                                              isSuccess: false,
                                            );

                                            return;
                                          }

                                          // Panggil function PATCH ke API
                                          await updateRecordPendingWithNg(
                                            idPending: id,
                                            idEmployeeFinish: idNextOperator,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 22),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.send,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              'SUBMIT',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // BUTTON CONFIRM
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade600,
                                            Colors.blue.shade400,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.shade200
                                                .withAlpha((0.3 * 255).toInt()),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6,
                                          )
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          scanQrNextOperator();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 22),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            // Icon(Icons.qr_code,color: Colors.white),
                                            Icon(Icons.person_add,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              'OPERATOR',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Text Section
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Colors.white), // Garis luar tabel
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    //DISINI YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Bagian kiri untuk Table
                                            Expanded(
                                              flex: 7, // 70% dari total layar
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(
                                                        2), // Kolom pertama
                                                    1: FixedColumnWidth(
                                                        20), // Kolom untuk ":"
                                                    2: FlexColumnWidth(
                                                        2), // Kolom kedua
                                                  },
                                                  children: [
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              'JOB NUMBER',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              data[0]
                                                                  .jobnumber
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                            'MACHINE',
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            data[0].machineName,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text('BCODE',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              data[0].bcode),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text('QTY',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(data[0]
                                                              .qty
                                                              .toString()),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              'START JOB',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(widget
                                                              .formatDateTime(
                                                                  data[0]
                                                                      .startTime)),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              'PENDING TIME',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text((widget
                                                              .formatDateTime(data[
                                                                      0]
                                                                  .startPending))),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text('REASON',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              (data[0].reason)),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              'TOTAL SHOOT',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(data[0]
                                                              .shootTotal
                                                              .toString()),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              'CURRENT SHOOT',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(data[0]
                                                              .shootTotal
                                                              .toString()),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Garis pemisah
                                          ],
                                        ), //Row disini
                                        const SizedBox(height: 5),

                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors
                                                    .white), // Garis luar tabel
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0.0, vertical: 8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'LIST NG',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                if (data[0].ngList.length ==
                                                        1 &&
                                                    data[0].ngList[0].idNg ==
                                                        '000000' &&
                                                    data[0]
                                                            .ngList[0]
                                                            .ngName
                                                            .toUpperCase() ==
                                                        'NO NG')
                                                  Text(
                                                    'SO FAR IS GOOD NO NG FOUND.',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .green.shade800),
                                                  )
                                                else
                                                  LayoutBuilder(
                                                    builder:
                                                        (context, constraints) {
                                                      return SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              BoxConstraints(
                                                                  minWidth:
                                                                      constraints
                                                                          .maxWidth),
                                                          child: Table(
                                                            columnWidths: const {
                                                              0: FlexColumnWidth(
                                                                  1), // kolom nomor
                                                              1: FlexColumnWidth(
                                                                  4), // kolom 'NG Name'
                                                              2: FlexColumnWidth(
                                                                  1), // kolom 'Qty'
                                                            },
                                                            border:
                                                                TableBorder.all(
                                                                    color: Colors
                                                                        .grey),
                                                            children: [
                                                              // Header
                                                              TableRow(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      Colors
                                                                          .blue
                                                                          .shade800,
                                                                      Colors
                                                                          .blue
                                                                          .shade300,
                                                                    ],
                                                                    begin: Alignment
                                                                        .topCenter,
                                                                    end: Alignment
                                                                        .bottomCenter,
                                                                  ),
                                                                ),
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      'NO',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.white),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      'NG NAME',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      'QTY',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              // Rows data ngList dengan nomor
                                                              ...data[0]
                                                                  .ngList
                                                                  .asMap()
                                                                  .entries
                                                                  .map((entry) {
                                                                final index =
                                                                    entry.key;
                                                                final ng =
                                                                    entry.value;
                                                                return TableRow(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Text(
                                                                        (index +
                                                                                1)
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          ng.ngName),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Text(
                                                                        ng.qty
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              }),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                            // padding: EdgeInsets.all(0),

                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors
                                                      .white), // Garis luar tabel
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "NEXT OPERATOR",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ]),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // FOTO KARYAWAN (KIRI)
                                                    Expanded(
                                                      flex:
                                                          3, // lebih proporsional
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 10),
                                                        child: Center(
                                                          child: Container(
                                                            width: 200,
                                                            height: 200,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey.shade50,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                child: Image
                                                                    .network(
                                                                  "${AppConfig.baseUrl}/media/img/employee/$photoNextOperator",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder:
                                                                      (context,
                                                                          error,
                                                                          stackTrace) {
                                                                    return Icon(
                                                                      Icons
                                                                          .person,
                                                                      size: 60,
                                                                      color: Colors
                                                                          .grey,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // DATA KARYAWAN (KANAN)
                                                    Expanded(
                                                      flex: 7,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Table(
                                                          defaultVerticalAlignment:
                                                              TableCellVerticalAlignment
                                                                  .middle,
                                                          columnWidths: {
                                                            0: FlexColumnWidth(),
                                                          },
                                                          children: [
                                                            TableRow(
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border(
                                                                      bottom: BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    nameNextOperator,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            TableRow(
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border(
                                                                      bottom: BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                      nrpNextOperator),
                                                                ),
                                                              ],
                                                            ),
                                                            TableRow(
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border(
                                                                      bottom: BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                      divNextOperator),
                                                                ),
                                                              ],
                                                            ),
                                                            TableRow(
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border(
                                                                      bottom: BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                      secNextOperator),
                                                                ),
                                                              ],
                                                            ),
                                                            TableRow(
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              8,
                                                                          horizontal:
                                                                              4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border(
                                                                      bottom: BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        "REMAINING SHOOT",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.normal),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(right: 25),
                                                                        child:
                                                                            Text(
                                                                          data[0]
                                                                              .sisaShoot
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(fontSize: 16),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ))
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                ],
                              ),
                            ),
                            //Sampai sini yaaaaaaaaaa
                          ],
                        ),
                      ])
                    : Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              data[0].idProses,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              data[0].bcode,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              data[0].drawingNumber,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              data[0].productType,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Column(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      "${AppConfig.baseUrl}/static/img/employee/${data[0].idEmployee}.png",
                                      width: widthApp * 0.2,
                                      height: heightApp * 0.1,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.person,
                                                  size: 120,
                                                  color: Colors.grey),
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    data[0].employeeName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    data[0].nrp,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    data[0].section.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    data[0].division,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ]),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(3), // Kolom pertama

                                        1: FlexColumnWidth(7), // Kolom kedua
                                      },
                                      children: [
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('ID RECORD',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].idRecord}",
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('JOB NUMBER',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].jobnumber}",
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('BCODE',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(": ${data[0].bcode}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('MACHINE',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].machineName}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('QTY',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].qty.toString()}", //disini ya waktu nya **************************************************************************************************************
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('START TIME',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].startTime}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('CONFIRM',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${nameNextOperator.toString()}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
              ),
            );
          }
        },
      ),
    );
  }
}

//*****************************************CHANGE MACHINE REASON *****************************************************************************/
class ChangeMachineDialog extends StatefulWidget {
  final String idPending;
  final String Function(String) formatDateTime;
  const ChangeMachineDialog(
      {Key? key, required this.idPending, required this.formatDateTime})
      : super(key: key);

  @override
  _ChangeMachineDialogState createState() => _ChangeMachineDialogState();
}

class _ChangeMachineDialogState extends State<ChangeMachineDialog> {
  late Future<List<RecordPendingModel>> _recordFuture;
  late String getCodeMachine;
  String idNextMachine = "";
  String nameNextMachine = "";
  String idEmployeeConfirm = "";
  String nameEmployeeConfirm = "";
  String storedEmployeeId = "";
  bool isScanningEmployee = false;
  bool isScanningMachine = false;
  bool isSubmitting = false;

  Future<List<RecordPendingModel>> fetchRecordData() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/pending-detail/${widget.idPending}/'),
    );

    // Memastikan status code adalah 200 (OK)
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse.containsKey('data')) {
        var dataList = jsonResponse['data'];
        if (dataList != null && dataList is List) {
          storedEmployeeId = dataList[0]['id_employee']; // dari list
          return dataList
              .map(
                  (recordDetails) => RecordPendingModel.fromJson(recordDetails))
              .toList();
        } else {
          // print('Data is null or not a List: $dataList');
          return [];
        }
      } else {
        // print('No "data" key found, processing root level JSON.');
        storedEmployeeId = jsonResponse['id_employee']; // <- Tambahkan ini!
        setState(() {});
        return [RecordPendingModel.fromJson(jsonResponse)];
      }
    } else {
      // Menangani kesalahan jika status code bukan 200
      throw Exception('Failed to load records');
    }
  }

  @override
  void initState() {
    super.initState();
    _recordFuture = fetchRecordData();
  }

  Future<void> scanQrNextMachine() async {
    try {
      // 📷 Step 1: Scan pakai MobileScannerPage
      final getCodeMachine = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const MobileScannerPage()),
      );

      if (!mounted) return;
      if (getCodeMachine == null ||
          getCodeMachine.isEmpty ||
          getCodeMachine == "-1") return;

      // 📌 Step 2: Validasi QRCode Machine (10 karakter)
      if (getCodeMachine.length != 10) {
        CustomSnackbar.show(
          context,
          "Wrong Machine QRCode",
          isSuccess: false,
        );

        return;
      }

      // 🔍 Step 3: Ambil detail mesin dengan timeout
      final response = await http
          .get(Uri.parse(
              "${AppConfig.baseUrl}/api/machine-detail/$getCodeMachine/"))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Request timed out. Please try again.");
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          idNextMachine = data['id_mc'].toString();
          nameNextMachine = data['nm_mc'].toString();
        });
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Machine not found. Please add Machine to Database.",
          isSuccess: false,
        );
      } else {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Error: ${response.statusCode} - ${response.reasonPhrase}",
          isSuccess: false,
        );
      }
    } on TimeoutException catch (_) {
      CustomSnackbar.show(
        context,
        "Request timed out. Please try again.",
        isSuccess: false,
      );
    } on SocketException catch (_) {
      CustomSnackbar.show(
        context,
        "Network error. Please check your internet connection and try again.",
        isSuccess: false,
      );
    } on FormatException catch (_) {
      CustomSnackbar.show(
        context,
        "Error parsing data from server.",
        isSuccess: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Unexpected error occurred: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> scanEmployee() async {
    try {
      // 📷 Step 1: Scan QRCode pakai MobileScannerPage
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration:
              const Duration(milliseconds: 300), // pop halus
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // 📌 Step 2: Validasi QRCode Employee (8 digit)
      if (!RegExp(r'^\d{8}$').hasMatch(getcode)) {
        CustomSnackbar.show(
          context,
          "Invalid QR Code format. Must be 8 digits.",
          isSuccess: false,
        );

        return;
      }

      // 🔍 Step 3: Ambil detail Employee dengan timeout
      final response = await http
          .get(Uri.parse("${AppConfig.baseUrl}/api/employee-detail/$getcode/"))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Request timed out. Please try again.");
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (!data.containsKey('id_employee')) {
          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Invalid data from server",
            isSuccess: false,
          );

          return;
        }

        if (data['status'] == "02") {
          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Employee not Active",
            isSuccess: false,
          );

          return;
        }

        if (!mounted) return;
        setState(() {
          idEmployeeConfirm = data['id_employee'].toString();
          nameEmployeeConfirm = data['full_name'].toString();
        });
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Employee not found. Please add Employee to Database.",
          isSuccess: false,
        );
      } else {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Error: ${response.statusCode} - ${response.reasonPhrase}",
          isSuccess: false,
        );
      }
    } on TimeoutException catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Request timed out. Please try again.",
        isSuccess: false,
      );
    } on SocketException catch (_) {
      CustomSnackbar.show(
        context,
        "Network error. Please check your internet connection.",
        isSuccess: false,
      );
    } on FormatException catch (_) {
      CustomSnackbar.show(
        context,
        "Error parsing data from server.",
        isSuccess: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Unexpected error occurred: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> updateRecordPendingMc(int idPending, String idMachine) async {
    final String url =
        '${AppConfig.baseUrl}/api/update-record-pending-mc/'; // tanpa param di URL

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_pending': idPending, // kirim id_pending di body
          'id_machine': idMachine, // kirim id_machine di body
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Notification: ${responseData['message']}.",
          isSuccess: true,
        );

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RecordStop(
              title: 'STOP',
              idProses: "001",
            ),
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
            transitionDuration: const Duration(milliseconds: 1200),
          ),
        );
      } else {
        try {
          final responseData = jsonDecode(response.body);

          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Error: ${responseData['error']}",
            isSuccess: false,
          );
        } catch (e) {
          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Unexpected response format.",
            isSuccess: false,
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Request failed: $error",
        isSuccess: false,
      );
    }
  }

  void submitDataStop() async {
    if (isSubmitting) return; // Hindari double submit

    if (nameEmployeeConfirm.isEmpty) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "PLEASE,SCAN EMPLOYEE ID!.",
        isSuccess: false,
      );

      return;
    } else if (idEmployeeConfirm != storedEmployeeId) {
      CustomSnackbar.show(
        context,
        "Employee Confirmation salah!.",
        isSuccess: false,
      );

      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await updateRecordPendingMc(
        int.parse(widget.idPending),
        idNextMachine,
      );
    } finally {
      // Setelah selesai (sukses atau error), kembalikan flag
      setState(() {
        isSubmitting = false;
      });
    }
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    double heightApp = MediaQuery.of(context).size.height;
    // double paddingTop = MediaQuery.of(context).padding.top;
    bool isTablet = widthApp > 600;

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
          automaticallyImplyLeading: false,
          title: const Text(
            'ACTION CHANGE MACHINE',
            style: TextStyle(
                color: Colors.white, fontSize: 18.0, fontFamily: "Montserrat"),
          ),
          centerTitle: true,
          backgroundColor:
              Colors.transparent, // Menjadikan background AppBar transparan
        ),
      ),
    );
    // double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    return Scaffold(
      appBar: myAppBar,
      body: FutureBuilder<List<RecordPendingModel>>(
        future: _recordFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Jika data sedang dimuat*******
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            //Jika terjadi kesalahan atau error

            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //Jika data kosong
            return const Center(child: Text("No Data Available"));
          } else {
            //Jika data sudah dimuat dan tidak kosong,kita bisa akses dan menampilkannya.
            final data = snapshot.data!; // Ambil data hasil future

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: isTablet
                    ? Column(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade800,
                                Colors.blue.shade600,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                data[0].idRecord,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                data[0].nameProses,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                data[0].drawingNumber,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                data[0].productType,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section

                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // FOTO KARYAWAN

                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      alignment: Alignment.topCenter,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade100,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          )
                                        ],
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          double imageWidth =
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.16;
                                          double imageHeight = imageWidth;

                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              "${AppConfig.baseUrl}/media/img/employee/${data[0].idEmployee}.png",
                                              width: imageWidth,
                                              height: imageHeight,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // NAMA KARYAWAN

                                    Text(
                                      data[0].employeeName,
                                      style: const TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),

                                    // NRP
                                    Text(
                                      data[0].nrp,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),

                                    const SizedBox(height: 6.0),

                                    // SECTION
                                    Text(
                                      data[0].section,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),

                                    // DIVISION
                                    Text(
                                      data[0].division,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),

                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade300,
                                            Colors.blue.shade600,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.shade200
                                                .withAlpha((0.3 * 255).toInt()),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6,
                                          )
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        // onPressed: () {},

                                        onPressed: isScanningMachine
                                            ? null
                                            : () async {
                                                setState(() {
                                                  isScanningMachine = true;
                                                });
                                                await scanQrNextMachine();

                                                if (mounted) {
                                                  setState(() {
                                                    isScanningMachine = false;
                                                  });
                                                }
                                              },

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 22),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.qr_code,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              'MACHINE',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // BUTTON CONFIRM
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade600,
                                            Colors.blue.shade400,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.shade200
                                                .withAlpha((0.3 * 255).toInt()),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6,
                                          )
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        // onPressed: () {},

                                        onPressed: isScanningEmployee
                                            ? null // tombol disabled saat sedang scanning
                                            : () async {
                                                if (idNextMachine.isEmpty) {
                                                  CustomSnackbar.show(
                                                    context,
                                                    "Harap scan ID machine.",
                                                    isSuccess: false,
                                                  );

                                                  return;
                                                }

                                                setState(() {
                                                  isScanningEmployee = true;
                                                });

                                                await scanEmployee();

                                                if (mounted) {
                                                  setState(() {
                                                    isScanningEmployee = false;
                                                  });
                                                }
                                              },

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 22),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.qr_code,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              'CONFIRM',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10.0),

                                    // BUTTON SUBMIT

                                    Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.shade800,
                                              Colors.blue.shade600,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.shade200
                                                  .withOpacity(0.3),
                                              offset: const Offset(0, 2),
                                              blurRadius: 6,
                                            )
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: isSubmitting
                                              ? null
                                              : () async {
                                                  submitDataStop();
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 22),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: SizedBox(
                                            height: 24, // tinggi konsisten
                                            child: Center(
                                              child: isSubmitting
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const [
                                                        Icon(Icons.send,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          'SUBMIT',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        )),

                                    const SizedBox(height: 10.0),
                                    // BUTTON CANCEL
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red.shade400,
                                            Colors.red.shade800,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.shade200
                                                .withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6,
                                          )
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _closeDialog();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 22),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.cancel,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              'CANCEL',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Text Section
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Colors.white), // Garis luar tabel
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    //DISINI YAAAAAAAAAAA
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Bagian kiri untuk Table
                                            Expanded(
                                              flex: 7, // 70% dari total layar
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(
                                                        2), // Kolom pertama
                                                    1: FixedColumnWidth(
                                                        20), // Kolom untuk ":"
                                                    2: FlexColumnWidth(
                                                        2), // Kolom kedua
                                                  },
                                                  children: [
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              'JOB NUMBER',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              data[0]
                                                                  .jobnumber
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text('BCODE',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              data[0].bcode),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text('QTY',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(data[0]
                                                              .qty
                                                              .toString()),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              'START JOB',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(widget
                                                              .formatDateTime(
                                                                  data[0]
                                                                      .startTime)),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              'PENDING TIME',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text((widget
                                                              .formatDateTime(data[
                                                                      0]
                                                                  .startPending))),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text('REASON',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text((data[0]
                                                              .reason
                                                              .toString())),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                            'MACHINE BEFORE',
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            data[0].machineName,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                            'NEXT MACHINE',
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              nameNextMachine
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF9CCC65), // hijau daun pisang muda
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold, // opsional
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                            'OPERATOR CONFIRM',
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            nameEmployeeConfirm,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF9CCC65), // hijau daun pisang muda
                                                              fontWeight: FontWeight
                                                                  .bold, // opsional
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Garis pemisah
                                          ],
                                        ), //Row disini
                                        const SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                ],
                              ),
                            ),
                            //Sampai sini yaaaaaaaaaa
                          ],
                        ),
                      ])
                    : Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              data[0].idProses,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              data[0].bcode,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              data[0].drawingNumber,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              data[0].productType,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Column(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      "${AppConfig.baseUrl}/static/img/employee/${data[0].idEmployee}.png",
                                      width: widthApp * 0.2,
                                      height: heightApp * 0.1,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.person,
                                                  size: 120,
                                                  color: Colors.grey),
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    data[0].employeeName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    data[0].nrp,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    data[0].section.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    data[0].division,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ]),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(3), // Kolom pertama

                                        1: FlexColumnWidth(7), // Kolom kedua
                                      },
                                      children: [
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('ID RECORD',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].idRecord}",
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('JOB NUMBER',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].jobnumber}",
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('BCODE',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(": ${data[0].bcode}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('MACHINE',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].machineName}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('QTY',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].qty.toString()}", //disini ya waktu nya **************************************************************************************************************
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('START TIME',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${data[0].startTime}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
              ),
            );
          }
        },
      ),
    );
  }
}
