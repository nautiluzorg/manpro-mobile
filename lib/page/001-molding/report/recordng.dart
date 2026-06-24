import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_provider_data/page/001-molding/report/ng_summary_page.dart';
import 'package:flutter_provider_data/page/001-molding/report/paginated_record_ng.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_provider_data/model/record_ng_model.dart';
import 'package:flutter_provider_data/page/menu_sub.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordNg extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordNg({super.key, required this.title, required this.idProses});

  @override
  _RecordNgState createState() => _RecordNgState();
}

class _RecordNgState extends State<RecordNg> {
  PaginatedRecordNg? paginatedData;
  late Future<RecordNgPaginatedResponse> futureData;
  bool isLoading = true;
  int _rowsPerPage = 20; // Jumlah row per page
  int _totalRecords = 0; // Total data dari API
  int _currentPage = 1; // Halaman saat ini
  bool _buttonsEnabled = true;
  int pageIndex = 0; // 0-based index halaman
  int pageSize = 20; // default page size
  String? selectedReason;
  String? selectedJobNumber;
  String? selectedNgName;
  String? selectedIdEmployeeFinish;
  String? selectedBatchNumber;
  String? selectedIdMcFinish;
  DateTime? _startDate;
  // late Future<RecordNgPaginatedResponse> _futureRecords;
  final TextEditingController _dateRangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _futureRecords =fetchRecordsForFuture(page: _currentPage, pageSize: _rowsPerPage);
    loadNgPage(page: 1, pageSize: _rowsPerPage);
  }

  Future<PaginatedRecordNg> fetchNgDataFuture({
    int page = 1,
    int pageSize = 20,
    String? jobNumber,
    String? ngName,
    String? idEmployeeFinish,
    String? batchNumber,
    String? idMcFinish,
    DateTime? startDate,
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (jobNumber != null && jobNumber.isNotEmpty) {
      queryParams['jobnumber'] = jobNumber;
    }

    if (ngName != null && ngName.isNotEmpty) {
      queryParams['ng_name'] = ngName;
    }

    if (idEmployeeFinish != null && idEmployeeFinish.isNotEmpty) {
      queryParams['id_employee_finish'] = idEmployeeFinish;
    }

    if (batchNumber != null && batchNumber.isNotEmpty) {
      queryParams['batch_number'] = batchNumber;
    }

    if (idMcFinish != null && idMcFinish.isNotEmpty) {
      queryParams['id_mc_finish'] = idMcFinish;
    }

    if (startDate != null) {
      queryParams['start_date'] =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/api/record-ng/')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PaginatedRecordNg.fromJson(jsonData);
    } else {
      throw Exception('Failed to load Record Downtime data');
    }
  }

  Future<void> loadNgPage({required int page, required int pageSize}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await fetchNgDataFuture(
        page: page,
        pageSize: pageSize,
        jobNumber: selectedJobNumber,
        ngName: selectedNgName,
        idEmployeeFinish: selectedIdEmployeeFinish,
        batchNumber: selectedBatchNumber,
        idMcFinish: selectedIdMcFinish,
        startDate: _startDate,
      );

      if (!mounted) return;

      setState(() {
        paginatedData = result;
        _currentPage = page;
        _rowsPerPage = pageSize;
        pageIndex = page - 1; // 0-based index
        _totalRecords = result.count;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading page : $e');
    }
  }

  void _clearFilters() {
    setState(() {
      selectedJobNumber = null;
      selectedNgName = null;
      selectedBatchNumber = null;
      selectedIdEmployeeFinish = null;
      selectedBatchNumber = null;
      selectedIdMcFinish = null;
      _startDate = null;
      _buttonsEnabled = true; // enable kembali button REASON
    });

    // Load semua data tanpa filter
    loadNgPage(page: 1, pageSize: _rowsPerPage);
  }

  String formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr); // parse dari format "yyyy-MM-dd"
      return DateFormat('dd-MM-yyyy').format(dt); // ubah ke "dd-MM-yyyy"
    } catch (e) {
      return dateStr; // jika gagal, kembalikan string asli
    }
  }

  Future<void> scanJobNumber(String idProses) async {
    try {
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
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // Validasi format minimal panjang QR
      if (getcode.length < 21) {
        CustomSnackbar.show(
          context,
          "Bukan QRCode Job Number, Qrcode tidak dikenali.",
          isSuccess: false,
        );
        return;
      }

      // Validasi pola QR Code (jobnumber panjang 10, dll)
      if (!RegExp(r'^[a-zA-Z0-9]{9}[a-zA-Z0-9]{10}[a-zA-Z0-9]{2}[0-9]+$')
          .hasMatch(getcode)) {
        CustomSnackbar.show(
          context,
          "Invalid QR Code format.",
          isSuccess: false,
        );
        return;
      }

      // Ambil jobnumber dari substring
      String jobnumber = getcode.substring(9, 19);

      if (getcode.isNotEmpty) {
        logPrint('Scanned QR: $getcode');

        setState(() {
          selectedJobNumber = jobnumber; // simpan jobnumber ke state
          _currentPage = 1;
          _buttonsEnabled = false; // disable tombol sementara
        });

        // reload data dengan filter jobnumber
        await loadNgPage(page: 1, pageSize: _rowsPerPage);
      }
    } on TimeoutException catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Request timed out. Please try again.",
        isSuccess: false,
      );
    } on SocketException catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "No internet connection.",
        isSuccess: false,
      );
    } on FormatException catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Error parsing server response.",
        isSuccess: false,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Unexpected error: $e",
        isSuccess: false,
      );
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
          "QRCode Employee ID tidak valid, harus 8 karakter.",
          isSuccess: false, // warna hijau + icon check
        );
        return;
      }

      if (!RegExp(r'^[0-9]{8}$').hasMatch(getcode)) {
        CustomSnackbar.show(
          context,
          "QRCode Employee ID tidak valid, harus 8 digit angka..",
          isSuccess: false, // warna hijau + icon check
        );

        return;
      }

      String employeeId = getcode; // 8 karakter ID Employee

      logPrint('Scanned Employee ID: $employeeId');

      setState(() {
        selectedIdEmployeeFinish = employeeId; // simpan jobnumber ke state
        _currentPage = 1;
        _buttonsEnabled = false; // disable tombol sementara
      });

      // reload data dengan filter jobnumber
      await loadNgPage(page: 1, pageSize: _rowsPerPage);
    } on TimeoutException catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Request timed out. Please try again..",
        isSuccess: false, // warna hijau + icon check
      );
    } on SocketException catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "No internet connection.",
        isSuccess: false, // warna hijau + icon check
      );
    } on FormatException catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Error parsing server response.",
        isSuccess: false, // warna hijau + icon check
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Unexpected error: $e.",
        isSuccess: false, // warna hijau + icon check
      );
    }
  }

  Future<void> _showNgDialog() async {
    List reasons = [];

    // 1️⃣ tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/ng/${widget.idProses}/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        reasons = data
            .where((item) =>
                item['id_ng'] != null &&
                item['id_ng'].toString().isNotEmpty &&
                item['id_ng'] != '000000')
            .toList();
      } else {
        debugPrint("Failed to load NG list, code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching reasons: $e");
    }

    // 2️⃣ tutup loading
    if (mounted) Navigator.pop(context);

    // 3️⃣ tampilkan dialog
    if (!mounted) return;
    final selectedReasonId = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Pilih NG Name',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: reasons.isEmpty
              ? const Center(child: Text('Tidak ada data'))
              : ListView.builder(
                  itemCount: reasons.length,
                  itemBuilder: (context, index) {
                    var reason = reasons[index];
                    return GestureDetector(
                      onTap: () =>
                          Navigator.pop(context, reason['id_ng'].toString()),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade300,
                              Colors.teal.shade600
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reason['ng_name'] ?? '',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(reason['description'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white70)),
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

    // 4️⃣ update state
    if (!mounted) return;
    if (selectedReasonId != null) {
      final selectedReasonObj = reasons.firstWhere(
        (item) => item['id_ng'].toString() == selectedReasonId,
        orElse: () => null,
      );

      setState(() {
        selectedReason = selectedReasonObj?['ng_name'] ?? '';
        selectedNgName = selectedReasonObj?['ng_name'] ?? '';
        _buttonsEnabled = false;
      });

      loadNgPage(page: 1, pageSize: _rowsPerPage);
    }
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
                      padding: const EdgeInsets.all(8),
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
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 136, 135, 135)
                                .withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: OrientationBuilder(
                        builder: (context, orientation) {
                          final children = [
                            // === Job Number button ===
                            SizedBox(
                              width: 120,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _buttonsEnabled
                                      ? LinearGradient(
                                          colors: [
                                            Colors.lightBlue.shade100,
                                            Colors.blue.shade500,
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
                                          scanJobNumber(widget.idProses);
                                        }
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
                                        'JOB',
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

                            // === Operator button ===
                            SizedBox(
                              width: 120,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _buttonsEnabled
                                      ? LinearGradient(
                                          colors: [
                                            Colors.purple
                                                .shade400, // menggantikan Color(0xFF8E2DE2)
                                            Colors.purple
                                                .shade700, // menggantikan Color(0xFF4A00E0)
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

                            // === Report button ===
                            SizedBox(
                              width: 140,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _buttonsEnabled
                                      ? LinearGradient(
                                          colors: [
                                            Colors.indigo.shade100,
                                            Colors.indigo.shade400,
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
                                          _showNgDialog();
                                        }
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
                                        Icons.find_in_page,
                                        size: 20,
                                        color: _buttonsEnabled
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'NG NAME',
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

                            // === Date Range field ===
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
                                            setState(() {
                                              _dateRangeController.clear();
                                              _startDate = null;
                                              _currentPage = 1;
                                              _buttonsEnabled = true;
                                            });
                                            loadNgPage(
                                                page: 1,
                                                pageSize: _rowsPerPage);
                                          },
                                        )
                                      : const SizedBox(width: 48),
                                ),
                                onTap: () async {
                                  final DateTimeRange? picked =
                                      await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                    currentDate: DateTime.now(),
                                    saveText: 'Select',
                                  );
                                  if (!mounted) return;
                                  if (picked != null) {
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
                                      _dateRangeController.text = displayText;
                                      _currentPage = 1;
                                      _buttonsEnabled = false;
                                    });
                                    await loadNgPage(
                                        page: 1, pageSize: _rowsPerPage);
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            // === Clear button ===
                            SizedBox(
                              width: 120,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.redAccent,
                                      Color.fromARGB(255, 241, 155, 155),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.zero,
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
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 4),
                                      Text(
                                        'CLEAR',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 10.0),
                            SizedBox(
                              width: 140,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _buttonsEnabled
                                      ? LinearGradient(
                                          colors: [
                                            Colors.indigo.shade100,
                                            Colors.indigo.shade400,
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
                                                  NgSummaryPage(
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
                                      borderRadius: BorderRadius.circular(3),
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
                          ];

                          return orientation == Orientation.portrait
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(children: children),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: children,
                                );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // BAGIAN BAWAH: DataTable dengan Expanded

                  Expanded(
                    child: HorizontalDataTable(
                      leftHandSideColumnWidth: 340, // NO + JOB NUMBER
                      rightHandSideColumnWidth: 800, // total kolom kanan
                      isFixedHeader: true,

                      headerWidgets: [
                        // ===== KIRI =====
                        Container(
                          width: 340,
                          height: 50,
                          alignment: Alignment.center,
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
                                  child: Text('NO',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              SizedBox(
                                width: 280,
                                child: Center(
                                  child: Text('NG NAME',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== KANAN =====
                        Container(
                          width: 120,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: const Text('NG QTY',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),

                        Container(
                          width: 120,
                          height: 50,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: const Text('JOBNUMBER',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),

                        Container(
                          width: 200,
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
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: const Text('JOB CODE',
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
                        Container(
                          width: 120,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: const Text('DATE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],

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
                              // NO
                              Container(
                                width: 60,
                                alignment: Alignment.center,
                                child: Text((pageIndex * pageSize + index + 1)
                                    .toString()),
                              ),

                              Container(
                                width: 280,
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(children: [
                                  const Icon(Icons.label_important,
                                      color: Colors.red, size: 18),
                                  const SizedBox(width: 4),
                                  Text(record.ngName)
                                ]),
                              ),
                            ],
                          ),
                        );
                      },

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
                                width: 120,
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(record.qty.toString()),
                              ),
                              Container(
                                width: 120,
                                height: 48,
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(record.jobnumber.toString(),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              // QTY

                              // OPERATOR
                              Container(
                                width: 200,
                                height: 48,
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _currentPage = 1;
                                      _buttonsEnabled = false;
                                    });
                                    loadNgPage(page: 1, pageSize: _rowsPerPage);
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(
                                            '${AppConfig.baseUrl}/media/img/employee/${record.idEmployeeFinish}.png'),
                                        onBackgroundImageError: (_, __) {},
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(record.employeeName)),
                                    ],
                                  ),
                                ),
                              ),
                              // JOB CODE
                              Container(
                                width: 120,
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(record.batchNumber.toString()),
                              ),
                              // MACHINE
                              Container(
                                width: 120,
                                height: 48,
                                alignment: Alignment.centerLeft,
                                child: Text(record.mcName.toString()),
                              ),
                              // DATE
                              Container(
                                width: 120,
                                height: 48,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    formatDate(record.startDate.toString())),
                              ),
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
                          ? () => loadNgPage(
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
                                      loadNgPage(
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
                          ? () => loadNgPage(
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

    /*
    Scaffold(
      appBar: myAppBar,
      body: Column(children: [
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

            child: Row(
              children: [
                // Job Number button

                SizedBox(
                  width: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _buttonsEnabled
                          ? LinearGradient(
                              colors: [
                                Colors.lightBlue.shade100,
                                Colors.blue.shade500,
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
                              scanJobNumber(widget.idProses);
                            }
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
                            color:
                                _buttonsEnabled ? Colors.white : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'JOB',
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

                // Operator button
                SizedBox(
                  width: 120, // samain lebar dengan button lain
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _buttonsEnabled
                          ? LinearGradient(
                              colors: [
                                Colors.teal.shade100,
                                Colors.teal.shade400,
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
                              scanEmployeeId(widget.idProses);
                            }
                          : null, // disabled jika _buttonsEnabled false
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
                            Icons.person_search,
                            size: 20,
                            color:
                                _buttonsEnabled ? Colors.white : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'OPT',
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

                // Batch button
                SizedBox(
                  width: 140,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _buttonsEnabled
                          ? LinearGradient(
                              colors: [
                                Colors.indigo.shade100,
                                Colors.indigo.shade400, // gradasi lebih gelap
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
                              // Navigasi ke halaman Report NG
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TotalNgChartPage(
                                        title: widget.title,
                                        idProses: widget.idProses)),
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
                            Icons.find_in_page,
                            size: 20,
                            color:
                                _buttonsEnabled ? Colors.white : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'REPORT NG',
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
                        color: Color.fromARGB(255, 107, 102, 102)),
                    decoration: InputDecoration(
                      labelText: 'DATE RANGE',
                      labelStyle:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 10),
                      prefixIcon: const Icon(Icons.calendar_month, size: 20),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 35,
                        minHeight: 30,
                      ),
                      suffixIcon: _dateRangeController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setState(() {
                                  _dateRangeController.clear();
                                  _currentPage = 1;
                                  // clear list sebelumnya
                                  _futureRecords = fetchRecordsForFuture(
                                      page: 1, pageSize: _rowsPerPage);
                                  _buttonsEnabled = true;
                                });
                              },
                            )
                          : const SizedBox(
                              width:
                                  48), // tetap ada "ruang" supaya tinggi sama
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
                        _dateRangeController.text =
                            '${picked.start.day.toString().padLeft(2, '0')}-'
                            '${picked.start.month.toString().padLeft(2, '0')}-'
                            '${picked.start.year} TO '
                            '${picked.end.day.toString().padLeft(2, '0')}-'
                            '${picked.end.month.toString().padLeft(2, '0')}-'
                            '${picked.end.year}';

                        setState(() {
                          _currentPage = 1;
                          _futureRecords = fetchRecordsForFuture(
                                  page: 1, pageSize: _rowsPerPage)
                              .whenComplete(() {
                            setState(() {
                              _buttonsEnabled =
                                  false; // semua button jadi disable
                            });
                          });
                          // reset pagination
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(width: 10.0),
                SizedBox(
                    width: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.redAccent,
                            const Color.fromARGB(255, 241, 155, 155),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.zero, // tetap kotak
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentPage = 1;
                            _rowsPerPage = 20;
                            _dateRangeController.clear();
                            _futureRecords = fetchRecordsForFuture(page: 1);
                            _buttonsEnabled = true; // ← re-enable semua button
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // tetap persegi
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                    ))
              ],
            ),
          ),
        ),

//Sampai sini***********************
        Expanded(
          child: FutureBuilder<RecordNgPaginatedResponse>(
            future: _futureRecords,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
                return const Center(child: Text('No data found'));
              }

              final data = snapshot.data!;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Stack(
                          children: [
                            // background gradient untuk heading row
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 50, // tinggi header row default DataTable
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF0D47A1), // navy blue
                                      Color(0xFF42A5F5), // sky blue
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            // DataTable transparan headingRowColor agar gradient kelihatan
                            DataTableTheme(
                              data: DataTableThemeData(
                                headingRowColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                headingTextStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('NO')),
                                  DataColumn(label: Text('NG NAME')),
                                  DataColumn(label: Text('QTY')),
                                  DataColumn(label: Text('JOBNUMBER')),
                                  DataColumn(label: Text('OPERATOR')),
                                  DataColumn(label: Text('MACHINE')),
                                  DataColumn(label: Text('DATE')),
                                  DataColumn(label: Text('JOB CODE')),
                                ],
                                rows: data.results.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  final r = entry.value;
                                  int nomor =
                                      (_currentPage - 1) * _rowsPerPage +
                                          index +
                                          1;

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(nomor.toString())),
                                      DataCell(Text(r.ngName)),
                                      DataCell(Text(r.qty.toString())),
                                      DataCell(Text(r.jobnumber)),
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                '${AppConfig.baseUrl}/media/img/employee/${r.idEmployeeFinish}.png',
                                              ),
                                              onBackgroundImageError:
                                                  (error, stackTrace) {},
                                            ),
                                            const SizedBox(width: 8),
                                            Text(r.employeeName),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(r.mcName)),
                                      DataCell(Text(formatDate(r.startDate))),
                                      DataCell(Text(r.batchNumber)),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Pagination Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1565C0), // biru tua
                          Color(0xFF42A5F5), // biru muda
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Tombol PREV di kiri
                        ElevatedButton(
                          onPressed: _currentPage > 1
                              ? () => _loadPage(_currentPage - 1)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            disabledBackgroundColor:
                                Colors.white.withAlpha((0.5 * 255).round()),
                            disabledForegroundColor:
                                Colors.blue.withAlpha((0.5 * 255).round()),
                          ),
                          child: const Text('Prev'),
                        ),

                        // Spacer + Tengah: TOTAL DATA + Rows per page + Page Info
                        Expanded(
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // TOTAL DATA
                                Text(
                                  'TOTAL DATA: $_totalRecords',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 20),

                                // ROWS PER PAGE
                                const Text(
                                  'ROW PER PAGE: ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 60,
                                  child: DropdownButton<int>(
                                    value: _rowsPerPage,
                                    dropdownColor: Colors.blue.shade100,
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
                                        setState(() {
                                          _rowsPerPage = value;
                                          _currentPage = 1;
                                          _loadPage(_currentPage);
                                        });
                                      }
                                    },
                                  ),
                                ),

                                const SizedBox(width: 30),

                                // Page Info
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'Page $_currentPage of ${(_totalRecords / _rowsPerPage).ceil()}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tombol NEXT di kanan
                        ElevatedButton(
                          onPressed:
                              (_currentPage * _rowsPerPage < _totalRecords)
                                  ? () => _loadPage(_currentPage + 1)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            disabledBackgroundColor:
                                Colors.white.withAlpha((0.5 * 255).round()),
                            disabledForegroundColor:
                                Colors.blue.withAlpha((0.5 * 255).round()),
                          ),
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  )


                ],
              );
            },
          ),
        ),
      ]),
    );

    */
  }
}


/*
//FITUR INFINITE SCROLL DENGAN METODE SERVER SIDE

import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/menu.dart';

class RecordNg extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordNg({super.key, required this.title, required this.idProses});

  @override
  _RecordNgState createState() => _RecordNgState();
}

class RecordNgModel {
  final String ngName;
  final int qty;
  final String jobnumber;
  final String employeeName;
  final String mcName;
  final String batchNumber;
  final int idEmployeeFinish;

  RecordNgModel({
    required this.ngName,
    required this.qty,
    required this.jobnumber,
    required this.employeeName,
    required this.mcName,
    required this.batchNumber,
    required this.idEmployeeFinish,
  });
}

class _RecordNgState extends State<RecordNg> {
  final ScrollController _scrollController = ScrollController();

  final List<RecordNgModel> _allRecords = List.generate(
    100,
    (index) => RecordNgModel(
      ngName: 'NG Item ${index + 1}',
      qty: (index + 1) * 2,
      jobnumber: 'JOB-${1000 + index}',
      employeeName: 'Operator ${index % 10 + 1}',
      mcName: 'Machine ${index % 5 + 1}',
      batchNumber: 'BATCH-${500 + index}',
      idEmployeeFinish: index % 10 + 1,
    ),
  );

  List<RecordNgModel> _records = [];
  final int _rowsPerPage = 20;
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadNextBatch();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadNextBatch();
      }
    });
  }

  void _loadNextBatch() {
    if (_isLoading) return;
    _isLoading = true;

    // Simulate delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final nextIndex = _currentIndex + _rowsPerPage;
      setState(() {
        _records.addAll(_allRecords.sublist(
          _currentIndex,
          nextIndex > _allRecords.length ? _allRecords.length : nextIndex,
        ));
        _currentIndex = nextIndex;
        _hasMore = _currentIndex < _allRecords.length;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          title: Text(widget.title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontFamily: "Montserrat")),
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
      body: Column(
        children: [
          // =================== FILTER / BUTTONS ===================
          Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade50, Colors.grey.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(0),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search,
                                size: 20, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text('JOB'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search,
                                size: 20, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text('OPT',
                                style: TextStyle(color: Colors.blueAccent)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.find_in_page,
                                size: 20, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text('CODE'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.precision_manufacturing,
                                size: 20, color: Colors.black),
                            const SizedBox(width: 4),
                            Text('MCHN'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(width: 260, child: TextField()),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _records.clear();
                            _currentIndex = 0;
                            _hasMore = true;
                            _loadNextBatch();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: Text('CLEAR',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =================== RECORD LIST ===================
          Expanded(
            child: _records.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _records.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _records.length) {
                        if (_hasMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('No more data')),
                          );
                        }
                      }

                      final r = _records[index];
                      int nomor = index + 1;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: Text(nomor.toString()),
                          title: Text(r.ngName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Qty: ${r.qty}'),
                              Text('Job: ${r.jobnumber}'),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    child: Text(r.idEmployeeFinish.toString()),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Operator: ${r.employeeName}'),
                                ],
                              ),
                              Text('Machine: ${r.mcName}'),
                              Text('Batch: ${r.batchNumber}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


*/