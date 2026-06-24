import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/reason_model.dart';
import 'package:flutter_provider_data/model/record_running_manage_model.dart';
import 'package:flutter_provider_data/page/001-molding/recordrunning.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';

class RecordRunningManage extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordRunningManage({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<RecordRunningManage> createState() => _RecordRunningManageState();
}

class _RecordRunningManageState extends State<RecordRunningManage> {
  late Future<List<RecordRunningManageModel>> _recordsFuture;
  bool isLoading = true;
  bool isDeleting = false;
  late Map<String, bool> selectedRows;

  // ✅ Tambahkan variabel ini untuk melacak checkbox
  List<bool> selectedRow = [];
  bool isAllSelected = false; // untuk checkbox header
  bool get isAnyRowSelected =>
      selectedRow.contains(true); // <-- cek minimal satu centang

  @override
  void initState() {
    super.initState();
    _recordsFuture = fetchRecords();
  }

  Future<List<RecordRunningManageModel>> fetchRecords() async {
    final url =
        "${AppConfig.baseUrl}/api/running-records/?id_proses=${widget.idProses}";
    debugPrint("Fetching data from: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final body = json.decode(response.body);
        if (body is List) {
          final list = body
              .map((item) => RecordRunningManageModel.fromJson(item))
              .toList();
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

  Future<List<ReasonModel>> fetchReasonList() async {
    final response =
        await http.get(Uri.parse("${AppConfig.baseUrl}/api/reason-list/all/"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      // Mapping + filter idReason 03 dan 06
      final List<ReasonModel> reasonList = data
          .map((e) => ReasonModel.fromJson(e))
          .where((reason) => reason.idReason != "03" && reason.idReason != "06")
          .toList();

      return reasonList;
    } else {
      throw Exception('Failed to load reasons');
    }
  }

  Future<void> updateSelectedRecord(
      List<RecordRunningManageModel> selectedEmployees,
      ReasonModel selectedReason) async {
    if (selectedEmployees.isEmpty) return;

    final recordsPayload = selectedEmployees.map((record) {
      final bcode = record.detailsRecord.isNotEmpty
          ? record.detailsRecord.first.bcode.bcode
          : '';
      return {
        "id_record": record.idRecord,
        "id_reason": selectedReason.idReason,
        "id_employee": record.employeeFinish!.idEmployee,
        "id_proses": record.idProses,
        "bcode": bcode, // fallback ke string kosong
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/record-set-pending/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"records": recordsPayload}),
      );

      if (response.statusCode == 201) {
        logPrint("Records updated successfully!");

        // ✅ Refresh datatable
        if (!mounted) return;
        setState(() {
          for (int i = 0; i < selectedRow.length; i++) {
            selectedRow[i] = false;
          }
          isAllSelected = false;
          _recordsFuture = fetchRecords();
        });

        CustomSnackbar.show(
          context,
          "Submit Successfully!",
          isSuccess: true,
        );
      } else {
        logPrint("Failed to update records: ${response.body}");

        if (!mounted) return;

        CustomSnackbar.show(
          context,
          "Failed to update records: ${response.body}",
          isSuccess: false,
        );
      }
    } catch (e) {
      logPrint("Error updating records: $e");
      if (!mounted) return;

      CustomSnackbar.show(
        context,
        "Error updating records: $e",
        isSuccess: false,
      );
    }
  }

  void showSelectedRecordsDialog(List<RecordRunningManageModel> records) async {
    final selectedRecords = <String>[];
    final List<RecordRunningManageModel> selectedEmployees = [];
    final List<String> selectedIdRecords = [];
    List<ReasonModel> reasonList = [];

    for (int i = 0; i < selectedRow.length; i++) {
      if (selectedRow[i]) {
        // Ambil path foto dari records
        selectedRecords.add(
            "${AppConfig.baseUrl}/media/img/employee/${records[i].employeeFinish!.idEmployee}.png");
      }
    }

    for (int i = 0; i < selectedRow.length; i++) {
      if (selectedRow[i] && records[i].employeeFinish != null) {
        // Simpan untuk update massal
        selectedIdRecords.add(records[i].idRecord);

        // Simpan data employee untuk ditampilkan di dialog
        selectedEmployees.add(records[i]);
      }
    }

    if (selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data yang dipilih.')),
      );
      return;
    }

    if (selectedRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data yang dipilih.')),
      );
      return;
    }

    try {
      final response = await fetchReasonList(); // Buat fungsi fetchReasonList
      reasonList = response;
    } catch (e) {
      logPrint("Error fetching reasons: $e");
    }

    ReasonModel? selectedReason;
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              // ===== BACKGROUND SEMI TRANSPARAN =====
              GestureDetector(
                onTap: () {}, // biar tidak bisa di-tap untuk close
                child: Container(color: const Color.fromARGB(255, 49, 46, 46)),
              ),

              // ===== DIALOG DI BAWAH APPBAR =====
              Positioned(
                top: kToolbarHeight + 25, // ⬅️ ini jarak dari bawah AppBar
                left: 16,
                right: 16,
                child: Material(
                  borderRadius: BorderRadius.circular(15),
                  elevation: 8,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'STOP MOLDING PROCESS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.maxFinite,
                          child: Wrap(
                            spacing: 16, // jarak horizontal antar foto
                            runSpacing: 16, // jarak vertical antar baris
                            alignment: WrapAlignment.start,
                            children: selectedEmployees.map((record) {
                              final employee = record.employeeFinish!;
                              final photoUrl =
                                  "${AppConfig.baseUrl}/media/img/employee/${employee.idEmployee}.png";

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 26, // ukuran foto
                                    backgroundImage: NetworkImage(photoUrl),
                                    backgroundColor: Colors.grey.shade200,
                                    onBackgroundImageError: (_, __) =>
                                        const Icon(Icons.person,
                                            size: 26, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    employee.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(builder: (context, constraints) {
                          return DropdownSearch<ReasonModel>(
                            items: (f, cs) => reasonList,
                            itemAsString: (ReasonModel? item) =>
                                "${item?.nameReason}",
                            compareFn: (a, b) => a.idReason == b.idReason,
                            onChanged: (ReasonModel? value) {
                              selectedReason = value;
                            },

                            // ===== DECORATOR =====
                            decoratorProps: const DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: "Pilih Reason",
                                hintText: "Nama Reason",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                      color: Colors.blueAccent, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                      color: Colors.blue, width: 2.0),
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),

                            // ===== POPUP PROPS =====
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: const TextFieldProps(
                                decoration: InputDecoration(
                                  labelText: "Cari Reason",
                                  hintText: "Ketik nama Reason...",
                                  prefixIcon: Icon(Icons.search,
                                      color: Colors.blueAccent),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                                textCapitalization:
                                    TextCapitalization.characters,
                                keyboardType: TextInputType.text,
                              ),

                              // ===== ITEM BUILDER =====
                              itemBuilder: (context, ReasonModel item,
                                  bool isSelected, bool isDisabled) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.shade50
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.blueAccent, width: 2)
                                        : null,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      child: Text(
                                        item.idReason.length >= 2
                                            ? item.idReason.substring(
                                                item.idReason.length - 2)
                                            : item.idReason,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      item.nameReason,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Standar Time: ${item.standarTime} min",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle_rounded,
                                            color: Colors.green)
                                        : null,
                                  ),
                                );
                              },

                              constraints: BoxConstraints.tightFor(
                                width: MediaQuery.of(context).size.width *
                                    0.98, // 🔥 samakan dgn dialog width
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                              ),

                              scrollbarProps: const ScrollbarProps(
                                trackVisibility: true,
                                thumbVisibility: true,
                                thickness: 6,
                                radius: Radius.circular(3),
                              ),

                              menuProps: MenuProps(
                                margin: const EdgeInsets.only(top: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                elevation: 8,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'CLOSE',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () async {
                                if (selectedReason != null) {
                                  await updateSelectedRecord(
                                      selectedEmployees, selectedReason!);

                                  if (!mounted) return;
                                  Navigator.pop(context);
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Pilih reason dulu')),
                                  );
                                }
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                    onPressed: isAnyRowSelected
                        ? () async {
                            // Ambil data terbaru dari snapshot FutureBuilder
                            final records = await _recordsFuture;
                            showSelectedRecordsDialog(records);
                          }
                        : null, // nonaktif jika tidak ada centang
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
                              ? [Colors.red.shade400, Colors.red.shade800]
                              : [Colors.grey.shade400, Colors.grey.shade600],
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
                            Icon(Icons.stop_circle_sharp, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'STOP',
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
                          pageBuilder: (_, __, ___) => RecordRunning(
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
        FutureBuilder<List<RecordRunningManageModel>>(
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
                rightHandSideColumnWidth: 1260,
                isFixedHeader: true,

                // ===== HEADER =====
                headerWidgets: [
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
                              child: Text('NO',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0))),
                        ),
                        const SizedBox(
                          width: 120,
                          child: Center(
                              child: Text('JOBNUMBER',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0))),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    width: 240,
                    height: 55,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Text('OPERATOR',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                  ),
                  Container(
                    width: 160,
                    height: 55,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Text('MACHINE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                  ),
                  Container(
                    width: 120,
                    height: 55,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Text('BCODE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                  ),
                  Container(
                    width: 220,
                    height: 55,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Text('DRAWING NO',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                  ),
                  Container(
                    width: 120,
                    height: 55,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Text('TOTAL LOT',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                  ),
                  Container(
                    width: 220,
                    height: 55,
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Text('START TIME',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                  ),
                  Container(
                    width: 100,
                    height: 55,
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Text('QTY',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                  ),
                  Container(
                    width: 80,
                    height: 55,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Text('ACTION',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                  ),
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

                        // Icon tepat di samping checkbox
                        const Icon(Icons.label_important,
                            color: Colors.blue, size: 20),
                        const SizedBox(
                            width: 4), // jarak kecil antara icon & teks

                        // NO
                        Container(
                          width: 40,
                          alignment: Alignment.centerLeft,
                          child: Text((index + 1).toString(),
                              style: TextStyle(fontSize: 16)),
                        ),

                        // JOBNUMBER
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              record.detailsRecord.isNotEmpty
                                  ? record.detailsRecord.first.jobNumber
                                  : '',
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

                // ===== RIGHT SIDE (tetap sama) =====
                rightSideItemBuilder: (context, index) {
                  final record = records[index];
                  final rowColor =
                      index % 2 == 0 ? Colors.grey.shade100 : Colors.white;

                  final photoUrl =
                      "${AppConfig.baseUrl}/media/img/employee/${record.employeeFinish?.idEmployee ?? ''}.png";

                  return Container(
                    color: rowColor,
                    child: Row(
                      children: [
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
                                  record.employeeFinish?.fullName ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 62, 134, 175),
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 160,
                          height: 55,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(record.machineFinish?.nmMc ?? '',
                              style: TextStyle(fontSize: 16)),
                        ),
                        Container(
                          width: 120,
                          height: 55,
                          alignment: Alignment.center,
                          child: Text(record.detailsRecord.first.bcode.bcode,
                              style: TextStyle(fontSize: 16)),
                        ),
                        Container(
                          width: 220,
                          height: 55,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                              record.detailsRecord.first.bcode.drawingNumber,
                              style: TextStyle(fontSize: 16)),
                        ),
                        Container(
                          width: 120,
                          height: 55,
                          alignment: Alignment.center,
                          child: Text(record.totalJobnumber,
                              style: TextStyle(fontSize: 16)),
                        ),
                        Container(
                          width: 220,
                          height: 55,
                          alignment: Alignment.center,
                          child: Text(
                              record.startTime.toString().substring(0, 19),
                              style: TextStyle(fontSize: 16)),
                        ),
                        Container(
                          width: 100,
                          height: 55,
                          alignment: Alignment.center,
                          child: Text(
                              record.detailsRecord.first.startQty.toString(),
                              style: TextStyle(fontSize: 16)),
                        ),
                        Container(
                          width: 80,
                          height: 55,
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: isDeleting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.redAccent,
                                    ),
                                  )
                                : const Icon(
                                    Icons.delete_forever,
                                    color: Colors.redAccent,
                                    size: 30,
                                  ),
                            tooltip: "Hapus Record",
                            onPressed: isDeleting
                                ? null // tombol dikunci saat proses
                                : () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text(
                                          "KONFIRMASI HAPUS DATA",
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        content: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          height: 180,
                                          child: Center(
                                            child: Text(
                                              "Yakin ingin hapus Jobnumber ${record.detailsRecord.first.jobNumber}?",
                                              textAlign: TextAlign.center,
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ),
                                        actionsAlignment:
                                            MainAxisAlignment.center,
                                        actions: [
                                          // Tombol CANCEL (abu-abu)
                                          Container(
                                            width: 130,
                                            height: 55,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.grey,
                                                  Colors.black54
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor: Colors.white,
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

                                          // Tombol DELETE (gradient merah)
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
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
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor: Colors.white,
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
                                      setState(() =>
                                          isDeleting = true); // 🔒 kunci tombol

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
                                        if (context.mounted) {
                                          CustomSnackbar.show(
                                            context,
                                            "Terjadi kesalahan: $e",
                                            isSuccess: false,
                                          );
                                        }
                                      } finally {
                                        if (context.mounted) {
                                          setState(() => isDeleting =
                                              false); // 🔓 buka lagi
                                        }
                                      }
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
