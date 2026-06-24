import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/report/downtime_summary_page.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'paginated_record_downtime.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/page/menu_sub.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordDowntime extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordDowntime(
      {super.key, required this.title, required this.idProses});

  @override
  State<RecordDowntime> createState() => _RecordDowntimeState();
}

class _RecordDowntimeState extends State<RecordDowntime> {
  PaginatedRecordDowntime? paginatedData;
  bool isLoading = true;
  bool _buttonsEnabled = true;

  int pageIndex = 0; // 0-based index halaman
  int pageSize = 20; // default page size
  int _totalRecords = 0; // <--- tambahkan ini
  int _currentPage = 1;
  int _rowsPerPage = 20;

  // Optional filters
  String? selectedReason;
  String? selectedEmployeeId;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _dateRangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPendingPage(page: 1, pageSize: _rowsPerPage);
  }

// Versi refactor dengan konsep fetchPendingDataFuture
  Future<PaginatedRecordDowntime> fetchPendingDataFuture({
    int page = 1,
    int pageSize = 20,
    String? idReason,
    String? idEmployee,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (idReason != null && idReason.isNotEmpty) {
      queryParams['id_reason'] = idReason;
    }

    if (idEmployee != null && idEmployee.isNotEmpty) {
      queryParams['id_employee'] = idEmployee;
    }

    if (startDate != null) {
      queryParams['start_date'] =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }

    if (endDate != null) {
      final endDatePlusOne = endDate.add(Duration(days: 1));
      queryParams['end_date'] =
          '${endDatePlusOne.year}-${endDatePlusOne.month.toString().padLeft(2, '0')}-${endDatePlusOne.day.toString().padLeft(2, '0')}';
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/api/record-pending/')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PaginatedRecordDowntime.fromJson(jsonData);
    } else {
      throw Exception('Failed to load Record Downtime data');
    }
  }

  Future<void> loadPendingPage(
      {required int page, required int pageSize}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await fetchPendingDataFuture(
        page: page,
        pageSize: pageSize,
        idReason: selectedReason,
        idEmployee: selectedEmployeeId,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        paginatedData = result;
        _currentPage = page;
        _rowsPerPage = pageSize;
        pageIndex = page - 1; // 0-based index
        _totalRecords = result.count;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading page : $e');
    }
  }

  Future<void> _showReasonDialog() async {
    // 1️⃣ tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    List reasons = [];

    try {
      // 2️⃣ fetch data dari API
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/reason-list/all/'),
      );

      if (response.statusCode == 200) {
        reasons = json.decode(response.body);
      } else {
        debugPrint("Failed to load reason list, code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching reasons: $e");
    } finally {
      // 3️⃣ hilangkan loading, cek mounted
      if (mounted) {
        Navigator.pop(context);
      }
    }

    // 4️⃣ tampilkan dialog untuk pilih reason
    if (!mounted) return;

    final selectedReasonId = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Pilih Reason'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: reasons.isEmpty
              ? const Center(child: Text('No data'))
              : ListView.builder(
                  itemCount: reasons.length,
                  itemBuilder: (context, index) {
                    var reason = reasons[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, reason['id_reason']);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade800,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 51),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reason['name_reason'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              reason['description'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (selectedReasonId != null) {
      setState(() {
        selectedReason = selectedReasonId;
        _buttonsEnabled = false;
      });
      loadPendingPage(page: 1, pageSize: _rowsPerPage);
    }
  }

  Future<void> scanEmployeeId(String idProses) async {
    try {
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(), // halaman scanner yang sama
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // Validasi format QR Code ID Employee (harus 8 karakter alphanumeric)
      if (getcode.length != 8) {
        CustomSnackbar.show(
          context,
          "QRCode yang anda scan bukan QRcode Employee!",
          isSuccess: false, // warna hijau + icon check
        );

        return;
      }

      if (!RegExp(r'^[0-9]{8}$').hasMatch(getcode)) {
        CustomSnackbar.show(
          context,
          "QRCode Employee tidak valid, harus 8 digit angka.",
          isSuccess: false, // warna hijau + icon check
        );

        return;
      }

      String employeeId = getcode; // 8 karakter ID Employee

      logPrint('Scanned Employee ID: $employeeId');

      setState(() {
        _currentPage = 1;
        selectedEmployeeId = employeeId;
        _buttonsEnabled = false; // ← disable semua button
      });

      loadPendingPage(page: 1, pageSize: _rowsPerPage);
    } on TimeoutException catch (_) {
      CustomSnackbar.show(
        context,
        "Request timed out. Please try again.",
        isSuccess: false, // warna hijau + icon check
      );
    } on SocketException catch (_) {
      CustomSnackbar.show(
        context,
        "No internet connection.",
        isSuccess: false, // warna hijau + icon check
      );
    } on FormatException catch (_) {
      CustomSnackbar.show(
        context,
        "Error parsing server response.",
        isSuccess: false, // warna hijau + icon check
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Unexpected error: $e",
        isSuccess: false, // warna hijau + icon check
      );
    }
  }

  // Tambahkan di bagian State class
  void _clearFilters() {
    setState(() {
      selectedReason = null;
      selectedEmployeeId = null;
      _startDate = null;
      _endDate = null;
      _buttonsEnabled = true; // enable kembali button REASON
    });

    // Load semua data tanpa filter
    loadPendingPage(page: 1, pageSize: _rowsPerPage);
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
                      MenuSub(
                          title: "MOULDING REPORT", idProses: widget.idProses),
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
      body: paginatedData == null
          ? const Center(child: Text('No data'))
          : Stack(children: [
              Column(
                children: [
                  // BAGIAN ATAS: Menu / Buttons

                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Container(
                      padding: const EdgeInsets.all(8), // biar ada jarak dalam
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade100,
                            Colors.grey.shade50,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(0),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300, // Warna border top
                            width: 1, // Ketebalan border
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 136, 135, 135)
                                .withValues(alpha: 0.1), // 0.1 = 10% transparan
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Job Number button

                            SizedBox(
                              width: 120,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _buttonsEnabled
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF7B4397), // ungu tua
                                            Color(0xFF9D50BB), // ungu terang
                                            Color(0xFFED6EA0), // pink lembut
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade300,
                                            Colors.grey.shade400,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: ElevatedButton(
                                  onPressed: _buttonsEnabled
                                      ? () => _showReasonDialog()
                                      : null,
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
                                      Icon(
                                        Icons.search,
                                        size: 20,
                                        color: _buttonsEnabled
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'REASON',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _buttonsEnabled
                                              ? Colors.white
                                              : Colors.black54,
                                        ),
                                      ),
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
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF89F7FE), // soft sky blue
                                            Color(0xFF66A6FF), // soft aqua blue
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade300,
                                            Colors.grey.shade400,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: _buttonsEnabled
                                      ? () => scanEmployeeId(widget.idProses)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 12),
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_search,
                                        size: 20,
                                        color: _buttonsEnabled
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'OPT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                          color: _buttonsEnabled
                                              ? Colors.white
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Batch button
                            SizedBox(
                              width: 140,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _buttonsEnabled
                                      ? LinearGradient(
                                          colors: [
                                            Colors.indigo.shade100,
                                            Colors.indigo
                                                .shade400, // gradasi lebih gelap
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade300,
                                            Colors.grey.shade400,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: ElevatedButton(
                                  onPressed: _buttonsEnabled
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DowntimeSummaryPage(
                                                title: widget.title,
                                                idProses: widget.idProses,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
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
                                      Icon(
                                        Icons.insert_chart,
                                        size: 20,
                                        color: _buttonsEnabled
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'CHART',
                                        style: TextStyle(
                                          color: _buttonsEnabled
                                              ? Colors.white
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Date Range field

                            SizedBox(
                              width: 260,
                              child: TextField(
                                controller: _dateRangeController,
                                readOnly: true,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 107, 102, 102),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'DATE RANGE',
                                  labelStyle: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 10),
                                  prefixIcon: const Icon(Icons.calendar_month,
                                      size: 20),
                                  prefixIconConstraints: const BoxConstraints(
                                      minWidth: 35, minHeight: 30),
                                  suffixIcon: _dateRangeController
                                          .text.isNotEmpty
                                      ? IconButton(
                                          icon:
                                              const Icon(Icons.close, size: 20),
                                          onPressed: () {
                                            // Clear hanya filter tanggal (jangan lupa reload)
                                            setState(() {
                                              _dateRangeController.clear();
                                              _startDate = null;
                                              _endDate = null;
                                              _currentPage = 1;
                                              _buttonsEnabled =
                                                  true; // kembalikan tombol jika perlu
                                            });
                                            // reload data tanpa tanggal (tetap mempertahankan reason/employee jika ada)
                                            loadPendingPage(
                                                page: 1,
                                                pageSize: _rowsPerPage);
                                          },
                                        )
                                      : const SizedBox(
                                          width:
                                              48), // ruang biar layout konsisten
                                ),
                                onTap: () async {
                                  // Buka date range picker
                                  final DateTimeRange? picked =
                                      await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                    currentDate: DateTime.now(),
                                    saveText: 'Select',
                                  );

                                  if (!mounted) {
                                    return;
                                  } // safety — widget mungkin sudah unmounted

                                  if (picked != null) {
                                    // format display (dd-mm-yyyy TO dd-mm-yyyy)
                                    final start = picked.start;
                                    final end = picked.end;
                                    final displayText =
                                        '${start.day.toString().padLeft(2, '0')}-'
                                        '${start.month.toString().padLeft(2, '0')}-'
                                        '${start.year} TO '
                                        '${end.day.toString().padLeft(2, '0')}-'
                                        '${end.month.toString().padLeft(2, '0')}-'
                                        '${end.year}';

                                    setState(() {
                                      _startDate = start;
                                      _endDate = end;
                                      _dateRangeController.text = displayText;
                                      _currentPage = 1;
                                      _buttonsEnabled =
                                          false; // disable button lain kalau itu kebijakanmu
                                    });

                                    // Panggil loadPendingPage dengan DateTime (fetchPendingDataFuture akan men-generate query param)
                                    await loadPendingPage(
                                        page: 1, pageSize: _rowsPerPage);
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            SizedBox(
                                width: 120,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.redAccent,
                                        const Color.fromARGB(
                                            255, 241, 155, 155),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius:
                                        BorderRadius.zero, // tetap kotak
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _clearFilters();
                                      _dateRangeController.clear();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 12),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.zero, // tetap persegi
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        // Icon(Icons.refresh, size: 20, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'CLEAR',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),

                            const SizedBox(width: 10),

                            // Batch button

                            SizedBox(
                              width: 140,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _buttonsEnabled
                                      ? LinearGradient(
                                          colors: [
                                            Colors.indigo.shade100,
                                            Colors.indigo
                                                .shade400, // gradasi lebih gelap
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade300,
                                            Colors.grey.shade400,
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.list_alt,
                                        size: 20,
                                        color: _buttonsEnabled
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'SUMMARY',
                                        style: TextStyle(
                                          color: _buttonsEnabled
                                              ? Colors.white
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BAGIAN BAWAH: DataTable dengan Expanded

                  Expanded(
                    child: HorizontalDataTable(
                      leftHandSideColumnWidth: 340, // gabungan NO + REASON
                      rightHandSideColumnWidth: 900,
                      isFixedHeader: true,
                      headerWidgets: [
                        // ===== HEADER KIRI (NO + REASON) =====
                        Container(
                          width: 340,
                          height: 50,
                          alignment: Alignment.centerLeft,
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
                                width: 60,
                                child: Center(
                                  child: Text(
                                    'NO',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 280,
                                child: Text(
                                  'DOWNTIME REASON',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== HEADER KANAN =====
                        Container(
                          width: 140,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('DURATION',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              Text('(Min)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                      fontSize: 12)),
                            ],
                          ),
                        ),

                        Container(
                          width: 200,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('DOWNTIME START',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              Text('(Time)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          width: 200,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('DOWNTIME FINISH',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              Text('(Time)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                      fontSize: 12)),
                            ],
                          ),
                        ),

                        Container(
                          width: 240,
                          height: 50,
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
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          width: 120,
                          height: 50,
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
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],

                      // ===== KIRI (NO + REASON) =====
                      leftSideItemBuilder: (context, index) {
                        if (paginatedData == null ||
                            paginatedData!.results.isEmpty) {
                          return Container(
                            height: 48,
                            alignment: Alignment.center,
                            child: const Text(
                              'DATA TIDAK ADA',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }

                        final record = paginatedData!.results[index];
                        final rowColor = index % 2 == 0
                            ? Colors.grey.shade100
                            : Colors.white;

                        return Container(
                          color: rowColor,
                          width: 340,
                          height: 48,
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                alignment: Alignment.center,
                                child: Text((pageIndex * pageSize + index + 1)
                                    .toString()),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        size: 18, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(record.reasonName,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },

                      // ===== KANAN =====
                      rightSideItemBuilder: (context, index) {
                        if (paginatedData == null ||
                            paginatedData!.results.isEmpty) {
                          return Container(
                            height: 48,
                            alignment: Alignment.center,
                            child: const Text(
                              'DATA TIDAK ADA',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }

                        final record = paginatedData!.results[index];
                        final rowColor = index % 2 == 0
                            ? Colors.grey.shade100
                            : Colors.white;

                        return Container(
                          color: rowColor,
                          child: Row(
                            children: [
                              Container(
                                width: 140,
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(record.totalPending.toString()),
                              ),
                              Container(
                                width: 200,
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(formatDateTime(
                                    record.startPending.toString())),
                              ),
                              Container(
                                width: 200,
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(formatDateTime(
                                    record.finishPending.toString())),
                              ),

                              // OPERATOR pindah ke kolom kanan pertama
                              Container(
                                width: 240,
                                height: 48,
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundImage: NetworkImage(
                                          '${AppConfig.baseUrl}/media/img/employee/${record.idEmployee}.png'),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(record.employeeName,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                width: 120,
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(formatDateTime(
                                    record.machineName.toString())),
                              ),

                              // Kolom lainnya tetap sama
                            ],
                          ),
                        );
                      },

                      itemCount: paginatedData?.results.length ?? 0,
                      rowSeparatorWidget:
                          const Divider(color: Colors.grey, height: 1),
                    ),
                  ),

                  if (isLoading)
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // ISLOADING di bawah DataTable
                ],
              ),
            ]),
      bottomNavigationBar: paginatedData != null
          ? SafeArea(
              child: Container(
                height:
                    60, // <--- penting, jangan sampai container otomatis fill
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1565C0),
                      Color(0xFF42A5F5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // PREVIOUS Button
                    TextButton(
                      onPressed: paginatedData!.previous != null
                          ? () => loadPendingPage(
                              page: _currentPage - 1, pageSize: _rowsPerPage)
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white, // warna normal
                        disabledForegroundColor:
                            Colors.grey.shade400, //  // warna saat disable
                      ),
                      child: const Text('PREVIOUS'),
                    ),
                    // Tengah: Info Total, Rows per Page, Page
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'TOTAL DATA: $_totalRecords',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14.0),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              'ROW PER PAGE: ',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.0),
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              width: 60,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButton<int>(
                                  value: _rowsPerPage,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  style: const TextStyle(color: Colors.black),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 20, child: Text('20')),
                                    DropdownMenuItem(
                                        value: 40, child: Text('40')),
                                    DropdownMenuItem(
                                        value: 60, child: Text('60')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      loadPendingPage(
                                          page: 1,
                                          pageSize:
                                              value); // reset ke halaman 1
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                            Text(
                              'PAGE $_currentPage OF ${(_totalRecords / _rowsPerPage).ceil()}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14.0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // NEXT Button
                    // NEXT
                    TextButton(
                      onPressed: paginatedData!.next != null
                          ? () => loadPendingPage(
                              page: _currentPage + 1, pageSize: _rowsPerPage)
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            Colors.grey.shade400, // terang di atas biru
                        // lebih terang
                      ),
                      child: const Text('NEXT'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
