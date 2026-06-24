import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';
import 'package:flutter_provider_data/model/reason_dropdown_model.dart';
import 'package:flutter_provider_data/model/record_running_detail_model.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_provider_data/page/001-molding/recordprocess.dart';
import 'package:flutter_provider_data/page/001-molding/recordrunningmanage.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/page_transition_helper.dart';

class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Kalau kosong, boleh
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Cek karakter pertama, kalau 0, kembalikan oldValue (batalkan input)
    if (newValue.text.startsWith('0')) {
      return oldValue;
    }

    return newValue;
  }
}

class RecordRunning extends StatelessWidget {
  final String title;
  final String idProses;

  const RecordRunning({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Record Finish',
      debugShowCheckedModeBanner: false,
      home: ListRecordRunning(idProses: idProses),
    );
  }
}

class ListRecordRunning extends StatefulWidget {
  final String idProses;
  const ListRecordRunning({super.key, required this.idProses});

  @override
  _ListRecordRunningState createState() => _ListRecordRunningState();
}

class _ListRecordRunningState extends State<ListRecordRunning> {
  late Future<List<RecordRunningModel>> records;
  List<RecordRunningModel> _allPendingList = [];
  List<RecordRunningModel> _filteredList = [];
  String _scannedJobNumber = '';
  String _scannedEmployeeFinishId = '';
  bool _isSearchDisabled = false; // Untuk disable dua tombol pencarian
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

//Mengambil data dari API untuk list molding yang sedang Running**********************
  Future<void> _fetchData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });
    }

    try {
      List<RecordRunningModel> fetchedList = await fetchRecords();
      setState(() {
        _allPendingList = fetchedList;
        _filteredList = fetchedList;
        _scannedJobNumber = '';
        _scannedEmployeeFinishId = '';
        _isSearchDisabled = false;

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
        final jobnumber = item.detailsRecord.isNotEmpty
            ? item.detailsRecord[0].jobNumber
            : '';
        final matchesJobnumber = _scannedJobNumber.isEmpty ||
            jobnumber.toLowerCase() == _scannedJobNumber.toLowerCase();

        final matchesEmployeeFinish = _scannedEmployeeFinishId.isEmpty ||
            item.activeEmployee?.idEmployee == _scannedEmployeeFinishId;

        return matchesJobnumber && matchesEmployeeFinish;
      }).toList();

      _isSearchDisabled = true; // Disable tombol pencarian setelah filter
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

      // 📌 Step 2: Validasi format QRCode
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

  Future<void> scanAndFilterEmployeeFinish() async {
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

      // 📌 Step 2: Validasi panjang QRCode Employee (8 digit)
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
        "Error scanning employee: $e",
        isSuccess: false,
      );
    }
  }

  Future<List<RecordRunningModel>> fetchRecords() async {
    final response = await http.get(
      Uri.parse(
          "${AppConfig.baseUrl}/api/record-list/?run_status=running&id_proses=${widget.idProses}"),
    );

    if (response.statusCode == 200) {
      try {
        final body = json.decode(response.body);

        if (body is List) {
          return body
              .map((record) => RecordRunningModel.fromJson(record))
              .toList();
        } else {
          throw Exception("Expected a list but got: ${body.runtimeType}");
        }
      } catch (e) {
        throw Exception("Failed to decode JSON: $e\nBody: ${response.body}");
      }
    } else {
      throw Exception(
          'Failed to load records (status: ${response.statusCode})');
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
    double widthApp = MediaQuery.of(context).size.width;
    double heightApp = MediaQuery.of(context).size.height;
    bool isTablet = widthApp > 600;
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_hasError) return Center(child: Text('Error: $_errorMessage'));

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
            'MOULDING RUNNING',
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
                        // onPressed: () {},
                        onPressed:
                            _isSearchDisabled ? null : scanAndFilterJobNumber,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_sharp),
                            SizedBox(width: 8),
                            Text('JOBNUMBER'),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),
                      OutlinedButton(
                        // onPressed: () {},
                        onPressed: _isSearchDisabled
                            ? null
                            : scanAndFilterEmployeeFinish,
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
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _scannedJobNumber = '';
                              _scannedEmployeeFinishId = '';
                              _filteredList = _allPendingList;
                              _isSearchDisabled = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
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

                      const Spacer(), // <-- Ini yang akan dorong text ke kanan

                      const SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: () {
                          PageTransitionHelper.navigateReplaceWithTransition(
                            context,
                            RecordRunningManage(
                                title: "MANAGE MOLD RUNNING",
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
                        'MOLD RUNNING: ${_filteredList.length}',
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
                ? const Center(
                    child: Text(
                    'SAAT INI TIDAK ADA RUNNING MOLDING.',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                      letterSpacing: 0.5,
                    ),
                  ))
                : ListView.builder(
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final record = _filteredList[index];

                      return Card(
                        elevation: 4,
                        child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: isTablet
                                ? Column(children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          record.idRecord,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          record.proses.nameProses
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          record.detailsRecord.isNotEmpty
                                              ? record
                                                  .detailsRecord[0].bcode.bcode
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          record.detailsRecord.isNotEmpty
                                              ? record.detailsRecord[0].bcode
                                                  .drawingNumber
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          record.detailsRecord.isNotEmpty
                                              ? record.detailsRecord[0].bcode
                                                  .productType
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                      ],
                                    ),
                                    SizedBox(height: 5.0),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          child: Column(children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                "${AppConfig.baseUrl}/media/img/employee/${record.activeEmployee?.idEmployee}.png",
                                                width: widthApp * 0.15,
                                                height: heightApp * 0.1,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(Icons.person,
                                                        size: 120,
                                                        color: Colors.grey),
                                              ),
                                            ),
                                            SizedBox(height: 5.0),
                                            Text(
                                              record.activeEmployee?.fullName ??
                                                  'Operator tidak aktif',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              record.activeEmployee?.nrp ??
                                                  'NRP tidak ditemukan',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              (record.activeEmployee?.section ??
                                                      'Section tidak ditemukan')
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              (record.activeEmployee
                                                          ?.division ??
                                                      'Division tidak ditemukan')
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ]),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(
                                                        4), // Kolom pertama

                                                    1: FlexColumnWidth(
                                                        6), // Kolom kedua
                                                  },
                                                  children: [
                                                    TableRow(
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                      children: [
                                                        Padding(
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
                                                                        .bold,
                                                                fontSize: 15.0,
                                                              )),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].jobNumber : ''}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                                          child: Text('DRAW NO',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      15.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.detailsRecord.first.bcode.drawingNumber}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0)),
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
                                                          child: Text('MACHINE',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      15.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            ": ${record.activeMachine?.nmMc ?? 'N/A'}", // Ganti machineFinish ke activeMachine
                                                            textAlign:
                                                                TextAlign.left,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15.0),
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
                                                          child: Text('QTY',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].startQty.toString() : ''}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0)),
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
                                                              'SHOOT QTY',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].shootQty.toString() : ''}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0)),
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
                                                              'START TIME',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${_formatDateTime(record.startTime.toString())}", //disini ya waktu nya **************************************************************************************************************
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0)),
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
                                                          child: Text('STATUS',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.runStatus.toUpperCase()}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Ink(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5.0,
                                                                  vertical:
                                                                      15.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5), // Sudut melengkung pada border
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.red,
                                                                Colors.red
                                                                    .shade200,
                                                              ], // Gradasi biru
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                            ),
                                                          ),
                                                          child: OutlinedButton
                                                              .icon(
                                                            icon: Icon(
                                                                Icons.stop,
                                                                color: Colors
                                                                    .white,
                                                                size: 25.0),
                                                            label: Text(
                                                              "STOP",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 25.0,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              _showFullScreenDialog(
                                                                  context,
                                                                  record
                                                                      .idRecord);
                                                            },
                                                            style:
                                                                OutlinedButton
                                                                    .styleFrom(
                                                              // Menghilangkan background yang solid karena sudah menggunakan gradasi dari Container
                                                              foregroundColor:
                                                                  Colors.white,
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .transparent, // Border tidak terlihat di OutlinedButton
                                                                width:
                                                                    0, // Border normal tidak diperlukan
                                                              ),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15), // Sudut melengkung pada border
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      Expanded(
                                                        child: Ink(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5.0,
                                                                  vertical:
                                                                      15.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5), // Sudut melengkung pada border
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.blue,
                                                                Colors.blue
                                                                    .shade800
                                                              ], // Gradasi biru
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                            ),
                                                          ),
                                                          child: OutlinedButton
                                                              .icon(
                                                            icon: Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .white,
                                                                size: 25.0),
                                                            label: Text(
                                                              "FINISH",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 25.0,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator
                                                                  .pushReplacement(
                                                                context,
                                                                PageRouteBuilder(
                                                                  pageBuilder: (context,
                                                                          animation,
                                                                          secondaryAnimation) =>
                                                                      RecordProcess(
                                                                          title:
                                                                              "Moulding",
                                                                          idProses:
                                                                              record.idProses),
                                                                  transitionsBuilder: (context,
                                                                      animation,
                                                                      secondaryAnimation,
                                                                      child) {
                                                                    const curve =
                                                                        Curves
                                                                            .easeIn;
                                                                    var tween = Tween<double>(
                                                                            begin:
                                                                                0.0,
                                                                            end:
                                                                                1.0)
                                                                        .chain(CurveTween(
                                                                            curve:
                                                                                curve));
                                                                    var opacityAnimation =
                                                                        animation
                                                                            .drive(tween);

                                                                    return FadeTransition(
                                                                      opacity:
                                                                          opacityAnimation,
                                                                      child:
                                                                          child,
                                                                    );
                                                                  },
                                                                  transitionDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              1200),
                                                                ),
                                                              );
                                                            },
                                                            style:
                                                                OutlinedButton
                                                                    .styleFrom(
                                                              // Menghilangkan background yang solid karena sudah menggunakan gradasi dari Container
                                                              foregroundColor:
                                                                  Colors.white,
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .transparent, // Border tidak terlihat di OutlinedButton
                                                                width:
                                                                    0, // Border normal tidak diperlukan
                                                              ),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15), // Sudut melengkung pada border
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ])
                                : Column(// DARI SINI UNTUK SMARTPHONE****
                                    children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          record.idProses,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          record.detailsRecord.isNotEmpty
                                              ? record
                                                  .detailsRecord[0].bcode.bcode
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          record.detailsRecord[0].bcode
                                              .drawingNumber,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          record.detailsRecord.isNotEmpty
                                              ? record.detailsRecord[0].bcode
                                                  .productType
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                      ],
                                    ),
                                    SizedBox(height: 5.0),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          child: Column(children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                "${AppConfig.baseUrl}/media/img/employee/${record.activeEmployee?.idEmployee}.png",
                                                width: widthApp * 0.2,
                                                height: heightApp * 0.1,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(Icons.person,
                                                        size: 120,
                                                        color: Colors.grey),
                                              ),
                                            ),
                                            SizedBox(height: 5.0),
                                            Text(
                                              record.activeEmployee?.fullName ??
                                                  "-",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              record.activeEmployee?.nrp ?? "-",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              record.activeEmployee?.section
                                                      .toUpperCase() ??
                                                  "-",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              record.activeEmployee?.division ??
                                                  "-",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ]),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(
                                                        3), // Kolom pertama

                                                    1: FlexColumnWidth(
                                                        7), // Kolom kedua
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
                                                              'ID RECORD',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      10.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.idRecord}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      10.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
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
                                                              'JOB NUMBER',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      10.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].jobNumber : ''}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      10.0,
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
                                                          child: Text('MACHINE',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      10.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.activeMachine?.nmMc}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10.0)),
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
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].startQty.toString() : ''}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10.0)),
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
                                                              'START TIME',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.startTime}", //disini ya waktu nya **************************************************************************************************************
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10.0)),
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
                                                          child: Text('STATUS',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${record.runStatus.toUpperCase()}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10.0)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5.0),
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Ink(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5), // Sudut melengkung pada border
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.red,
                                                                Colors.red
                                                                    .shade200,
                                                              ], // Gradasi biru
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                            ),
                                                          ),
                                                          child: OutlinedButton
                                                              .icon(
                                                            icon: Icon(
                                                                Icons.stop,
                                                                color: Colors
                                                                    .white),
                                                            label: Text(
                                                              "STOP",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    isTablet
                                                                        ? 30.0
                                                                        : 16.0,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              _showFullScreenDialog(
                                                                  context,
                                                                  record
                                                                      .idRecord);
                                                            },
                                                            style:
                                                                OutlinedButton
                                                                    .styleFrom(
                                                              // Menghilangkan background yang solid karena sudah menggunakan gradasi dari Container
                                                              foregroundColor:
                                                                  Colors.white,
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .transparent, // Border tidak terlihat di OutlinedButton
                                                                width:
                                                                    0, // Border normal tidak diperlukan
                                                              ),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15), // Sudut melengkung pada border
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      Expanded(
                                                        child: Ink(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5), // Sudut melengkung pada border
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.blue,
                                                                Colors.blue
                                                                    .shade800
                                                              ], // Gradasi biru
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                            ),
                                                          ),
                                                          child: OutlinedButton
                                                              .icon(
                                                            icon: Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .white),
                                                            label: Text(
                                                              "FINISH",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    isTablet
                                                                        ? 30.0
                                                                        : 16.0,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator
                                                                  .pushReplacement(
                                                                context,
                                                                PageRouteBuilder(
                                                                  pageBuilder: (context,
                                                                          animation,
                                                                          secondaryAnimation) =>
                                                                      RecordProcess(
                                                                          title:
                                                                              "Molding",
                                                                          idProses:
                                                                              record.idProses),
                                                                  transitionsBuilder: (context,
                                                                      animation,
                                                                      secondaryAnimation,
                                                                      child) {
                                                                    const curve =
                                                                        Curves
                                                                            .easeIn;
                                                                    var tween = Tween<double>(
                                                                            begin:
                                                                                0.0,
                                                                            end:
                                                                                1.0)
                                                                        .chain(CurveTween(
                                                                            curve:
                                                                                curve));
                                                                    var opacityAnimation =
                                                                        animation
                                                                            .drive(tween);

                                                                    return FadeTransition(
                                                                      opacity:
                                                                          opacityAnimation,
                                                                      child:
                                                                          child,
                                                                    );
                                                                  },
                                                                  transitionDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              1200),
                                                                ),
                                                              );
                                                            },
                                                            style:
                                                                OutlinedButton
                                                                    .styleFrom(
                                                              // Menghilangkan background yang solid karena sudah menggunakan gradasi dari Container
                                                              foregroundColor:
                                                                  Colors.white,
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .transparent, // Border tidak terlihat di OutlinedButton
                                                                width:
                                                                    0, // Border normal tidak diperlukan
                                                              ),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15), // Sudut melengkung pada border
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ])),
                      );
                    },
                  ),
          ),
        ]));

//SAMPAI SINI YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA***************************************************************************************
  }

  Future<void> _showFullScreenDialog(
      BuildContext context, String idRecord) async {
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Dialog.fullscreen(
            backgroundColor: Colors.transparent,
            child: FadeTransition(
              opacity: animation,
              child: NumBlockKeyboardDialog(idRecord: idRecord),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );

    if (result == true) {
      await _fetchData(); // refresh data dari server
    }
  }
}

//CLASS UNTUK MENAMPILKAN DIALOG FULLSCREEN UNTUK MEMILIH ALASAN STOP*****************************************************************************************
class NumBlockKeyboardDialog extends StatefulWidget {
  final String idRecord;
  const NumBlockKeyboardDialog({super.key, required this.idRecord});

  @override
  _NumBlockKeyboardDialogState createState() => _NumBlockKeyboardDialogState();
}

class _NumBlockKeyboardDialogState extends State<NumBlockKeyboardDialog> {
  final double _opacity = 1.0;
  late Future<List<RecordRunningDetailModel>> recordrunningdetail;

  String? selectedReasonCode; //Ini tambahan baru.
  String? selectedReasonItem;
  ReasonDropdownModel? selectedReasonItemObject;
  List<ReasonDropdownModel> _reasonItems = <ReasonDropdownModel>[];

  final bool _isloading = false;

  String? selectedNgCode;
  String? selectedNgName;
  NgDropdownModel? selectedNgItemObject;
  List<NgDropdownModel> _ngItems = <NgDropdownModel>[];
  List<Map<String, String>> ngDataList = []; // menyimpan ID dan QTY

  final TextEditingController ngQtyController = TextEditingController();
  final TextEditingController currentShootQtyController =
      TextEditingController();
  bool isAddButtonEnabled = false;

  String code = "";
  String getcode = "";

  late String getCodeEmployee;
  late String idEmployee;
  String employeeName = "";
  String employeeIdConfirm = "";
  String storedEmployeeId = "";

  Future<List<RecordRunningDetailModel>> fetchRecordData() async {
    final response = await http.get(
      Uri.parse("${AppConfig.baseUrl}/api/record-detail/${widget.idRecord}/"),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('data')) {
        final dataList = jsonResponse['data'];
        if (dataList is List) {
          return dataList
              .map((item) => RecordRunningDetailModel.fromJson(item))
              .toList();
        } else {
          // Data bukan list, return list kosong atau throw error
          return [];
        }
      } else if (jsonResponse is Map<String, dynamic>) {
        // Tidak ada key 'data', tapi response adalah objek record langsung
        return [RecordRunningDetailModel.fromJson(jsonResponse)];
      } else {
        // Response tidak sesuai ekspektasi
        return [];
      }
    } else {
      throw Exception(
          'Failed to load records with status: ${response.statusCode}');
    }
  }

  Future<List<ReasonDropdownModel>> fetchReasonItems() async {
    // Ganti URL dengan endpoint API Anda
    final url = Uri.parse("${AppConfig.baseUrl}/api/reason-list/all/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse JSON data
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => ReasonDropdownModel.fromJson(item)).toList();
      } else {
        // Jika status code bukan 200, lemparkan error
        throw Exception(
            'Failed to load data: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      // Tangkap error jaringan atau parsing
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<NgDropdownModel>> fetchNgList(String idProses) async {
    final url = Uri.parse(
        "${AppConfig.baseUrl}/api/ng-list/active/?id_proses=$idProses");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['results'];

        return data.map((item) => NgDropdownModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load NG list: $e');
    }
  }

  // Memuat data dari Server RestAPI untuk dimasukan kedalam state

  void _loadData() async {
    try {
      List<ReasonDropdownModel> items = await fetchReasonItems();
      setState(() {
        _reasonItems =
            items; // Mengupdate state dengan data yang berhasil diambil
      });

      List<NgDropdownModel> itemsNg = await fetchNgList('001');
      setState(() {
        _ngItems =
            itemsNg; // Mengupdate state dengan data yang berhasil diambil
      });
    } catch (e) {
      logPrint('Error fetching data: $e');
    }
  }

  void _validateInputs() {
    final isDropdownSelected = selectedNgItemObject != null;
    final isQtyValid = ngQtyController.text.trim().isNotEmpty &&
        int.tryParse(ngQtyController.text.trim()) != null &&
        int.parse(ngQtyController.text.trim()) > 0;

    setState(() {
      isAddButtonEnabled = isDropdownSelected && isQtyValid;
    });
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

      // 📌 Step 2: Validasi panjang QRCode Employee (8 digit)
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

  Future<void> createRecordPending(
    String idRecordApi,
    String idReasonApi,
    String idEmployeeApi,
    String idProsesApi,
    String bcodeApi,
  ) async {
    try {
      var response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/create-record-pending/"),
        body: {
          "id_record": idRecordApi,
          "id_reason": idReasonApi,
          "id_employee": idEmployeeApi,
          "id_proses": idProsesApi,
          "bcode": bcodeApi,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);

        if (!mounted) return;
        CustomSnackbar.show(
          context,
          responseData["message"],
          isSuccess: true,
        );

        if (context.mounted) {
          Navigator.pop(
              context, true); // Balik ke list dan beri sinyal "perlu refresh"
        }
      } else {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Failed to create record. Try again!",
          isSuccess: false,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        context,
        "An error occurred: $e",
        isSuccess: false,
      );
    }
  }

  void submitDataStop(String idRecord, String selectedReasonCode,
      String idEmployee, String idProses, String bcode) {
    if (selectedReasonCode.isEmpty) {
      CustomSnackbar.show(
        context,
        "Please select reason stop!.",
        isSuccess: false,
      );

      return;
    } else if (employeeIdConfirm.isEmpty) {
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
      createRecordPending(
          idRecord, selectedReasonCode, idEmployee, idProses, bcode);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    recordrunningdetail = fetchRecordData();
    fetchRecordData().then((records) {
      // Jika data berhasil dimuat, setState untuk menyimpan storedEmployeeId
      setState(() {
        if (records.isNotEmpty) {
          storedEmployeeId = records[0]
              .activeEmployee
              .idEmployee; // Menyimpan idEmployee dari data pertama
        }
      });
    });
  }

  @override
  void dispose() {
    currentShootQtyController.dispose();
    super.dispose();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
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
            'ADD REASON STOP',
            style: TextStyle(
                color: Colors.white, fontSize: 20.0, fontFamily: "Montserrat"),
          ),
          centerTitle: true,
          backgroundColor:
              Colors.transparent, // Menjadikan background AppBar transparan
        ),
      ),
    );
    // double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _opacity,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: myAppBar,
        body: FutureBuilder<List<RecordRunningDetailModel>>(
          future: recordrunningdetail,
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

              return SingleChildScrollView(
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  elevation: 4,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: isTablet
                          ? Column(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.idRecord,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      data[0].proses.nameProses,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    data[0].detailsRecord.isNotEmpty
                                        ? Text(
                                            data[0]
                                                .detailsRecord[0]
                                                .bcode
                                                .bcode,
                                            style:
                                                const TextStyle(fontSize: 15),
                                          )
                                        : const Text(
                                            'No bcode',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                    data[0].detailsRecord.isNotEmpty
                                        ? Text(
                                            data[0]
                                                .detailsRecord[0]
                                                .bcode
                                                .productType,
                                            style:
                                                const TextStyle(fontSize: 15),
                                          )
                                        : const Text(
                                            'No product type',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                  ],
                                ),
                              ),

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
                                                color: Colors
                                                    .grey), // Garis luar tabel
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                // Menghitung ukuran gambar berdasarkan persentase lebar layar
                                                double imageWidth = MediaQuery
                                                            .of(context)
                                                        .size
                                                        .width *
                                                    0.16; // 30% dari lebar layar
                                                double imageHeight =
                                                    imageWidth; // Rasio gambar 1:1

                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                  child: Image.network(
                                                    "${AppConfig.baseUrl}/media/img/employee/${data[0].activeEmployee.idEmployee}.png",
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
                                          data[0].activeEmployee.fullName,
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
                                          data[0].activeEmployee.nrp,
                                          style: TextStyle(
                                            fontSize:
                                                14.0, // Smaller size for nrp
                                            color: Colors.grey[
                                                700], // Lighter color for nrp
                                          ),
                                        ),
                                        const SizedBox(
                                            height: 5.0), // Space between lines
                                        // Section with medium size
                                        Text(
                                          data[0]
                                              .activeEmployee
                                              .section
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize:
                                                16.0, // Medium size for section
                                            fontWeight: FontWeight
                                                .w400, // Slightly bold for section
                                            color: Colors
                                                .grey[700], // Darker text color
                                          ),
                                        ),
                                        const SizedBox(
                                            height: 5.0), // Space between lines
                                        // Division with smaller font size
                                        Text(
                                          data[0]
                                              .activeEmployee
                                              .division
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize:
                                                16.0, // Smaller size for division
                                            fontWeight: FontWeight
                                                .w400, // Normal weight for division
                                            color: Colors.grey[
                                                700], // Lighter text color
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Text Section

                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      color: Colors.grey[
                                          90], // warna biru tipis sebagai background
                                      padding: const EdgeInsets.all(
                                          8.0), // beri padding supaya teks gak mepet

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors
                                                      .white), // Garis luar tabel
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              children: [
                                                // Bagian kiri untuk Table
                                                Expanded(
                                                  flex:
                                                      7, // 70% dari total layar
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
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
                                                                  EdgeInsets
                                                                      .all(6.0),
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
                                                                  EdgeInsets
                                                                      .all(6.0),
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
                                                                        .detailsRecord
                                                                        .isNotEmpty
                                                                    ? data[0]
                                                                        .detailsRecord[
                                                                            0]
                                                                        .jobNumber
                                                                    : '',
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
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
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text(
                                                                'BCODE',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                            ),
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
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
                                                                        .detailsRecord
                                                                        .isNotEmpty
                                                                    ? data[0]
                                                                        .detailsRecord[
                                                                            0]
                                                                        .bcode
                                                                        .bcode
                                                                    : '',
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
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
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text(
                                                                  'MACHINE',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left),
                                                            ),
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text(':',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text(data[
                                                                      0]
                                                                  .activeMachine
                                                                  .nmMc),
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
                                                                      .all(6.0),
                                                              child: Text('QTY',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left),
                                                            ),
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
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
                                                                        .detailsRecord
                                                                        .isNotEmpty
                                                                    ? data[0]
                                                                        .detailsRecord[
                                                                            0]
                                                                        .startQty
                                                                        .toString()
                                                                    : '',
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
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text(
                                                                  'SHOOT QTY',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left),
                                                            ),
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
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
                                                                        .detailsRecord
                                                                        .isNotEmpty
                                                                    ? data[0]
                                                                        .detailsRecord[
                                                                            0]
                                                                        .shootQty
                                                                        .toString()
                                                                    : '',
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
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text(
                                                                  'START TIME',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left),
                                                            ),
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
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
                                                                _formatDateTime(data[
                                                                        0]
                                                                    .startTime
                                                                    .toString()),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black87,
                                                                ),
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
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text(
                                                                  'STATUS PROCESS',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left),
                                                            ),
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text(':',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text((data[
                                                                          0]
                                                                      .runStatus)
                                                                  .toUpperCase()),
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
                                                                      .all(6.0),
                                                              child: Text(
                                                                  'CONFIRM EMPLOYEE',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left),
                                                            ),
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text(':',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Text(
                                                                  employeeName),
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
                                          const SizedBox(height: 10.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 12),
                                child: DropdownSearch<ReasonDropdownModel>(
                                  items: (f, cs) => _reasonItems,
                                  itemAsString: (ReasonDropdownModel? item) =>
                                      item?.nameReason ?? '',
                                  compareFn: (ReasonDropdownModel? a,
                                          ReasonDropdownModel? b) =>
                                      a?.idReason == b?.idReason,
                                  onChanged: (ReasonDropdownModel? selected) {
                                    if (selected != null) {
                                      setState(() {
                                        selectedReasonItemObject = selected;
                                        selectedReasonCode = selected.idReason;
                                        selectedReasonItem =
                                            selected.nameReason;

                                        if (selected.idReason != '03') {
                                          ngDataList.clear();
                                          selectedNgItemObject = null;
                                          selectedNgCode = null;
                                          selectedNgName = null;
                                          ngQtyController.clear();
                                        }
                                      });
                                      // print('Selected: ${selected.idReason} - ${selected.nameReason}');
                                    }
                                  },
                                  decoratorProps: const DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: "CHOOSE REASON",
                                      hintText: "CHOOSE REASON",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    itemBuilder: (context, item, isDisabled,
                                        isSelected) {
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 10.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        elevation: 2,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue,
                                                Colors.blue.shade800,
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: ListTile(
                                              title: Text(
                                                item.nameReason,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 24,
                                                  color: Colors.white,
                                                  letterSpacing: 2.5,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop(item);
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    scrollbarProps: const ScrollbarProps(
                                      trackVisibility: true,
                                      thumbVisibility: true,
                                    ),
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                    ),
                                    menuProps: const MenuProps(
                                      margin: EdgeInsets.only(top: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ✅ 3 Tombol sejajar di 1 Row
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: _buildCustomButton(
                                        text: 'SUBMIT',
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade800,
                                            Colors.blue.shade900
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        height: 80,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        onPressed: () async {
                                          if (employeeIdConfirm.isEmpty) {
                                            CustomSnackbar.show(
                                              context,
                                              "Please scan Employee QRCode!",
                                              isSuccess: false,
                                            );

                                            return;
                                          } else if (employeeIdConfirm !=
                                              storedEmployeeId) {
                                            CustomSnackbar.show(
                                              context,
                                              "Employee Confirm does not match!",
                                              isSuccess: false,
                                            );

                                            return;
                                          }

                                          //JIKA PILIHANNYA ADALAH PERGANTIAN OPERATOR********************
                                          if (selectedReasonItemObject
                                                  ?.idReason ==
                                              '03') {
                                            final currentShootText =
                                                currentShootQtyController.text
                                                    .trim();

                                            if (currentShootText.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: const EdgeInsets.only(
                                                      top: 20,
                                                      left: 20,
                                                      right: 20),
                                                  content: const Text(
                                                    'Harap lengkapi data current Shoot.',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            final int shootQty = int.tryParse(
                                                    currentShootText) ??
                                                0;

                                            List<Map<String, dynamic>> ngData =
                                                ngDataList
                                                    .where((item) =>
                                                        item["id_ng"] != null)
                                                    .map((item) => {
                                                          "id_ng":
                                                              item["id_ng"],
                                                          "qty": int.tryParse(
                                                                  item["qty"] ??
                                                                      "0") ??
                                                              0,
                                                          "id_employee_finish":
                                                              item["idEmployee"] ??
                                                                  '',
                                                          "jobnumber": item[
                                                                  "jobnumber"] ??
                                                              '',
                                                        })
                                                    .toList();

                                            try {
                                              final response = await http.post(
                                                Uri.parse(
                                                    '${AppConfig.baseUrl}/api/submit-change-operator/'),
                                                headers: {
                                                  'Content-Type':
                                                      'application/json'
                                                },
                                                body: jsonEncode({
                                                  "id_record": widget.idRecord,
                                                  "id_reason":
                                                      selectedReasonCode ?? '',
                                                  "id_employee": data[0]
                                                      .activeEmployee
                                                      .idEmployee,
                                                  "id_proses":
                                                      data[0].proses.idProses,
                                                  "bcode": data[0]
                                                      .detailsRecord[0]
                                                      .bcode
                                                      .bcode,
                                                  "shoot_qty": shootQty,
                                                  "ng_data": ngData
                                                }),
                                              );

                                              if (response.statusCode == 200) {
                                                setState(() {
                                                  ngDataList.clear();
                                                  currentShootQtyController
                                                      .clear();
                                                });

                                                CustomSnackbar.show(
                                                  context,
                                                  "Change Operator Successfully",
                                                  isSuccess: true,
                                                );

                                                Navigator.pop(context);

                                                if (context.mounted) {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context,
                                                              animation,
                                                              secondaryAnimation) =>
                                                          RecordRunning(
                                                              title: 'RUNNING',
                                                              idProses: '001'),
                                                      transitionsBuilder:
                                                          (context,
                                                              animation,
                                                              secondaryAnimation,
                                                              child) {
                                                        const curve =
                                                            Curves.easeIn;
                                                        var tween = Tween<
                                                                    double>(
                                                                begin: 0.0,
                                                                end: 1.0)
                                                            .chain(CurveTween(
                                                                curve: curve));
                                                        var opacityAnimation =
                                                            animation
                                                                .drive(tween);
                                                        return FadeTransition(
                                                            opacity:
                                                                opacityAnimation,
                                                            child: child);
                                                      },
                                                      transitionDuration:
                                                          const Duration(
                                                              milliseconds:
                                                                  1200),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                CustomSnackbar.show(
                                                  context,
                                                  "Gagal submit: ${response.body}",
                                                  isSuccess: false,
                                                );
                                              }
                                            } catch (e) {
                                              CustomSnackbar.show(
                                                context,
                                                "Error: $e",
                                                isSuccess: false,
                                              );
                                            }
                                          } else {
                                            submitDataStop(
                                              widget.idRecord,
                                              selectedReasonCode ?? '',
                                              data[0].activeEmployee.idEmployee,
                                              data[0].proses.idProses,
                                              data[0].detailsRecord.isNotEmpty
                                                  ? data[0]
                                                      .detailsRecord[0]
                                                      .bcode
                                                      .bcode
                                                  : '',
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: _buildCustomButton(
                                      text: 'CANCEL',
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.shade800,
                                          Colors.red.shade900
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      height: 80,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      onPressed: _closeDialog,
                                    )),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: _buildCustomButton(
                                      text: 'CONFIRM',
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue[500]!,
                                          Colors.blue[800]!
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      height: 80,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      onPressed: scanQrCodeEmployee,
                                    )),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              if (selectedReasonItemObject?.idReason ==
                                  '03') ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: TextField(
                                              controller:
                                                  currentShootQtyController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly, // hanya digit
                                                LengthLimitingTextInputFormatter(
                                                    5), // maksimal 5 digit
                                                NoLeadingZeroFormatter(), // tidak boleh mulai 0
                                              ],
                                              decoration: InputDecoration(
                                                labelText: 'SHOOTS',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 4,
                                            child:
                                                DropdownSearch<NgDropdownModel>(
                                              selectedItem:
                                                  selectedNgItemObject,
                                              items: (f, cs) => _ngItems,
                                              itemAsString:
                                                  (NgDropdownModel? item) =>
                                                      item?.ngName ?? '',
                                              compareFn: (NgDropdownModel? a,
                                                      NgDropdownModel? b) =>
                                                  a?.idNg == b?.idNg,
                                              onChanged:
                                                  (NgDropdownModel? selected) {
                                                if (selected != null) {
                                                  setState(() {
                                                    selectedNgItemObject =
                                                        selected;
                                                    selectedNgCode =
                                                        selected.idNg;
                                                    selectedNgName =
                                                        selected.ngName;
                                                  });

                                                  _validateInputs();
                                                  // print('Selected: ${selected.idNg} - ${selected.ngName}');
                                                }
                                              },
                                              decoratorProps:
                                                  const DropDownDecoratorProps(
                                                decoration: InputDecoration(
                                                  labelText: "CHOOSE NG",
                                                  hintText: "CHOOSE NG",
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              popupProps: PopupProps.menu(
                                                showSearchBox: true,
                                                itemBuilder: (context, item,
                                                    isDisabled, isSelected) {
                                                  return Card(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 10.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                    ),
                                                    elevation: 2,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Colors.blue,
                                                            Colors
                                                                .blue.shade800,
                                                          ],
                                                          begin: Alignment
                                                              .bottomCenter,
                                                          end: Alignment
                                                              .topCenter,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8.0),
                                                        child: ListTile(
                                                          title: Text(
                                                            item.ngName,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white,
                                                              letterSpacing: 2,
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(item);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                scrollbarProps:
                                                    const ScrollbarProps(
                                                  trackVisibility: true,
                                                  thumbVisibility: true,
                                                ),
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.7,
                                                ),
                                                menuProps: const MenuProps(
                                                  margin:
                                                      EdgeInsets.only(top: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(4)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 1,
                                            child: TextField(
                                              onChanged: (_) =>
                                                  _validateInputs(),
                                              controller: ngQtyController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    5),
                                                NoLeadingZeroFormatter(),
                                              ],
                                              decoration: InputDecoration(
                                                labelText: 'QTY NG',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 18),
                                              backgroundColor:
                                                  Colors.blue.shade800,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .zero, // tanpa radius
                                              ),
                                            ),
                                            onPressed: isAddButtonEnabled
                                                ? () {
                                                    final String idNg =
                                                        selectedNgItemObject
                                                                ?.idNg ??
                                                            '';
                                                    final String ngName =
                                                        selectedNgItemObject
                                                                ?.ngName ??
                                                            '';
                                                    final String qtyText =
                                                        ngQtyController.text;
                                                    final int qty =
                                                        int.tryParse(qtyText) ??
                                                            0;
                                                    final String jobnumber =
                                                        data[0]
                                                                .detailsRecord
                                                                .isNotEmpty
                                                            ? data[0]
                                                                .detailsRecord[
                                                                    0]
                                                                .jobNumber
                                                            : '';

                                                    final String idEmploFinish =
                                                        data[0]
                                                            .activeEmployee
                                                            .idEmployee;

                                                    final String idRecord =
                                                        data[0]
                                                                .idRecord
                                                                .isNotEmpty
                                                            ? data[0].idRecord
                                                            : '';

                                                    if (idNg.isEmpty ||
                                                        ngName.isEmpty ||
                                                        qty <= 0 ||
                                                        jobnumber.isEmpty) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                "Please select NG, enter valid quantity, and jobnumber")),
                                                      );
                                                      return;
                                                    }

                                                    setState(() {
                                                      final existingIndex =
                                                          ngDataList.indexWhere(
                                                              (item) =>
                                                                  item[
                                                                      'id_ng'] ==
                                                                  idNg);

                                                      if (existingIndex != -1) {
                                                        final existingQty =
                                                            int.tryParse(ngDataList[
                                                                            existingIndex]
                                                                        [
                                                                        'qty'] ??
                                                                    '0') ??
                                                                0;
                                                        ngDataList[existingIndex]
                                                                ['qty'] =
                                                            (existingQty + qty)
                                                                .toString();
                                                      } else {
                                                        ngDataList.add({
                                                          'id_ng': idNg,
                                                          'ngName': ngName,
                                                          'qty': qty.toString(),
                                                          'idRecord': idRecord,
                                                          'idEmployee':
                                                              idEmploFinish,
                                                          'jobnumber':
                                                              jobnumber,
                                                        });
                                                      }

                                                      selectedNgItemObject =
                                                          null;
                                                      selectedNgCode = null;
                                                      selectedNgName = null;
                                                      ngQtyController.clear();
                                                      _validateInputs();

                                                      // Debug print cek list
                                                      // print("NG Data List setelah ADD:");

                                                      for (var item
                                                          in ngDataList) {
                                                        print(
                                                            "id_ng: ${item['id_ng']}, ngName: ${item['ngName']}, qty: ${item['qty']},idRecord: ${item['idRecord']},idEmployee: ${item['idEmployee']}, jobnumber: ${item['jobnumber']}");
                                                      }
                                                    });
                                                  }
                                                : null,
                                            child: const Text(
                                              'ADD',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      18 // warna teks putih
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      // Tabel data NG
                                      Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 2.0),
                                        width: double
                                            .infinity, // ✅ agar selebar layar
                                        height:
                                            500, // atur tinggi sesuai kebutuhan laya
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: DataTable(
                                            headingRowColor:
                                                WidgetStateProperty.all(
                                                    Colors.blue.shade800),
                                            columnSpacing: 32,
                                            columns: const [
                                              DataColumn(
                                                label: SizedBox(
                                                  width: 40, // Lebar kolom NO
                                                  child: Text(
                                                    'NO',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: SizedBox(
                                                  width:
                                                      200, // Lebar kolom NAME OF TYPE NG
                                                  child: Text(
                                                    'NAME OF TYPE NG',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: SizedBox(
                                                  width: 60, // Lebar kolom QTY
                                                  child: Text(
                                                    'QTY',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: SizedBox(
                                                  width: 60, // Lebar kolom QTY
                                                  child: Text(
                                                    'ID Employee',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: SizedBox(
                                                  width:
                                                      80, // kasih lebar besar agar terdorong kanan
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      'DELETE',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            rows: List.generate(
                                                ngDataList.length, (index) {
                                              final item = ngDataList[index];
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                      Text('${index + 1}')),
                                                  DataCell(
                                                      Text(item['ngName']!)),
                                                  DataCell(Text(item['qty']!)),
/*
                                                  DataCell(
                                                      Text(item['idRecord']!)),
*/

                                                  DataCell(Text(
                                                      item['idEmployee']!)),
                                                  DataCell(
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () {
                                                          setState(() {
                                                            ngDataList.removeAt(
                                                                index); // ✅ Hapus yang benar
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Widget yang ingin ditampilkan jika ID Reason adalah '03'

                                //SAMPAI SINI YAAAA BUAT TANDA ALIAS MARK*****************
                              ]
                            ])
                          : Column(
                              ///////////INI UNTUK TAMPILAN SMARTPHONE*******************************************************************************************************
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      data[0].proses.nameProses,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      data[0].detailsRecord.isNotEmpty
                                          ? data[0].detailsRecord[0].bcode.bcode
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      data[0].detailsRecord.isNotEmpty
                                          ? data[0]
                                              .detailsRecord[0]
                                              .bcode
                                              .drawingNumber
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      data[0].detailsRecord.isNotEmpty
                                          ? data[0]
                                              .detailsRecord[0]
                                              .bcode
                                              .productType
                                          : '',
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              "${AppConfig.baseUrl}/media/img/employee/${data[0].activeEmployee.idEmployee}.png",
                                              width: widthApp * 0.2,
                                              height: heightApp * 0.1,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.person,
                                                      size: 120,
                                                      color: Colors.grey),
                                            ),
                                          ),
                                          SizedBox(height: 5.0),
                                          Text(
                                            data[0].activeEmployee.fullName,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            data[0].activeEmployee.nrp,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            data[0]
                                                .activeEmployee
                                                .section
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            data[0]
                                                .activeEmployee
                                                .division
                                                .toUpperCase(),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5.0),
                                            child: Table(
                                              columnWidths: const {
                                                0: FlexColumnWidth(
                                                    3), // Kolom pertama

                                                1: FlexColumnWidth(
                                                    7), // Kolom kedua
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
                                                      child: Text('ID RECORD',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 10.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ": ${data[0].idRecord}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: const TextStyle(
                                                              fontSize: 10.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
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
                                                      child: Text('JOB NUMBER',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 10.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ": ${data[0].detailsRecord.isNotEmpty ? data[0].detailsRecord[0].jobNumber : ''}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: const TextStyle(
                                                              fontSize: 10.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
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
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 10.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ": ${data[0].detailsRecord.isNotEmpty ? data[0].detailsRecord[0].bcode.bcode : ''}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 10.0)),
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
                                                      child: Text('MACHINE',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 10.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ": ${data[0].activeMachine.nmMc}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 10.0)),
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
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 10.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ": ${data[0].detailsRecord.isNotEmpty ? data[0].detailsRecord[0].startQty.toString() : ''}", //disini ya waktu nya **************************************************************************************************************
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 10.0)),
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
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 10.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ": ${data[0].startTime}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 10.0)),
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
                                                      child: Text('STATUS',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 10.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ": ${data[0].runStatus.toUpperCase()}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 10.0)),
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
                                                      child: Text('CONFIRM',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 10.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ": ${employeeName.toString()}",
                                                          textAlign:
                                                              TextAlign.left,
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

                                SizedBox(height: 10.0),

                                Container(
                                  alignment: Alignment.center,
                                  child: _isloading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : DropdownSearch<ReasonDropdownModel>(
                                          items: (f, cs) => _reasonItems,
                                          itemAsString:
                                              (ReasonDropdownModel? item) =>
                                                  item?.nameReason ?? '',
                                          compareFn: (ReasonDropdownModel? a,
                                                  ReasonDropdownModel? b) =>
                                              a?.idReason == b?.idReason,
                                          onChanged:
                                              (ReasonDropdownModel? selected) {
                                            if (selected != null) {
                                              setState(() {
                                                selectedReasonItemObject =
                                                    selected;
                                                selectedReasonCode =
                                                    selected.idReason;
                                                selectedReasonItem =
                                                    selected.nameReason;
                                              });
                                              print(
                                                  'Selected: ${selected.idReason} - ${selected.nameReason}');
                                            }
                                          },
                                          decoratorProps:
                                              const DropDownDecoratorProps(
                                            decoration: InputDecoration(
                                              labelText: "CHOOSE REASON STOP",
                                              hintText: "CHOOSE REASON",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          popupProps: PopupProps.menu(
                                            itemBuilder: (context, item,
                                                isDisabled, isSelected) {
                                              return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 10.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                ),
                                                elevation:
                                                    2, // Memberikan efek bayangan pada card
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.blue,
                                                        Colors.blue.shade800,
                                                      ],
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment.topCenter,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                    child: ListTile(
                                                      title: Text(
                                                        item.nameReason,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        // Logika jika item di-tap
                                                        Navigator.of(context).pop(
                                                            item); // Tutup menu dan pilih item
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            scrollbarProps:
                                                const ScrollbarProps(
                                              trackVisibility:
                                                  true, // Menghilangkan scrollbar
                                              thumbVisibility:
                                                  true, // Jangan tampilkan indikator scroll
                                            ),
                                            constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.7,
                                            ),
                                            menuProps: const MenuProps(
                                              margin: EdgeInsets.only(top: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4)),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),

                                SizedBox(height: 10.0),

                                SizedBox(height: 10.0),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .transparent, // Menggunakan background transparan
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 15),
                                                  ),
                                                  onPressed: () {
                                                    _closeDialog();
                                                  },
                                                  child: const Text(
                                                    'CANCELSS',
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 15),
                                                  ),
                                                  onPressed: () {
                                                    submitDataStop(
                                                      widget.idRecord,
                                                      selectedReasonCode ?? "",
                                                      data[0]
                                                          .activeEmployee
                                                          .idEmployee,
                                                      data[0].proses.nameProses,
                                                      data[0]
                                                              .detailsRecord
                                                              .isNotEmpty
                                                          ? data[0]
                                                              .detailsRecord[0]
                                                              .bcode
                                                              .bcode
                                                          : '',
                                                    );
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
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        padding: EdgeInsets.all(5),
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
                                              backgroundColor:
                                                  Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15),
                                            ),
                                            onPressed: () {
                                              // scanQrCodeEmployee();
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
                                )

                                ///sini ya
                              ],
                            )),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    IconData? icon,
    Color? color, // Warna solid jika gradient tidak dipakai
    Gradient? gradient,
    double height = 50,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: gradient == null ? color ?? Colors.blue : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Container(
          alignment: Alignment.center,
          height: height,
          width: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: fontSize),
              if (icon != null) const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
