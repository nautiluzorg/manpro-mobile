import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_stop_manage_model.dart';
import 'package:flutter_provider_data/page/001-molding/recordstop.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';

class RecordStopManage extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordStopManage({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<RecordStopManage> createState() => _RecordStopManageState();
}

class _RecordStopManageState extends State<RecordStopManage> {
  late Future<List<RecordStopManageModel>> _recordsFuture;
  late Map<String, bool> selectedRows;
  bool isLoading = true;
  bool _isDeleting = false;
  List<bool> selectedRow = [];
  bool isAllSelected = false; // untuk checkbox header
  bool get isAnyRowSelected =>
      selectedRow.contains(true); // <-- cek minimal satu centang

  @override
  void initState() {
    super.initState();
    _recordsFuture = fetchRecords();
  }

  Future<List<RecordStopManageModel>> fetchRecords() async {
    final url =
        "${AppConfig.baseUrl}/api/record-pending-list/?status_pending=open&id_proses=${widget.idProses}";
    debugPrint("Fetching data from: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final body = json.decode(response.body);
        if (body is List) {
          final list =
              body.map((item) => RecordStopManageModel.fromJson(item)).toList();
          selectedRow = List<bool>.filled(list.length, false);
          return list;
        } else {
          throw Exception("Unexpected data format: ${body.runtimeType}");
        }
      } catch (e) {
        throw Exception("Failed to parse JSON: $e");
      }
    } else {
      throw Exception("Failed to fetch data (status ${response.statusCode})");
    }
  }

  /// ✅ Fungsi untuk toggle semua checkbox
  void toggleSelectAll(bool? value) {
    setState(() {
      isAllSelected = value ?? false;
      for (int i = 0; i < selectedRow.length; i++) {
        selectedRow[i] = isAllSelected;
      }
    });
  }

  /// ✅ Fungsi untuk toggle checkbox individu
  void toggleRow(int index, bool? value) {
    setState(() {
      selectedRow[index] = value ?? false;
      isAllSelected = selectedRow.every((v) => v);
    });
  }

  List<int> getSelectedPendingIds(List<RecordStopManageModel> records) {
    List<int> selectedIdPendings = [];
    for (int i = 0; i < selectedRow.length; i++) {
      if (selectedRow[i]) {
        selectedIdPendings.add(records[i].idPending);
      }
    }
    return selectedIdPendings;
  }

  void printSelectedPendingPayload(List<RecordStopManageModel> records) {
    // ambil data row yang dicentang
    final selectedRecords = <Map<String, dynamic>>[];

    for (int i = 0; i < selectedRow.length; i++) {
      if (selectedRow[i]) {
        selectedRecords.add({
          "id_record": records[i].idRecord,
          "id_pending": records[i].idPending,
        });
      }
    }

    if (selectedRecords.isEmpty) {
      logPrint("Belum ada row yang dicentang!");
      return;
    }

    final payload = {"records": selectedRecords};
    logPrint("Payload siap dikirim: ${jsonEncode(payload)}");
  }

  Future<void> updateStartRecord(List<RecordStopManageModel> records) async {
    // Ambil data row yang dicentang
    final selectedRecords = <Map<String, dynamic>>[];

    for (int i = 0; i < selectedRow.length; i++) {
      if (selectedRow[i]) {
        selectedRecords.add({
          "id_record": records[i].idRecord,
          "id_pending": records[i].idPending,
        });
      }
    }

    if (selectedRecords.isEmpty) {
      logPrint("Belum ada row yang dicentang!");
      return;
    }

    final payload = {"records": selectedRecords};

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/record-set-start/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        logPrint("Data berhasil dikirim ke API!");
        logPrint("Response: ${response.body}");

        setState(() {
          selectedRow = List<bool>.filled(selectedRow.length, false);
          isAllSelected = false;
          _recordsFuture = fetchRecords();
        });
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Submit Successfully!",
          isSuccess: true,
        );
      } else {
        logPrint("Gagal mengirim data. Status: ${response.statusCode}");
        logPrint("Response: ${response.body}");
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Gagal mengirim data. Status: ${response.statusCode}",
          isSuccess: false,
        );
      }
    } catch (e) {
      logPrint("Error saat mengirim data ke API: $e");
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Error saat mengirim data ke API: $e",
        isSuccess: false,
      );
    }
  }

  Widget _buildHeaderCell(String label, double width) {
    return Container(
      width: width,
      height: 55,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0)),
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
                        Text('OPERATOR'),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // ✅ Tombol STOP aktif hanya jika ada checkbox dicentang
                  const SizedBox(width: 20),
                  ElevatedButton(
                    // onPressed: () {}, // nonaktif jika tidak ada centang

                    onPressed: isAnyRowSelected
                        ? () async {
                            final records = await _recordsFuture;
                            await updateStartRecord(records);
                          }
                        : null,

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
                          colors: isAnyRowSelected
                              ? [
                                  Colors.green.shade400,
                                  Colors.green.shade700
                                ] // aktif (lanjut)
                              : [
                                  Colors.grey.shade400,
                                  Colors.grey.shade600
                                ], // nonaktif
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
                            Icon(Icons.play_circle_fill, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'RESUME',
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

                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => RecordStop(
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

        // === TABEL ===
        FutureBuilder<List<RecordStopManageModel>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text("Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No data available."));
            }

            final records = snapshot.data!;
            if (selectedRow.length != records.length) {
              selectedRow = List<bool>.filled(records.length, false);
            }

            return Expanded(
              child: HorizontalDataTable(
                leftHandSideColumnWidth: 220,
                rightHandSideColumnWidth: 1440,
                isFixedHeader: true,
                headerWidgets: [
                  // ===== HEADER =====
                  Container(
                    width: 220,
                    height: 55,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Checkbox(
                              value: isAllSelected,
                              onChanged: toggleSelectAll,
                              checkColor: Colors.white,
                              activeColor: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 60,
                          child: Center(
                            child: Text(
                              'NO',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 120,
                          child: Center(
                            child: Text(
                              'JOBNUMBER',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildHeaderCell('REASON STOP', 240),
                  _buildHeaderCell('OPERATOR', 240),
                  _buildHeaderCell('TIME STOP', 220),
                  _buildHeaderCell('DRAWING NO', 220),
                  _buildHeaderCell('CATEGORY', 120),
                  _buildHeaderCell('MACHINE', 220),
                  _buildHeaderCell('QTY', 100),
                  _buildHeaderCell('ACTION', 80),
                ],

                // ===== LEFT SIDE =====
                leftSideItemBuilder: (context, index) {
                  final record = records[index];
                  final rowColor =
                      index % 2 == 0 ? Colors.grey.shade100 : Colors.white;

                  return Container(
                    width: 220,
                    height: 55,
                    color: rowColor,
                    child: Row(
                      children: [
                        // Checkbox
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Checkbox(
                              value: selectedRow[index],
                              onChanged: (val) => toggleRow(index, val),
                              activeColor: Colors.blue,
                            ),
                          ),
                        ),

                        const Icon(Icons.label_important,
                            color: Colors.blue, size: 20),
                        const SizedBox(width: 4),

                        // NO
                        Container(
                          width: 40,
                          alignment: Alignment.centerLeft,
                          child: Text((index + 1).toString(),
                              style: const TextStyle(fontSize: 16)),
                        ),

                        // JOBNUMBER
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              record.jobnumber,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
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

                  final photoUrl =
                      "${AppConfig.baseUrl}/media/img/employee/${record.idEmployee}.png";

                  return Container(
                    color: rowColor,
                    child: Row(
                      children: [
                        // REASON
                        Container(
                          width: 240,
                          height: 55,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            record.reason,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red.shade600, // 🔴 Warna agak merah
                            ),
                          ),
                        ),

                        // OPERATOR
                        Container(
                          width: 240,
                          height: 55,
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
                                    width: 30,
                                    height: 30,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.person, size: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  record.employeeName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 62, 134, 175),
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // BCODE
                        Container(
                          width: 220,
                          height: 55,
                          alignment: Alignment.centerLeft,
                          child: Text(
                              formatDateTime(record.startPending.toString()),
                              style: const TextStyle(fontSize: 16)),
                        ),

                        // DRAWING NO
                        Container(
                          width: 220,
                          height: 55,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(record.drawingNumber,
                              style: const TextStyle(fontSize: 16)),
                        ),

                        // TOTAL LOT
                        Container(
                          width: 120,
                          height: 55,
                          alignment: Alignment.centerLeft,
                          child: Text(record.productCategory,
                              style: const TextStyle(fontSize: 16)),
                        ),

                        // START TIME
                        Container(
                          width: 220,
                          height: 55,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            record.machineName,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        // QTY
                        Container(
                          width: 100,
                          height: 55,
                          alignment: Alignment.centerLeft,
                          child: Text(record.qty.toString(),
                              style: const TextStyle(fontSize: 16)),
                        ),

// Tambahkan kolom ACTION DELETE di bagian paling kanan
                        Container(
                          width: 80,
                          height: 55,
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.redAccent,
                              size: 30,
                            ),
                            tooltip: "Hapus Record Stop",
                            onPressed: () async {
                              // 🔒 Variabel proteksi double click
                              if (_isDeleting) return;
                              setState(() => _isDeleting = true);

                              final confirm = await showDialog<bool>(
                                context: context,
                                barrierDismissible:
                                    false, // ❌ Tidak bisa tutup di luar
                                builder: (ctx) => AlertDialog(
                                  title: const Text(
                                    "KONFIRMASI HAPUS DATA",
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: 180,
                                    child: Center(
                                      child: Text(
                                        "Yakin ingin hapus Jobnumber ${record.jobnumber}?",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  actionsAlignment: MainAxisAlignment.center,
                                  actions: [
                                    // CANCEL button (abu gradient)
                                    Container(
                                      width: 130,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.grey, Colors.black54],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: const Text(
                                          "CANCEL",
                                          style: TextStyle(
                                            fontSize: 18,
                                            letterSpacing: 1.2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 20),

                                    // DELETE button (merah gradient)
                                    Container(
                                      width: 130,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.redAccent,
                                            Colors.deepOrange
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: const Text(
                                          "DELETE",
                                          style: TextStyle(
                                            fontSize: 18,
                                            letterSpacing: 1.2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  final response = await http.delete(
                                    Uri.parse(
                                      "${AppConfig.baseUrl}/api/recordproses/delete/${record.idRecord}/",
                                    ),
                                  );

                                  if (!context.mounted) return;

                                  if (response.statusCode == 200) {
                                    CustomSnackbar.show(
                                      context,
                                      "Record berhasil dihapus",
                                      isSuccess: true,
                                    );

                                    setState(() {
                                      _recordsFuture = fetchRecords();
                                    });
                                  } else {
                                    CustomSnackbar.show(
                                      context,
                                      "Gagal menghapus record (status ${response.statusCode})",
                                      isSuccess: false,
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  CustomSnackbar.show(
                                    context,
                                    "Terjadi kesalahan: $e",
                                    isSuccess: false,
                                  );
                                } finally {
                                  setState(() =>
                                      _isDeleting = false); // 🔓 Lepas proteksi
                                }
                              } else {
                                setState(() => _isDeleting =
                                    false); // 🔓 Batalkan jika user CANCEL
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },

                itemCount: records.length,
              ),
            );
          },
        ),
      ]),
    );
  }
}
