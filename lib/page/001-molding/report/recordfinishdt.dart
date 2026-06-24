import 'dart:convert';
import 'package:flutter_provider_data/model/record_model.dart';
import 'package:flutter_provider_data/page/001-molding/report/detailrecordfinish.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_data_table/flutter_data_table.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/config/app_config.dart';

class RecordFinishDt extends StatefulWidget {
  const RecordFinishDt({super.key, required this.title});

  final String title;
  @override
  State<RecordFinishDt> createState() => _RecordFinishDtState();
}

class _RecordFinishDtState extends State<RecordFinishDt> {
  late Future<List<RecordModel>> records;
  late ColumnWidgetModel columnWidgetModel;
  List<RowWidgetModel> rows = [];
  int _selectedIndex = 0; // Menentukan tab yang terpilih

  // Mendapatkan daftar kolom
  ColumnWidgetModel getColumnList() {
    List<ColumnHeaderModel> columnList = [
      ColumnHeaderModel(
          id: 0, // Kolom nomor urut INI TAMBAHAN BARU
          slug: "no",
          label: "NO",
          orderNumber: 0,
          columnType: RowFieldWidgetType.textWidget,
          textAlign: TextAlign.center,
          fixedWidth: 15.0), //sampai sini TAMBAHAN BARUNYA

      ColumnHeaderModel(
          id: 1,
          slug: "photo",
          label: "PHOTO",
          orderNumber: 1,
          columnType: RowFieldWidgetType.customWidget,
          textAlign: TextAlign.left,
          fixedWidth: 15.0),
      ColumnHeaderModel(
          id: 2,
          slug: "name",
          label: "NAME",
          orderNumber: 2,
          columnType: RowFieldWidgetType.textWidget,
          textAlign: TextAlign.left,
          fixedWidth: 40.0),
      ColumnHeaderModel(
          id: 3,
          slug: "idrecord",
          label: "ID RECORD",
          orderNumber: 3,
          columnType: RowFieldWidgetType.textWidget,
          textAlign: TextAlign.left,
          fixedWidth: 35.0),
      ColumnHeaderModel(
          id: 4,
          slug: "start",
          label: "START",
          orderNumber: 4,
          columnType: RowFieldWidgetType.textWidget,
          textAlign: TextAlign.center),
      ColumnHeaderModel(
          id: 5,
          slug: "finish",
          label: "FINISH",
          orderNumber: 5,
          columnType: RowFieldWidgetType.textWidget,
          textAlign: TextAlign.center),
      ColumnHeaderModel(
          id: 6,
          slug: "quantity",
          label: "QTY",
          orderNumber: 6,
          columnType: RowFieldWidgetType.textWidget,
          fixedWidth: 15),
      ColumnHeaderModel(
          id: 7,
          slug: "job number",
          label: "JOB NUMBER",
          orderNumber: 7,
          columnType: RowFieldWidgetType.textWidget,
          fixedWidth: 25.0),
      ColumnHeaderModel(
          id: 8,
          slug: 'actionButton',
          label: 'ACTION',
          orderNumber: 8,
          columnType: RowFieldWidgetType.customWidget,
          textAlign: TextAlign.center,
          fixedWidth: 20),
    ];
    return ColumnWidgetModel(
      columnsList: columnList,
      backgroundColor: Colors.blueAccent,
      style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      headerBorder: true,
    );
  }

  // Fungsi untuk mengubah data JSON menjadi baris untuk FlutterDataTable
  setRow(List<RecordModel> records) {
    print('Jumlah data:${records.length}');
    int index = 1;

    for (var record in records) {
      rows.add(RowWidgetModel(rowFieldList: [
        RowFieldWidgetModel(
            columnHeaderModel: columnWidgetModel.columnsList[0], // Kolom No
            value: index.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.0)),
        RowFieldWidgetModel(
          columnHeaderModel: columnWidgetModel.columnsList[1],
          value: Padding(
            padding: const EdgeInsets.all(2.0),
            child: ClipOval(
              child: Image.network(
                "${AppConfig.baseUrl}/media/img/employee/${record.idEmployee}.png",
                width: 80, // Tentukan ukuran gambar
                height: 60, // Tentukan ukuran gambar
                fit: BoxFit.cover, // Agar gambar tetap proporsional
              ),
            ),
          ),
        ),
        RowFieldWidgetModel(
            columnHeaderModel: columnWidgetModel.columnsList[2],
            value: record.idEmployee.fullName,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0)),
        RowFieldWidgetModel(
            columnHeaderModel: columnWidgetModel.columnsList[3],
            value: record.idRecord,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0)),
        RowFieldWidgetModel(
            columnHeaderModel: columnWidgetModel.columnsList[4],
            value: record.startTime,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0)),
        RowFieldWidgetModel(
            columnHeaderModel: columnWidgetModel.columnsList[5],
            value: record.finishTime,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0)),
        RowFieldWidgetModel(
            columnHeaderModel: columnWidgetModel.columnsList[6],
            value: record.detailsRecord.isNotEmpty
                ? record.detailsRecord[0].finishQty
                : 0,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0)),
        RowFieldWidgetModel(
            columnHeaderModel: columnWidgetModel.columnsList[7],
            value: record.detailsRecord.isNotEmpty
                ? record.detailsRecord[0].jobNumber
                : '',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0)),
        RowFieldWidgetModel(
          columnHeaderModel: columnWidgetModel.columnsList[8],
          value: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  foregroundColor: Colors
                      .transparent, // Transparan untuk memastikan gradient bekerja
                ),
                onPressed: () {
                  print("${record.idRecord}");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailRecordFinish(
                          title: "Detail Finish",
                          idRecord: record
                              .idRecord), // Ganti dengan halaman tujuan Anda
                    ),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.blue.shade800
                      ], // Gradient warna
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(4), // Membulatkan sudut
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: const Text(
                      "DETAIL",
                      style: TextStyle(color: Colors.white, fontSize: 9.0),
                    ),
                  ),
                ),
              )),
        )
      ]));

      index++; //ini baru ya
    }
  }

  // Mengambil data JSON dari server
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        '${AppConfig.baseUrl}/api/record-list/?run_status=finish')); // Ganti dengan URL API
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<RecordModel> records =
          data.map((json) => RecordModel.fromJson(json)).toList();
      setState(() {
        setRow(records); // Update baris data dengan records yang baru
      });
    } else {
      throw Exception('Failed to load data');
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

//INI UNTUK MODE LISTVIEW CARD()
  Future<List<RecordModel>> fetchRecords() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/record-list/?run_status=finish'),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((record) => RecordModel.fromJson(record))
          .toList();
    } else {
      throw Exception('Failed to load records');
    }
  }

  // Fungsi untuk menangani perubahan tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    columnWidgetModel = getColumnList();
    fetchData(); // Ambil data saat init
    records = fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    // double heightApp = MediaQuery.of(context).size.height;
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
          title: Text(
            'MOULDING ${widget.title}',
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
                      const Menu(kode: '001', proses: "MOULDING"),
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
            },
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
      ),
    );
    // double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    // Halaman konten yang akan dipilih berdasarkan tab
    List<Widget> pages = [
      //HALAMAN PERTAMA UNTUK MODE LISTVIEW CARD()******************************

      Scaffold(
          appBar: myAppBar,
          body: isTablet
              ? FutureBuilder<List<RecordModel>>(
                  future: records,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<RecordModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No records found'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final record = snapshot.data![index];
                          return InkWell(
                              onTap: () {
                                // Menggunakan Navigator untuk berpindah ke halaman baru
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailRecordFinish(
                                        title: "Detail Finish",
                                        idRecord: record
                                            .idRecord), // Ganti dengan halaman tujuan Anda
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                elevation: 4,
                                child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15.0, horizontal: 8.0),
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
                                              record.idRecord,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              record.idProses.nameProses,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              record.detailsRecord.isNotEmpty
                                                  ? record.detailsRecord[0]
                                                      .bcode.kode
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 20.0),
                                            Text(
                                              record.detailsRecord.isNotEmpty
                                                  ? record.detailsRecord[0]
                                                      .bcode.drawingNumber
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              record.detailsRecord.isNotEmpty
                                                  ? record.detailsRecord[0]
                                                      .bcode.productType
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Image Section
                                          Flexible(
                                            flex: 3,
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: double
                                                        .infinity, // Lebar penuh untuk container

                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),

                                                    child: Center(
                                                      child: LayoutBuilder(
                                                        builder: (context,
                                                            constraints) {
                                                          // Menghitung ukuran gambar berdasarkan persentase lebar layar
                                                          double imageWidth =
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.16; // 30% dari lebar layar
                                                          double imageHeight =
                                                              imageWidth; // Rasio gambar 1:1

                                                          return ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                            child:
                                                                Image.network(
                                                              "${AppConfig.baseUrl}/media/img/employee/${record.idEmployee}.png",
                                                              width: imageWidth,
                                                              height:
                                                                  imageHeight,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    record.idEmployee.fullName,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Text(
                                                    record.idEmployee.nrp,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black87,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Text(
                                                    record.idEmployee.section
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black87,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Text(
                                                    record.idEmployee.division,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Text Section
                                          Flexible(
                                            flex: 7,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(
                                                        1), // Kolom pertama
                                                    1: FixedColumnWidth(
                                                        20), // Kolom untuk ":"
                                                    2: FlexColumnWidth(
                                                        2), // Kolom kedua
                                                  },
                                                  children: [
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade100, // Warna untuk baris ganjil
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
                                                              record.detailsRecord
                                                                      .isNotEmpty
                                                                  ? record
                                                                      .detailsRecord[
                                                                          0]
                                                                      .jobNumber
                                                                  : '',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
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
                                                        color: Colors
                                                            .white, // Warna untuk baris genap
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
                                                          child: Text(
                                                              record.idMc.nmMc,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade100, // Warna untuk baris ganjil
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
                                                              'START QTY',
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
                                                          child: Text(
                                                              record.detailsRecord
                                                                      .isNotEmpty
                                                                  ? record
                                                                      .detailsRecord[
                                                                          0]
                                                                      .startQty
                                                                      .toString()
                                                                  : '0',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors
                                                            .white, // Warna untuk baris genap
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
                                                              'START TIME',
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
                                                          child: Text(
                                                              record.startTime ??
                                                                  '-',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade100, // Warna untuk baris ganjil
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
                                                              'FINISH TIME',
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
                                                          child: Text(
                                                              record.finishTime ??
                                                                  '-',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors
                                                            .white, // Warna untuk baris genap
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
                                                          child: Text('STATUS',
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
                                                          child: Text(
                                                              record.runStatus
                                                                  .toUpperCase(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 8.0),
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
                                              'TOTAL TIME: ${record.totalTime}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'CYCLE TIME: ${record.cycleTime}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'GOOD: ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].finishQty.toString() : '0'}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 20.0),
                                            Text(
                                              'NG: ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].qtyNg.toString() : '0'}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'PENDING: ${record.totalPending}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ])),
                              )

                              //Sampai sini Tampilan Smartphone.
                              );
                        },
                      );
                    }
                  },
                )
              : FutureBuilder<List<RecordModel>>(
                  future: records,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<RecordModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No records found'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final record = snapshot.data![index];
                          return InkWell(
                            onTap: () {
                              // Navigate to another screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailRecordFinish(
                                    title: "Detail Finish",
                                    idRecord: record.idRecord,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      width: double.infinity,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 2.0),
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
                                                children: [
                                                  Text(
                                                    record.idRecord,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20.0),
                                                  Text(
                                                    record.idProses.nameProses,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20.0),
                                                  Text(
                                                    record.detailsRecord
                                                            .isNotEmpty
                                                        ? record
                                                            .detailsRecord[0]
                                                            .bcode
                                                            .kode
                                                        : '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20.0),
                                                  Text(
                                                    record.detailsRecord
                                                            .isNotEmpty
                                                        ? record
                                                            .detailsRecord[0]
                                                            .bcode
                                                            .drawingNumber
                                                        : '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20.0),
                                                  Text(
                                                    record.detailsRecord
                                                            .isNotEmpty
                                                        ? record
                                                            .detailsRecord[0]
                                                            .bcode
                                                            .productType
                                                        : '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Left Section: Employee Info & Image
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(5.0),
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
                                                  width: double.infinity,
                                                  child: Center(
                                                    child: LayoutBuilder(
                                                      builder: (context,
                                                          constraints) {
                                                        double imageWidth =
                                                            widthApp * 0.16;
                                                        double imageHeight =
                                                            imageWidth;

                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          child: Image.network(
                                                            "${AppConfig.baseUrl}/media/img/employee/${record.idEmployee.idEmployee}.png",
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
                                                  record.idEmployee.fullName,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  record.idEmployee.nrp,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  record.idEmployee.section
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  record.idEmployee.division,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
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
                                                            'JOB NUMBER',
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
                                                            ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].jobNumber : ''}",
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
                                                              ": ${record.idMc.nmMc}",
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
                                                            ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].startQty.toString() : '0'}",
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
                                                              ": ${record.startTime ?? '-'}",
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
                                                            ": ${_formatDateTime(record.finishTime.toString())}",
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
                                                              ": ${record.runStatus.toUpperCase()}",
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
                                    SizedBox(height: 5.0),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      width: double.infinity,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 2.0),
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
                                                children: [
                                                  Text(
                                                    'TOTAL TIME: ${record.totalTime}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 25.0),
                                                  Text(
                                                    'CYCLE TIME: ${record.cycleTime}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 25.0),
                                                  Text(
                                                    'GOOD: ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].finishQty.toString() : '0'}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 25.0),
                                                  Text(
                                                    'NG: ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].qtyNg.toString() : '0'}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 25.0),
                                                  Text(
                                                    'PENDING: ${record.totalPending}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                )),

      //HALAMAN KEDUA UNTUK MODE DATATABLE*******************************************************************************************************
      Scaffold(
        appBar: myAppBar,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: FlutterDataTable(
            rowHeight: 40.0,
            columnModel: columnWidgetModel,
            rowsData: rows,
            isCheckBoxMultiSelectAllowed: true,
            isSerialNumberColumnAllowed:
                false, // Menonaktifkan nomor urut otomatis
            colors: RowColor(color1: Colors.white, color2: Colors.grey[100]!),
            selectedRowColor: Colors.blue.shade50,
            isSortAllowed: true,
            headerHeight: 40.0,
            isRefreshAllowed: true,
            tableDecoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300, width: 1)),
          ),
        ),
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "LIST MODE",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: "TABLE MODE",
          ),
        ],
        backgroundColor: Colors.blueAccent,
        selectedItemColor: Colors.blue[50],
        unselectedItemColor: Colors.grey[400],
        selectedFontSize: 15.0,
        unselectedFontSize: 15.0,
        iconSize: 25.0,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
