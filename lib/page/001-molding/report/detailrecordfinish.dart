import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/page/001-molding/report/recordfinishdt.dart';
import 'package:intl/intl.dart';
import '../../../model/record_model.dart'; // Import model
import '../../../model/pending_list_by_idrecord.dart';
import '../../../model/recordng.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_provider_data/config/app_config.dart';

class DetailRecordFinish extends StatefulWidget {
  final String title;
  final String idRecord;
  const DetailRecordFinish(
      {Key? key, required this.title, required this.idRecord})
      : super(key: key);

  @override
  _DetailRecordFinishState createState() => _DetailRecordFinishState();
}

class _DetailRecordFinishState extends State<DetailRecordFinish> {
  DateTime jobDate = DateTime.now();
  late String formattedDate = DateFormat('d MMMM yyyy').format(jobDate);

  List<Map<String, dynamic>> ngTableData = [];
  List<Map<String, dynamic>> reasonTableData = [];
  RecordModel? _record;
  bool _isLoading = true;
  String? _error;
  late Future<List<PendingListByIdrecord>> futurePendingList;
  late Future<List<RecordNg>> futureRecordNg;
  int totalTypeNg = 0; // Total type of NG
  int totalTypePending = 0;

// ##THIS FOR INIT STATE APPLICATION******
  @override
  void initState() {
    super.initState();
    _fetchRecordById();
    futurePendingList = _fetchPendingList();
    futureRecordNg = _fetchNgList();
  }

  Future<void> _fetchRecordById() async {
    try {
      final response = await http.get(Uri.parse(
          "${AppConfig.baseUrl}/api/record-detail/${widget.idRecord}/"));

      if (response.statusCode == 200) {
        setState(() {
          _record = RecordModel.fromJson(jsonDecode(response.body));
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load employee";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<PendingListByIdrecord>> _fetchPendingList() async {
    final response = await http.get(Uri.parse(
        "${AppConfig.baseUrl}/api/pending-list/?id_record=${widget.idRecord}"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return PendingListByIdrecord.fromJsonList(data);
    } else {
      throw Exception("Failed to load data");
    }
  }

  Future<List<RecordNg>> _fetchNgList() async {
    final response = await http
        .get(Uri.parse("${AppConfig.baseUrl}/api/recordng/${widget.idRecord}"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return RecordNg.fromJsonList(data);
    } else if (response.statusCode == 404) {
      // Menangani response 404 dengan menampilkan pesan dari response API
      var errorResponse = jsonDecode(response.body);
      String errorMessage = errorResponse["detail"];
      throw Exception(
          errorMessage); // Lempar exception dengan pesan error dari API
    } else {
      // Penanganan error lain (misal 500 atau lainnya)
      throw Exception("Failed to load data: ${response.statusCode}");
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString)
          .toLocal(); // Parse UTC time and convert to local time

      // Format the DateTime to local Japan Standard Time (JST)
      return DateFormat('HH:mm yyyy-MM-dd')
          .format(dateTime); // Format to desired string format
    } catch (e) {
      return dateTimeString; // Return the original string if parsing fails
    }
  }

  // ##THIS FOR SCANNING QRCODE MACHINE*******************************************

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    double heightApp = MediaQuery.of(context).size.height;
    double paddingTop = MediaQuery.of(context).padding.top;
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
            'DATA RECORD DETAIL',
            style: TextStyle(
                color: Colors.white, fontSize: 20.0, fontFamily: "Montserrat"),
          ),
          centerTitle: true,
          backgroundColor:
              Colors.transparent, // Menjadikan background AppBar transparan
        ),
      ),
    );
    double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    return Scaffold(
      appBar: myAppBar,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _record == null
                  ? Center(child: Text("Karyawan tidak ditemukan"))
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: isTablet
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  //KOLOM CONTAINER KE(1)

                                  Container(
                                    //Container paling atas untuk informasi poto dan sebagainya..
                                    // color: const Color(0xFFF8F9FA),
                                    color: Colors.blue[100],
                                    // color: const Color(0xFFF8F9FA), // Warna biru untuk container
                                    padding: const EdgeInsets.all(
                                        10.0), // Memberikan padding di sekitar isi container
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(10.0),
                                            color: Colors.blueAccent[100],
                                            // color: const Color(0xFF90e0ef),

                                            child: Row(children: [
                                              Container(
                                                width: 170.0, // Ukuran gambar
                                                height: 200.0, // Ukuran gambar
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5), // Kelengkungan sudut gambar
                                                  border: Border.all(
                                                    color: Colors
                                                        .white, // Warna border putih
                                                    width: 1.0, // Lebar border
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0), // Kelengkungan sudut gambar
                                                  child: Image.network(
                                                    "${AppConfig.baseUrl}/media/img/employee/${_record!.idEmployee}.png", // Gambar dari URL
                                                    fit: BoxFit
                                                        .cover, // Menyesuaikan gambar agar memenuhi container
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5.0),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Nama
                                                  Text(
                                                    _record!
                                                        .idEmployee.fullName,
                                                    style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .white, // Warna teks putih agar kontras dengan latar belakang biru
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5.0),
                                                  Text(
                                                    _record!.idEmployee.nrp,
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors
                                                          .white70, // Warna teks lebih terang untuk jabatan
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5.0),
                                                  Text(
                                                    _record!.idEmployee.division
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors
                                                          .white70, // Warna teks lebih terang untuk jabatan
                                                    ),
                                                  ),

                                                  Text(
                                                    _record!.idEmployee.section
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors
                                                          .white70, // Warna teks lebih terang untuk jabatan
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]),

                                            // SizedBox(width: 10.0), // Spasi antar gambar dan teks

                                            // Kolom kiri untuk teks (Nama dan Jabatan)
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        // Bagian kanan: Informasi lainnya (jenis kelamin, pekerjaan, hobi)
                                        Expanded(
                                          child: Container(
                                            color: Colors.white,
                                            padding: const EdgeInsets.all(5.0),
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5.0),
                                                child: Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(
                                                        1), // Kolom pertama
                                                    1: FixedColumnWidth(
                                                        8), // Kolom untuk ":"
                                                    2: FlexColumnWidth(
                                                        2), // Kolom kedua
                                                  },
                                                  children: [
                                                    // Baris pertama dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade200, // Warna latar belakang untuk baris pertama
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .grey)),
                                                      ),
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
                                                                  fontSize:
                                                                      12.0,
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
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              widget.idRecord,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ],
                                                    ),
                                                    // Baris kedua dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .white, // Warna latar belakang untuk baris kedua
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .grey)),
                                                      ),
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
                                                                  fontSize:
                                                                      12.0)),
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
                                                            _record!.detailsRecord
                                                                    .isNotEmpty
                                                                ? _record!
                                                                    .detailsRecord[
                                                                        0]
                                                                    .jobNumber
                                                                : 'No job number',
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Baris ketiga dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade200, // Warna latar belakang untuk baris ketiga
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .grey)),
                                                      ),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              'DRAW NUMBER',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
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
                                                              _record!.detailsRecord
                                                                      .isNotEmpty
                                                                  ? _record!
                                                                      .detailsRecord[
                                                                          0]
                                                                      .bcode
                                                                      .kode
                                                                  : 'No bcode',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12.0)),
                                                        ),
                                                      ],
                                                    ),
                                                    // Baris keempat dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .white, // Warna latar belakang untuk baris keempat
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .grey)),
                                                      ),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                              'PRODUCT TYPE',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
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
                                                              _record!.detailsRecord
                                                                      .isNotEmpty
                                                                  ? _record!
                                                                      .detailsRecord[
                                                                          0]
                                                                      .bcode
                                                                      .productType
                                                                  : 'Product Type',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12.0)),
                                                        ),
                                                      ],
                                                    ),
                                                    // Baris kelima dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade200, // Warna latar belakang untuk baris kelima
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .grey)),
                                                      ),
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
                                                                  fontSize:
                                                                      12.0)),
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
                                                              _record!
                                                                  .idMc.nmMc,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12.0)),
                                                        ),
                                                      ],
                                                    ),
                                                    // Baris keenam dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .white, // Warna latar belakang untuk baris keenam
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .grey)),
                                                      ),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text('PROCESS',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
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
                                                              _record!.idProses
                                                                  .nameProses,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12.0)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 10.0),
                                  //*********************************************************************************************************** */
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment
                                            .topCenter, // Mulai dari kiri atas
                                        end: Alignment
                                            .bottomCenter, // Ke kanan bawah
                                        colors: [
                                          Colors.blue.shade300,
                                          Colors.blue.shade700
                                        ], // Warna gradasi
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "START  ${_record!.startTime}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.cyanAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          "FINISH  ${_record!.finishTime}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.cyanAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 20.0),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10.0),

                                  //KOLOM CONTAINER KE(2)
                                  Container(
                                    color: Colors.blue[100],
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      //Row ini membagi konten menjadi 2 bagian

                                      children: [
                                        // Left Column
                                        Expanded(
                                          // Expanded kolom kiri
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5.0,
                                                vertical:
                                                    20.0), // Padding atas & bawah
                                            color: Colors.grey[50],
                                            child: Column(
                                              children: [
                                                Table(
                                                  border: TableBorder(
                                                    horizontalInside: BorderSide
                                                        .none, // Menghilangkan garis horizontal di dalam tabel
                                                    verticalInside: BorderSide
                                                        .none, // Menghilangkan garis vertikal di dalam tabel
                                                  ),
                                                  children: [
                                                    // Baris pertama dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade200, // Warna latar belakang untuk baris pertama
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1.0),
                                                        ),
                                                      ),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              "START QTY",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            _record!.detailsRecord
                                                                    .isNotEmpty
                                                                ? _record!
                                                                    .detailsRecord[
                                                                        0]
                                                                    .startQty
                                                                    .toString()
                                                                : 'No data',
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Baris kedua dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .white, // Warna latar belakang untuk baris kedua
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1.0),
                                                        ),
                                                      ),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              "NG PRODUCT",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            _record!.detailsRecord
                                                                    .isNotEmpty
                                                                ? _record!
                                                                    .detailsRecord[
                                                                        0]
                                                                    .qtyNg
                                                                    .toString()
                                                                : 'No data',
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Baris ketiga dengan warna latar belakang

                                                    // Baris keempat dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade200, // Warna latar belakang untuk baris keempat
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1.0),
                                                        ),
                                                      ),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              "CYCLE TIME",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ":${_record!.cycleTime}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .white, // Warna latar belakang untuk baris keempat
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1.0),
                                                        ),
                                                      ),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              "DOWNTIME",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ":${_record!.totalPending}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 15.0),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5.0,
                                                      vertical: 25.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.lightBlue[50],
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center, // Agar tombol berada di tengah
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            // print("okelah");
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5), // Sudut melengkung
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  Colors.blue,
                                                                  Colors.blue
                                                                      .shade800,
                                                                ], // Warna gradien
                                                                begin: Alignment
                                                                    .topCenter,
                                                                end: Alignment
                                                                    .bottomCenter,
                                                              ),
                                                            ),
                                                            child:
                                                                ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent, // Menggunakan transparan karena gradien sudah di Ink
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5), // Sudut melengkung
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        30), // Padding lebih tinggi untuk menambah tinggi tombol
                                                              ),
                                                              onPressed: () {
                                                                // Tombol ini tidak perlu onPressed lagi karena InkWell menangani tap
                                                                Navigator
                                                                    .pushReplacement(
                                                                  context,
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (context,
                                                                            animation,
                                                                            secondaryAnimation) =>
                                                                        const Menu(
                                                                            kode:
                                                                                '001',
                                                                            proses:
                                                                                'MOULDING'),
                                                                    transitionsBuilder: (context,
                                                                        animation,
                                                                        secondaryAnimation,
                                                                        child) {
                                                                      const curve =
                                                                          Curves
                                                                              .easeIn;
                                                                      var tween = Tween<double>(
                                                                              begin: 0.0,
                                                                              end: 1.0)
                                                                          .chain(CurveTween(curve: curve));
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
                                                              child: const Text(
                                                                'HOME',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      25.0,
                                                                  color: Colors
                                                                      .white, // Warna teks putih
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                          width:
                                                              5), // Memberi jarak antar tombol
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        //Batas end Expanded kolom kiri sampai sini///

                                        const SizedBox(width: 2.0),
                                        // Right Column
                                        Expanded(
                                          //Expanded  kolom kanan dari sini //
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5.0,
                                                vertical:
                                                    20.0), // Padding atas & bawah
                                            color: Colors.grey[50],
                                            child: Column(
                                              children: [
                                                Table(
                                                  border: TableBorder(
                                                    horizontalInside: BorderSide
                                                        .none, // Menghilangkan garis horizontal di dalam tabel
                                                    verticalInside: BorderSide
                                                        .none, // Menghilangkan garis vertikal di dalam tabel
                                                  ),
                                                  children: [
                                                    // Baris pertama dengan warna latar belakang

                                                    // Baris kedua dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade200, // Warna latar belakang untuk baris kedua
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1.0),
                                                        ),
                                                      ),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              "FINISH QTY",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            _record!.detailsRecord
                                                                    .isNotEmpty
                                                                ? _record!
                                                                    .detailsRecord[
                                                                        0]
                                                                    .startQty
                                                                    .toString()
                                                                : 'No data',
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Baris ketiga dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .white, // Warna latar belakang untuk baris ketiga
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1.0),
                                                        ),
                                                      ),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              "GOOD PRODUCT",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            _record!.detailsRecord
                                                                    .isNotEmpty
                                                                ? _record!
                                                                    .detailsRecord[
                                                                        0]
                                                                    .finishQty
                                                                    .toString()
                                                                : 'No data',
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Baris keempat dengan warna latar belakang
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade200, // Warna latar belakang untuk baris keempat
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.white,
                                                              width: 1.0),
                                                        ),
                                                      ),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              "TOTAL TIME",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ":${_record!.totalTime}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                      ],
                                                    ),

                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .white, // Warna latar belakang untuk baris ketiga
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1.0),
                                                        ),
                                                      ),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              "QTY NG TYPE",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${totalTypeNg.toString()}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 15.0),

                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5.0,
                                                      vertical: 25.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.lightBlue[50],
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center, // Agar tombol berada di tengah
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            // print("okelah");
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5), // Sudut melengkung
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  Colors.blue,
                                                                  Colors.blue
                                                                      .shade800,
                                                                ], // Warna gradien
                                                                begin: Alignment
                                                                    .topCenter,
                                                                end: Alignment
                                                                    .bottomCenter,
                                                              ),
                                                            ),
                                                            child:
                                                                ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent, // Menggunakan transparan karena gradien sudah di Ink
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5), // Sudut melengkung
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        30), // Padding lebih tinggi untuk menambah tinggi tombol
                                                              ),
                                                              onPressed: () {
                                                                // Tombol ini tidak perlu onPressed lagi karena InkWell menangani tap
                                                                Navigator
                                                                    .pushReplacement(
                                                                  context,
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (context,
                                                                            animation,
                                                                            secondaryAnimation) =>
                                                                        const RecordFinishDt(
                                                                            title:
                                                                                'MOULD FINISH'),
                                                                    transitionsBuilder: (context,
                                                                        animation,
                                                                        secondaryAnimation,
                                                                        child) {
                                                                      const curve =
                                                                          Curves
                                                                              .easeIn;
                                                                      var tween = Tween<double>(
                                                                              begin: 0.0,
                                                                              end: 1.0)
                                                                          .chain(CurveTween(curve: curve));
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
                                                              child: const Text(
                                                                'OK',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      25.0,
                                                                  color: Colors
                                                                      .white, // Warna teks putih
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                          width:
                                                              5), // Memberi jarak antar tombol
                                                    ],
                                                  ),
                                                ),

                                                // sampai disini untuk widget potonya///
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ), //Sampai sini Containernya...

                                  const SizedBox(height: 10.0),
                                  //*********************************************************************************************************** */
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment
                                            .topCenter, // Mulai dari kiri atas
                                        end: Alignment
                                            .bottomCenter, // Ke kanan bawah
                                        colors: [
                                          Colors.blue.shade300,
                                          Colors.blue.shade700
                                        ], // Warna gradasi
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "LIST DATA NG MOULDING PROCESS",
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.cyanAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 30.0),
                                        Text(
                                          "TOTAL TYPE NG : ${totalTypeNg.toString()}",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.cyanAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 30.0),
                                        Text(
                                          "TOTAL NG PRODUCT : ${_record!.detailsRecord.isNotEmpty ? _record!.detailsRecord[0].qtyNg.toString() : 'No data'}",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.cyanAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10.0),

                                  //KOLOM CONTAINER KE 3
                                  Container(
                                    color: Colors.blue[100],
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      color: Colors.blue.shade50,
                                      padding: const EdgeInsets.all(10.0),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.15,
                                      child: FutureBuilder<List<RecordNg>>(
                                        future: futureRecordNg,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Error: ${snapshot.error}'));
                                          } else if (!snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            // Cek jika tidak ada data atau data kosong
                                            return Center(
                                                child: Text('NO DATA NG.',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .grey.shade600)));
                                          } else if (snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              snapshot.data == null) {
                                            // Penanganan error ketika data null (termasuk jika status code 404)
                                            return Center(
                                                child: Text(
                                                    'NO DATA NG PROCESS.',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .grey.shade600)));
                                          } else {
                                            // Jika data ada, tampilkan DataTable
                                            List<RecordNg> recordNgs =
                                                snapshot.data!;

                                            // Gunakan WidgetsBinding untuk menunggu hingga build selesai untuk melakuan setState jumlah type NG nya.
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              if (mounted) {
                                                setState(() {
                                                  totalTypeNg = recordNgs
                                                      .length; // Update jumlah data
                                                });
                                              }
                                            });

                                            return SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: Column(children: [
                                                  Container(
                                                    padding: EdgeInsets.all(5),
                                                    width: widthApp,
                                                    child: Table(
                                                      columnWidths: const {
                                                        0: FlexColumnWidth(0.1),
                                                        1: FixedColumnWidth(
                                                            455),
                                                        2: FlexColumnWidth(0.3),
                                                      },
                                                      children: [
                                                        // Header Row
                                                        TableRow(
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border(
                                                                      bottom: BorderSide(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade400)),
                                                                  gradient:
                                                                      LinearGradient(
                                                                    begin: Alignment
                                                                        .topCenter, // Mulai dari kiri atas
                                                                    end: Alignment
                                                                        .bottomCenter, // Ke kanan bawah
                                                                    colors: [
                                                                      Colors
                                                                          .blue
                                                                          .shade300,
                                                                      Colors
                                                                          .blue
                                                                          .shade700
                                                                    ], // Warna gradasi
                                                                  )),
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text('NO',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  'NG NAME',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text('QTY',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                          ],
                                                        ),
                                                        // Data Rows dari List
                                                        ...recordNgs
                                                            .asMap()
                                                            .entries
                                                            .map((entry) {
                                                          int index = entry.key;
                                                          var row = entry.value;
                                                          return TableRow(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: index %
                                                                          2 ==
                                                                      0
                                                                  ? Colors.grey
                                                                      .shade200
                                                                  : Colors
                                                                      .white,
                                                              border: Border(
                                                                  bottom: BorderSide(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade400)),
                                                            ),
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                    (index + 1)
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12.0),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                    row.ngName,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12.0),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                    row.qty
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12.0),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                            ],
                                                          );
                                                        }).toList(),
                                                      ],
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10.0),
                                  //*********************************************************************************************************** */
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment
                                            .topCenter, // Mulai dari kiri atas
                                        end: Alignment
                                            .bottomCenter, // Ke kanan bawah
                                        colors: [
                                          Colors.blue.shade300,
                                          Colors.blue.shade700
                                        ], // Warna gradasi
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "LIST DATA PENDING MOULDING",
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.cyanAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          "TOTAL PENDING PROCESS :${totalTypePending.toString()}",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.cyanAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          "TOTAL DOWNTIME :${_record!.totalPending}",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.cyanAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10.0),

                                  const SizedBox(height: 5.0),
                                  //KOLOM CONTAINER KE 3

                                  Container(
                                    color: Colors.blue[100],
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                        color: Colors.blue.shade50,
                                        padding: const EdgeInsets.all(10.0),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.15,
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: SizedBox(
                                                width: constraints
                                                    .maxWidth, // Memastikan tabel mengisi seluruh lebar
                                                child: FutureBuilder<
                                                    List<
                                                        PendingListByIdrecord>>(
                                                  future: futurePendingList,
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Center(
                                                          child: Text(
                                                              'Error: ${snapshot.error}'));
                                                    } else if (!snapshot
                                                            .hasData ||
                                                        snapshot
                                                            .data!.isEmpty) {
                                                      // Cek jika tidak ada data atau data kosong
                                                      return Center(
                                                          child: Text(
                                                              'NO DATA PENDING.',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      20.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600)));
                                                    } else if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .done &&
                                                        snapshot.data == null) {
                                                      // Penanganan error ketika data null (termasuk jika status code 404)
                                                      return Center(
                                                          child: Text(
                                                              'NO DATA PENDING PROCESS.',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      20.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600)));
                                                    } else {
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        if (mounted) {
                                                          setState(() {
                                                            totalTypePending =
                                                                snapshot.data!
                                                                    .length;
                                                          });
                                                        }
                                                      });

                                                      return Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        width: double.infinity,
                                                        child: Expanded(
                                                          child:
                                                              SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Table(
                                                              columnWidths: const {
                                                                0: FixedColumnWidth(
                                                                    50),
                                                                1: FixedColumnWidth(
                                                                    300),
                                                                2: FixedColumnWidth(
                                                                    155),
                                                                3: FixedColumnWidth(
                                                                    155),
                                                                4: FixedColumnWidth(
                                                                    100),
                                                              },
                                                              children: [
                                                                // Header Row
                                                                TableRow(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border(
                                                                        bottom: BorderSide(
                                                                            color:
                                                                                Colors.grey.shade400)),
                                                                    gradient:
                                                                        LinearGradient(
                                                                      begin: Alignment
                                                                          .topCenter,
                                                                      end: Alignment
                                                                          .bottomCenter,
                                                                      colors: [
                                                                        Colors
                                                                            .blue
                                                                            .shade300,
                                                                        Colors
                                                                            .blue
                                                                            .shade700
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          'NO',
                                                                          style: TextStyle(
                                                                              fontSize: 12.0,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white),
                                                                          textAlign: TextAlign.center),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          'REASON',
                                                                          style: TextStyle(
                                                                              fontSize: 12.0,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white),
                                                                          textAlign: TextAlign.center),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          'START',
                                                                          style: TextStyle(
                                                                              fontSize: 12.0,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white),
                                                                          textAlign: TextAlign.center),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          'FINISH',
                                                                          style: TextStyle(
                                                                              fontSize: 12.0,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white),
                                                                          textAlign: TextAlign.center),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          'DOWNTIME',
                                                                          style: TextStyle(
                                                                              fontSize: 12.0,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white),
                                                                          textAlign: TextAlign.center),
                                                                    ),
                                                                  ],
                                                                ),
                                                                // Data Rows dari List
                                                                ...snapshot
                                                                    .data!
                                                                    .asMap()
                                                                    .entries
                                                                    .map(
                                                                        (entry) {
                                                                  int index =
                                                                      entry.key +
                                                                          1;
                                                                  PendingListByIdrecord
                                                                      data =
                                                                      entry
                                                                          .value;

                                                                  return TableRow(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: index %
                                                                                  2 ==
                                                                              0
                                                                          ? Colors
                                                                              .grey
                                                                              .shade200
                                                                          : Colors
                                                                              .white,
                                                                      border: Border(
                                                                          bottom:
                                                                              BorderSide(color: Colors.grey.shade400)),
                                                                    ),
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child: Text(
                                                                            index
                                                                                .toString(),
                                                                            style:
                                                                                TextStyle(fontSize: 12.0),
                                                                            textAlign: TextAlign.center),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child: Text(
                                                                            data
                                                                                .nameReason,
                                                                            style:
                                                                                TextStyle(fontSize: 12.0),
                                                                            textAlign: TextAlign.left),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child: Text(
                                                                            _formatDateTime(data
                                                                                .startPending),
                                                                            style:
                                                                                TextStyle(fontSize: 12.0),
                                                                            textAlign: TextAlign.center),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child: Text(
                                                                            _formatDateTime(data
                                                                                .finishPending),
                                                                            style:
                                                                                TextStyle(fontSize: 12.0),
                                                                            textAlign: TextAlign.center),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child: Text(
                                                                            data.totalPending
                                                                                .toString(),
                                                                            style:
                                                                                TextStyle(fontSize: 12.0),
                                                                            textAlign: TextAlign.center),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }).toList(),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        )),
                                  ),

                                  const SizedBox(height: 15.0),

                                  Container(
                                    color: const Color(0xFFF8F9FA),
                                    child: Center(
                                        child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(1), // Kolom pertama
                                        1: FixedColumnWidth(
                                            20), // Kolom untuk ":"
                                        2: FlexColumnWidth(2), // Kolom kedua
                                      },
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[
                                                  200], // Warna latar belakang untuk row kedua
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('CUSTOMER',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(':',
                                                  textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(
                                                  _record!.detailsRecord
                                                          .isNotEmpty
                                                      ? _record!
                                                          .detailsRecord[0]
                                                          .bcode
                                                          .nameCompany
                                                      : 'No data',
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors
                                                  .white, // Warna latar belakang untuk row ketiga
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('BCODE',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(':',
                                                  textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(
                                                  _record!.detailsRecord
                                                          .isNotEmpty
                                                      ? _record!
                                                          .detailsRecord[0]
                                                          .bcode
                                                          .kode
                                                      : 'No data',
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[
                                                  200], // Warna latar belakang untuk row pertama
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('MACHINE AREA',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(':',
                                                  textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(_record!.idMc.areaMc,
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors
                                                  .white, // Warna latar belakang untuk row keempat
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('STATUS RUNNING',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(':',
                                                  textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(
                                                  _record!.runStatus
                                                      .toUpperCase(),
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[
                                                  200], // Warna latar belakang untuk row kelima
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('JOB STATUS',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(':',
                                                  textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(
                                                  _record!.jobStatus
                                                      .toUpperCase(),
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors
                                                  .white, // Warna latar belakang untuk row keenam
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('LEADER NAME',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(':',
                                                  textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('CRISTIANO RONALDO',
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                  ),
                                ],
                              ))
                          : Padding(
                              //SAMPAI SINI UNTUK TAMPILAN TABLETNYA**********************************************************************************************
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                children: [
                                  //KOLOM CONTAINER KE(1)
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Left Section: Employee Info & Image
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(2.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  color: Colors.white,
                                                  width: double.infinity,
                                                  child: Center(
                                                    child: LayoutBuilder(
                                                      builder: (context,
                                                          constraints) {
                                                        double imageWidth =
                                                            widthApp * 0.20;
                                                        double imageHeight =
                                                            imageWidth;

                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          child: Image.network(
                                                            "${AppConfig.baseUrl}/media/img/employee/${_record!.idEmployee}.png",
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
                                                  _record!.idEmployee.fullName,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  _record!.idEmployee.nrp,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  _record!.idEmployee.section
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  _record!.idEmployee.division
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        // Right Section: Job Info in a Table
                                        Flexible(
                                          flex: 7,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.7,
                                                ),
                                                child: Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(
                                                        4), // First column

                                                    1: FlexColumnWidth(
                                                        6), // Second column
                                                  },
                                                  children: [
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                            'ID RECORD',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            ": ${_record!.idRecord.toString()}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                            'JOB NUMBER',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            ": ${_record!.detailsRecord.isNotEmpty ? _record!.detailsRecord[0].jobNumber : '-'}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
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
                                                                fontSize: 12,
                                                              )),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${_record!.idMc.nmMc}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                            'QUANTITY',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            ": ${_record!.detailsRecord.isNotEmpty ? _record!.detailsRecord[0].startQty.toString() : '-'}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
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
                                                                fontSize: 12,
                                                              )),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${_record!.startTime.toString()}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Text(
                                                            'FINISH TIME',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                            ": ${_formatDateTime(_record!.finishTime.toString())}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
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
                                                                fontSize: 12,
                                                              )),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Text(
                                                              ": ${_record!.runStatus.toUpperCase()}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                              )),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 5.0),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment
                                            .topCenter, // Mulai dari kiri atas
                                        end: Alignment
                                            .bottomCenter, // Ke kanan bawah
                                        colors: [
                                          Colors.blue.shade300,
                                          Colors.blue.shade700
                                        ], // Warna gradasi
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "START  ${_record?.startTime ?? '-'}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.cyanAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          "FINISH  ${_record!.finishTime ?? '-'}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.cyanAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 20.0),
                                      ],
                                    ),
                                  ),

                                  // SizedBox(height: 10.0),

//Ini batasnya yaaah****************************************************************************************************************************************************
                                  Container(
                                      padding: EdgeInsets.all(5.0),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            flex: 5,
                                            child: Table(
                                              border: TableBorder(
                                                horizontalInside: BorderSide
                                                    .none, // Menghilangkan garis horizontal di dalam tabel
                                                verticalInside: BorderSide
                                                    .none, // Menghilangkan garis vertikal di dalam tabel
                                              ),
                                              children: [
                                                // Baris pertama dengan warna latar belakang

                                                // Baris kedua dengan warna latar belakang
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .white, // Warna latar belakang untuk baris kedua
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0),
                                                    ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text("START QTY",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ":${_record != null && _record!.detailsRecord.isNotEmpty ? _record!.detailsRecord[0].startQty.toString() : '-'}",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                  ],
                                                ),
                                                // Baris ketiga dengan warna latar belakang
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .shade200, // Warna latar belakang untuk baris ketiga
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0),
                                                    ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text("NG",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ":${_record != null && _record!.detailsRecord.isNotEmpty ? _record!.detailsRecord[0].qtyNg.toString() : '-'}",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                  ],
                                                ),
                                                // Baris keempat dengan warna latar belakang
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .white, // Warna latar belakang untuk baris keempat
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0),
                                                    ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text("CYCLE TIME",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ":${_record!.cycleTime}",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                  ],
                                                ),

                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .shade200, // Warna latar belakang untuk baris ketiga
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0),
                                                    ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text("DOWNTIME",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ":${_record!.totalPending}",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 5.0),
                                          Flexible(
                                            flex: 5,
                                            child: Table(
                                              border: TableBorder(
                                                horizontalInside: BorderSide
                                                    .none, // Menghilangkan garis horizontal di dalam tabel
                                                verticalInside: BorderSide
                                                    .none, // Menghilangkan garis vertikal di dalam tabel
                                              ),
                                              children: [
                                                // Baris pertama dengan warna latar belakang

                                                // Baris kedua dengan warna latar belakang
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .white, // Warna latar belakang untuk baris kedua
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0),
                                                    ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text("FINISH QTY",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ":${_record != null && _record!.detailsRecord.isNotEmpty ? _record!.detailsRecord[0].finishQty.toString() : '-'}",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                  ],
                                                ),
                                                // Baris ketiga dengan warna latar belakang
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .shade200, // Warna latar belakang untuk baris ketiga
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0),
                                                    ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text("GOOD",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ":${_record != null && _record!.detailsRecord.isNotEmpty ? _record!.detailsRecord[0].finishQty.toString() : '-'}",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                  ],
                                                ),
                                                // Baris keempat dengan warna latar belakang
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .white, // Warna latar belakang untuk baris keempat
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0),
                                                    ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text("TOTAL TIME",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ":${_record!.totalTime}",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                  ],
                                                ),

                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .shade200, // Warna latar belakang untuk baris ketiga
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0),
                                                    ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text("QTY NG TYPE",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          ":${totalTypeNg.toString()}",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )),

                                  SizedBox(height: 5.0),

                                  //KOLOM CONTAINER KE(2)
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      //Row ini membagi konten menjadi 2 bagian

                                      children: [
                                        // Left Column
                                        Expanded(
                                            // Expanded kolom kiri
                                            child: Container(
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center, // Agar tombol berada di tengah
                                            children: [
                                              Expanded(
                                                  child: Ink(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .transparent, // Menggunakan transparan karena gradien sudah di Ink
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5), // Sudut melengkung
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical:
                                                            10), // Ukuran padding tombol
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      PageRouteBuilder(
                                                        pageBuilder: (context,
                                                                animation,
                                                                secondaryAnimation) =>
                                                            const Menu(
                                                                kode: '001',
                                                                proses:
                                                                    'MOULDING'),
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
                                                                  curve:
                                                                      curve));
                                                          var opacityAnimation =
                                                              animation
                                                                  .drive(tween);

                                                          return FadeTransition(
                                                            opacity:
                                                                opacityAnimation,
                                                            child: child,
                                                          );
                                                        },
                                                        transitionDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    1200),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'HOME',
                                                    style: TextStyle(
                                                      fontSize: 25.0,
                                                      color: Colors
                                                          .white, // Warna teks putih
                                                    ),
                                                  ),
                                                ),
                                              )),
                                            ],
                                          ),
                                        )),

                                        //Batas end Expanded kolom kiri sampai sini///

                                        const SizedBox(width: 2.0),
                                        // Right Column

                                        Expanded(
                                            // Expanded kolom kiri
                                            child: Container(
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center, // Agar tombol berada di tengah
                                            children: [
                                              Expanded(
                                                  child: Ink(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .transparent, // Menggunakan transparan karena gradien sudah di Ink
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5), // Sudut melengkung
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical:
                                                            10), // Ukuran padding tombol
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      PageRouteBuilder(
                                                        pageBuilder: (context,
                                                                animation,
                                                                secondaryAnimation) =>
                                                            const RecordFinishDt(
                                                                title:
                                                                    'MOULD FINISH'),
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
                                                                  curve:
                                                                      curve));
                                                          var opacityAnimation =
                                                              animation
                                                                  .drive(tween);

                                                          return FadeTransition(
                                                            opacity:
                                                                opacityAnimation,
                                                            child: child,
                                                          );
                                                        },
                                                        transitionDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    1200),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'OK',
                                                    style: TextStyle(
                                                      fontSize: 25.0,
                                                      color: Colors
                                                          .white, // Warna teks putih
                                                    ),
                                                  ),
                                                ),
                                              )),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  ), //Sampai sini Containernya...

                                  const SizedBox(height: 5.0),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment
                                            .topCenter, // Mulai dari kiri atas
                                        end: Alignment
                                            .bottomCenter, // Ke kanan bawah
                                        colors: [
                                          Colors.blue.shade300,
                                          Colors.blue.shade700
                                        ], // Warna gradasi
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "LIST DATA NG MOULDING",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.cyanAccent,
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          "TOTAL TYPE NG: ${totalTypeNg.toString()}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.cyanAccent,
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          "TOTAL NG: ${_record != null && _record!.detailsRecord.isNotEmpty ? _record!.detailsRecord[0].qtyNg.toString() : '-'}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.cyanAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  //KOLOM CONTAINER KE 3
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    height: heightBody * 0.2,
                                    child: FutureBuilder<List<RecordNg>>(
                                      future: futureRecordNg,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          // Cek jika tidak ada data atau data kosong
                                          return const Center(
                                              child:
                                                  Text('NO DATA NG PROCESS.'));
                                        } else if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.data == null) {
                                          // Penanganan error ketika data null (termasuk jika status code 404)
                                          return const Center(
                                              child:
                                                  Text('NO DATA NG PROCESS.'));
                                        } else {
                                          // Jika data ada, tampilkan DataTable
                                          List<RecordNg> recordNgs =
                                              snapshot.data!;

                                          // Gunakan WidgetsBinding untuk menunggu hingga build selesai untuk melakuan setState jumlah type NG nya.
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            if (mounted) {
                                              setState(() {
                                                totalTypeNg = recordNgs
                                                    .length; // Update jumlah data
                                              });
                                            }
                                          });

                                          return SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Column(children: [
                                                Container(
                                                  padding: EdgeInsets.all(5),
                                                  width: widthApp,
                                                  child: Table(
                                                    columnWidths: const {
                                                      0: FlexColumnWidth(0.5),
                                                      1: FixedColumnWidth(275),
                                                      2: FlexColumnWidth(0.5),
                                                    },
                                                    children: [
                                                      // Header Row
                                                      TableRow(
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade400)),
                                                                gradient:
                                                                    LinearGradient(
                                                                  begin: Alignment
                                                                      .topCenter, // Mulai dari kiri atas
                                                                  end: Alignment
                                                                      .bottomCenter, // Ke kanan bawah
                                                                  colors: [
                                                                    Colors.blue
                                                                        .shade300,
                                                                    Colors.blue
                                                                        .shade700
                                                                  ], // Warna gradasi
                                                                )),
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text('NO',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                                'NG NAME',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text('QTY',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                        ],
                                                      ),
                                                      // Data Rows dari List
                                                      ...recordNgs
                                                          .asMap()
                                                          .entries
                                                          .map((entry) {
                                                        int index = entry.key;
                                                        var row = entry.value;
                                                        return TableRow(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: index % 2 ==
                                                                    0
                                                                ? Colors.grey
                                                                    .shade200
                                                                : Colors.white,
                                                            border: Border(
                                                                bottom: BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade400)),
                                                          ),
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  (index + 1)
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12.0),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  row.ngName,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12.0),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  row.qty
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12.0),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 5.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment
                                            .topCenter, // Mulai dari kiri atas
                                        end: Alignment
                                            .bottomCenter, // Ke kanan bawah
                                        colors: [
                                          Colors.blue.shade300,
                                          Colors.blue.shade700
                                        ], // Warna gradasi
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "LIST PENDING",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.cyanAccent,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          "TOTAL PENDING: ${totalTypePending.toString()}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.cyanAccent,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Text(
                                          "TOTAL DOWNTIME: ${_record!.totalPending.toString()}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.cyanAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 5.0),
                                  //KOLOM CONTAINER KE 3

                                  Container(
                                      color: Colors.blue.shade50,
                                      padding: const EdgeInsets.all(5.0),
                                      width: widthApp,
                                      height: heightBody * 0.2,
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: SizedBox(
                                              width: constraints
                                                  .maxWidth, // Memastikan tabel mengisi seluruh lebar
                                              child: FutureBuilder<
                                                  List<PendingListByIdrecord>>(
                                                future: futurePendingList,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                        child: Text(
                                                            'Error: ${snapshot.error}'));
                                                  } else if (!snapshot
                                                          .hasData ||
                                                      snapshot.data!.isEmpty) {
                                                    // Cek jika tidak ada data atau data kosong
                                                    return const Center(
                                                        child: Text(
                                                            'NO DATA PENDING PROCESS.'));
                                                  } else if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done &&
                                                      snapshot.data == null) {
                                                    // Penanganan error ketika data null (termasuk jika status code 404)
                                                    return const Center(
                                                        child: Text(
                                                            'NO DATA PENDING PROCESS.'));
                                                  } else {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      if (mounted) {
                                                        setState(() {
                                                          totalTypePending =
                                                              snapshot
                                                                  .data!.length;
                                                        });
                                                      }
                                                    });

                                                    return Container(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Table(
                                                            columnWidths: const {
                                                              0: FixedColumnWidth(
                                                                  50),
                                                              1: FixedColumnWidth(
                                                                  250),
                                                              2: FixedColumnWidth(
                                                                  150),
                                                              3: FixedColumnWidth(
                                                                  150),
                                                              4: FixedColumnWidth(
                                                                  80),
                                                            },
                                                            children: [
                                                              // Header Row
                                                              TableRow(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border(
                                                                      bottom: BorderSide(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade400)),
                                                                  gradient:
                                                                      LinearGradient(
                                                                    begin: Alignment
                                                                        .topCenter,
                                                                    end: Alignment
                                                                        .bottomCenter,
                                                                    colors: [
                                                                      Colors
                                                                          .blue
                                                                          .shade300,
                                                                      Colors
                                                                          .blue
                                                                          .shade700
                                                                    ],
                                                                  ),
                                                                ),
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'NO',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12.0,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .white),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'REASON',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12.0,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .white),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'START',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12.0,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .white),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'FINISH',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12.0,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .white),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'DOWNTIME',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12.0,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .white),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                ],
                                                              ),
                                                              // Data Rows dari List
                                                              ...snapshot.data!
                                                                  .asMap()
                                                                  .entries
                                                                  .map((entry) {
                                                                int index =
                                                                    entry.key +
                                                                        1;
                                                                PendingListByIdrecord
                                                                    data =
                                                                    entry.value;

                                                                return TableRow(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: index %
                                                                                2 ==
                                                                            0
                                                                        ? Colors
                                                                            .grey
                                                                            .shade200
                                                                        : Colors
                                                                            .white,
                                                                    border: Border(
                                                                        bottom: BorderSide(
                                                                            color:
                                                                                Colors.grey.shade400)),
                                                                  ),
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          index
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              fontSize:
                                                                                  12.0),
                                                                          textAlign:
                                                                              TextAlign.center),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          data
                                                                              .nameReason,
                                                                          style: TextStyle(
                                                                              fontSize:
                                                                                  12.0),
                                                                          textAlign:
                                                                              TextAlign.left),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          _formatDateTime(data
                                                                              .startPending),
                                                                          style: TextStyle(
                                                                              fontSize:
                                                                                  12.0),
                                                                          textAlign:
                                                                              TextAlign.center),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          _formatDateTime(data
                                                                              .finishPending),
                                                                          style: TextStyle(
                                                                              fontSize:
                                                                                  12.0),
                                                                          textAlign:
                                                                              TextAlign.center),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Text(
                                                                          data.totalPending
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              fontSize:
                                                                                  12.0),
                                                                          textAlign:
                                                                              TextAlign.center),
                                                                    ),
                                                                  ],
                                                                );
                                                              }).toList(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      )),

                                  const SizedBox(height: 15.0),

                                  Container(
                                    color: const Color(0xFFF8F9FA),
                                    child: Center(
                                        child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(4), // Kolom pertama
                                        1: FlexColumnWidth(6), // Kolom kedua
                                      },
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[
                                                  200], // Warna latar belakang untuk row kedua
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('CUSTOMER',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${_record != null && _record!.detailsRecord.isNotEmpty ? _record!.detailsRecord[0].bcode.nameCompany : '-'}",
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors
                                                  .white, // Warna latar belakang untuk row ketiga
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('BCODE',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${_record != null && _record!.detailsRecord.isNotEmpty ? _record!.detailsRecord[0].bcode.kode : '-'}",
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[
                                                  200], // Warna latar belakang untuk row pertama
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('MACHINE AREA',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${_record!.idMc.areaMc}",
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors
                                                  .white, // Warna latar belakang untuk row keempat
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('STATUS RUNNING',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(
                                                  ": ${_record!.runStatus.toUpperCase()}",
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[
                                                  200], // Warna latar belakang untuk row kelima
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('JOB STATUS',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(
                                                  " : ${_record!.jobStatus.toUpperCase()}",
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors
                                                  .white, // Warna latar belakang untuk row keenam
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text('LEADER NAME',
                                                  textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Text(': CRISTIANO RONALDO',
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                  ),
                                ],
                              ))

//Sampai disini Padding

                      ),
    );
  }
}
