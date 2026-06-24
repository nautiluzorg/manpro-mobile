import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/master/product_model.dart';
import 'package:flutter_provider_data/model/record_completed_model.dart';
import 'package:flutter_provider_data/page/001-molding/report/batch_summary.dart';
import 'package:flutter_provider_data/page/001-molding/report/paginated_record_completed.dart';
import 'package:flutter_provider_data/page/001-molding/report/record_completed_detail_dialog.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/page/menu_sub.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordCompleted extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordCompleted(
      {super.key, required this.title, required this.idProses});

  @override
  _RecordCompletedState createState() => _RecordCompletedState();
}

class _RecordCompletedState extends State<RecordCompleted> {
  PaginatedRecordCompleted? paginatedData;
  List<EmployeeModel> _employeeList = [];
  List<ProductModel> _productList = [];
  EmployeeModel? selectedEmployeeItem;
  ProductModel? selectedDrawingItem;
  bool _isEmployeeLoading = false;
  bool _isDrawingLoading = false;
  bool isLoading = true;
  int _rowsPerPage = 20; // Jumlah row per page
  int _totalRecords = 0; // Total data dari API
  int _currentPage = 1; // Halaman saat ini

  String? selectedJobNumber;
  String? selectedIdEmployeeFinish;
  String? selectedBatchNumber;
  String? selectedIdMcFinish;
  String? selectedDrawingNumber;
  String? selectedDrawingDropdown;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _dateRangeController = TextEditingController();

  bool _buttonsEnabled = true;
  int pageIndex = 0; // 0-based index halaman
  int pageSize = 20; // default page size
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchEmployee = false;
  bool _isSelectingEmployee = false;
  bool _showSearchDrawing = false;
  bool _isSelectingDrawing = false;

  @override
  void initState() {
    super.initState();
    // Load data setelah frame pertama agar navigasi smooth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDataPage(page: 1, pageSize: _rowsPerPage);
    });
  }

  Future<PaginatedRecordCompleted> fetchCompletedDataFuture({
    int page = 1,
    int pageSize = 20,
    String? jobNumber,
    String? idEmployeeFinish,
    String? batchNumber,
    String? idMcFinish,
    String? drawingNumber,
    DateTime? startTimeFrom,
    DateTime? startTimeTo,
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (jobNumber != null && jobNumber.isNotEmpty) {
      queryParams['jobnumber'] = jobNumber;
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

    if (drawingNumber != null && drawingNumber.isNotEmpty) {
      queryParams['drawing_number'] = drawingNumber;
    }

    if (startTimeFrom != null) {
      queryParams['start_time_from'] =
          '${startTimeFrom.year}-${startTimeFrom.month.toString().padLeft(2, '0')}-${startTimeFrom.day.toString().padLeft(2, '0')}';
    }

    if (startTimeTo != null) {
      queryParams['start_time_to'] =
          '${startTimeTo.year}-${startTimeTo.month.toString().padLeft(2, '0')}-${startTimeTo.day.toString().padLeft(2, '0')}';
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/api/record-list-completed/')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PaginatedRecordCompleted.fromJson(jsonData);
    } else {
      throw Exception('Failed to load Record Downtime data');
    }
  }

  Future<void> loadDataPage({required int page, required int pageSize}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await fetchCompletedDataFuture(
        page: page,
        pageSize: pageSize,
        jobNumber: selectedJobNumber,
        idEmployeeFinish: selectedIdEmployeeFinish,
        batchNumber: selectedBatchNumber,
        idMcFinish: selectedIdMcFinish,
        drawingNumber: selectedDrawingNumber,
        startTimeFrom: _startDate,
        startTimeTo: _endDate,
      );

      if (!mounted) return; //Tambahan baru.

      setState(() {
        paginatedData = result;
        _currentPage = page;
        _rowsPerPage = pageSize;
        pageIndex = page - 1; // 0-based index
        _totalRecords = result.count;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; //Tambahan baru
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading page : $e');
    }
  }

  void _clearFilters() {
    setState(() {
      selectedJobNumber = null;
      selectedBatchNumber = null;
      selectedIdEmployeeFinish = null;
      selectedBatchNumber = null;
      selectedIdMcFinish = null;
      selectedDrawingNumber = null;
      _startDate = null;
      _endDate = null;
      _buttonsEnabled = true; // enable kembali button REASON
      _dateRangeController.clear();
      _searchController.clear();
    });

    // Load semua data tanpa filter
    loadDataPage(page: 1, pageSize: _rowsPerPage);
  }

  String formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr); // parse dari format "yyyy-MM-dd"
      return DateFormat('dd-MM-yyyy').format(dt); // ubah ke "dd-MM-yyyy"
    } catch (e) {
      return dateStr; // jika gagal, kembalikan string asli
    }
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('dd-MM-yyyy HH:mm').format(dt);
    } catch (e) {
      return dateTimeStr;
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
        await loadDataPage(page: 1, pageSize: _rowsPerPage);
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

      String employeeId = getcode;

      logPrint('Scanned Employee ID: $employeeId');

      setState(() {
        selectedIdEmployeeFinish = employeeId; // simpan jobnumber ke state
        _currentPage = 1;
        _buttonsEnabled = false; // disable tombol sementara
      });

      // reload data dengan filter jobnumber
      await loadDataPage(page: 1, pageSize: _rowsPerPage);
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

  Future<void> _loadEmployeeList() async {
    setState(() => _isEmployeeLoading = true);
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.baseUrl}/api/employee-list-search/')); // ganti URL API kamu

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _employeeList = data.map((e) => EmployeeModel.fromJson(e)).toList();
        });
      } else {
        logPrint('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      logPrint('Error loading employees: $e');
    } finally {
      setState(() => _isEmployeeLoading = false);
    }
  }

  Future<void> _loadDrawingList() async {
    setState(() => _isDrawingLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/product-dropdown-list/'), // endpoint baru
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body); // langsung decode list
        setState(() {
          _productList = data.map((e) => ProductModel.fromJson(e)).toList();
        });
      } else {
        logPrint('Failed to load drawing list: ${response.statusCode}');
      }
    } catch (e) {
      logPrint('Error loading drawing list: $e');
    } finally {
      setState(() => _isDrawingLoading = false);
    }
  }

  void showFullScreenDialog(BuildContext context, RecordCompletedModel r) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          RecordCompletedDetailDialog(recordId: r.idRecord),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ));
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
            'MOLDING COMPLETED',
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
      body: Stack(
        children: [
          Column(
            children: [
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
                      final screenWidth = MediaQuery.of(context).size.width;

                      final children = [
                        // === JOB Button ===

                        SizedBox(
                          width: screenWidth * 0.16, // 15% dari lebar layar
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
                              onPressed: null,
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
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // kiri-kanan
                                children: [
                                  GestureDetector(
                                    onTap: _buttonsEnabled
                                        ? () => scanJobNumber(widget.idProses)
                                        : null,
                                    child: Icon(
                                      Icons.qr_code_scanner, // ikon kiri
                                      size: 24,
                                      color: _buttonsEnabled
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'JOB',
                                    style: TextStyle(
                                      color: _buttonsEnabled
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _buttonsEnabled
                                        ? () {
                                            setState(() {
                                              _showSearch =
                                                  !_showSearch; // toggle search bar
                                            });
                                          }
                                        : null,
                                    child: Icon(
                                      Icons.search_sharp, // ikon kanan
                                      size: 24,
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

                        SizedBox(width: screenWidth * 0.01), // spacing 2% layar

                        // === OPT Button ===
                        SizedBox(
                          width: screenWidth * 0.16,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _buttonsEnabled
                                  ? LinearGradient(
                                      colors: [
                                        Colors.purple.shade400,
                                        Colors.purple.shade700
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
                              onPressed: null,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: _buttonsEnabled
                                        ? () => scanEmployeeId(widget.idProses)
                                        : null,
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      size: 24,
                                      color: _buttonsEnabled
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                  // const SizedBox(width: 4),
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

                                  GestureDetector(
                                    onTap: _buttonsEnabled
                                        ? () async {
                                            setState(() {
                                              _showSearchEmployee = true;
                                              _showSearch = false;
                                            });

                                            // Kalau list employee masih kosong, fetch dari API
                                            if (_employeeList.isEmpty) {
                                              await _loadEmployeeList();
                                            }
                                          }
                                        : null,
                                    child: Icon(
                                      Icons.person_search, // ikon kanan
                                      size: 24,
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

                        SizedBox(width: screenWidth * 0.01),

                        SizedBox(
                          width: screenWidth * 0.11, // 20% layar
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _buttonsEnabled
                                  ? LinearGradient(
                                      colors: [
                                        Colors.teal.shade300,
                                        Colors.cyan.shade400,
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
                              onPressed: _buttonsEnabled
                                  ? () async {
                                      setState(() {
                                        _showSearchDrawing = true;
                                        _showSearch = false;
                                        _showSearchEmployee = false;
                                      });

                                      // Kalau list employee masih kosong, fetch dari API
                                      if (_productList.isEmpty) {
                                        await _loadDrawingList();
                                      }
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
                                    Icons.search_sharp,
                                    size: 20,
                                    color: _buttonsEnabled
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'DRW',
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

                        SizedBox(width: screenWidth * 0.01),

                        // === SUMMARY Button ===
                        SizedBox(
                          width: screenWidth * 0.11, // 20% layar
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
                              onPressed: () {
                                navigateWithFade(
                                    context,
                                    BatchSummary(
                                      title: 'SUMARRY RESULT',
                                      idProses: widget.idProses,
                                    ));
                              },
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
                                    Icons.list_alt,
                                    size: 20,
                                    color: _buttonsEnabled
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'SUM',
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

                        SizedBox(width: screenWidth * 0.01),

                        // === DATE RANGE Field ===
                        SizedBox(
                          width: screenWidth * 0.25, // 25% layar
                          child: TextField(
                            controller: _dateRangeController,
                            readOnly: true,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 107, 102, 102),
                            ),
                            decoration: InputDecoration(
                              labelText: 'RECORD DATE',
                              labelStyle: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 10),
                              prefixIcon:
                                  const Icon(Icons.calendar_month, size: 20),
                              prefixIconConstraints: const BoxConstraints(
                                  minWidth: 35, minHeight: 30),
                              suffixIcon: _dateRangeController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _dateRangeController.clear();
                                          _startDate = null;
                                          _endDate =
                                              null; // <-- reset end date juga
                                          _currentPage = 1;
                                          _buttonsEnabled = true;
                                        });
                                        loadDataPage(
                                            page: 1, pageSize: _rowsPerPage);
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
                                  _endDate = end; // <-- simpan end date
                                  _dateRangeController.text = displayText;
                                  _currentPage = 1;
                                  _buttonsEnabled = false;
                                });

                                await loadDataPage(
                                    page: 1, pageSize: _rowsPerPage);
                              }
                            },
                          ),
                        ),

                        SizedBox(width: screenWidth * 0.01),

                        // === CLEAR Button ===
                        SizedBox(
                          width: screenWidth * 0.14,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.redAccent,
                                  Color.fromARGB(255, 241, 155, 155)
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
                              child: const Text(
                                'CLEAR',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ];

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: children),
                      );
                    },
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: paginatedData == null || paginatedData!.results.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : HorizontalDataTable(
                          leftHandSideColumnWidth: 180, // kolom NO + JOBNUMBER
                          rightHandSideColumnWidth: 1980, // total kolom kanan
                          isFixedHeader: true,

                          headerWidgets: [
                            // ======== KIRI (LEFT SIDE) ========
                            // left header
                            Container(
                              width: 180, // 60 + 120
                              height: 50,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
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
                                                fontWeight: FontWeight.bold))),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Center(
                                        child: Text('JOBNUMBER',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                  ),
                                ],
                              ),
                            ),

                            // ======== KANAN (RIGHT SIDE) ========
                            Container(
                              width: 130,
                              height: 50,
                              alignment: Alignment.center,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: const Text('JOBCODE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),

                            Container(
                              width: 80,
                              height: 50,
                              alignment: Alignment.center,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('LOT',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            Container(
                              width: 200,
                              height: 50,
                              alignment: Alignment.center,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('DRAWING NUMBER',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            Container(
                              width: 220,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('OPERATOR',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('MACHINE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            Container(
                              width: 120,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('CATEGORY',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            Container(
                              width: 120,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('TYPE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('START',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('FINISH',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),

                            Container(
                              width: 120,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('TOTAL TIME',
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
                              width: 120,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('DOWNTIME',
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
                              width: 120,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('CYCLETIME',
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
                              width: 100,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('JOB QTY',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Text('(Pcs)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                          fontSize: 12)),
                                ],
                              ),
                            ),

                            Container(
                              width: 100,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('NG QTY',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Text('(Pcs)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                          fontSize: 12)),
                                ],
                              ),
                            ),

                            Container(
                              width: 100,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              // color: const Color(0xFF1565C0),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(
                                        0xFF0D47A1), // navy blue (adjust this to match your desired color)
                                    Color(
                                        0xFF42A5F5), // sky blue (adjust this to match your desired color)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('GOOD QTY',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Text('(Pcs)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],

                          leftSideItemBuilder: (context, index) {
                            if (paginatedData == null ||
                                paginatedData!.results.isEmpty) {
                              return Container(
                                height: 48,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Data Waiting...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            final record = paginatedData!.results[index];

                            final Color rowColor = index % 2 == 0
                                ? Colors.grey.shade100
                                : Colors.white;

                            return Container(
                              color: rowColor,
                              width: 180, // gabungan NO + JOBNUMBER
                              height: 48,
                              child: Row(
                                children: [
                                  // NO
                                  Container(
                                    width: 60,
                                    alignment: Alignment.center,
                                    child: Text(
                                      ((_currentPage - 1) * _rowsPerPage +
                                              index +
                                              1)
                                          .toString(),
                                    ),
                                  ),

                                  // JOBNUMBER + ICON
                                  Container(
                                    width: 120,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 4),
                                    child: InkWell(
                                      onTap: () =>
                                          showFullScreenDialog(context, record),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.label_important,
                                              color: Colors.blue, size: 18),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              record.jobNumber ?? '-',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },

                          rightSideItemBuilder: (context, index) {
                            final record = paginatedData!.results[index];
                            final Color rowColor = index % 2 == 0
                                ? Colors.grey.shade100
                                : Colors.white;

                            return Container(
                              color: rowColor,
                              child: Row(children: [
                                Container(
                                  width: 130,
                                  height: 48,
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedBatchNumber = record.jobCode;
                                        _dateRangeController.clear();
                                        _buttonsEnabled = false;
                                      });
                                      loadDataPage(
                                          page: 1, pageSize: _rowsPerPage);
                                    },
                                    child: Text(record.jobCode,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.blueGrey.shade600)),
                                  ),
                                ),
                                Container(
                                    width: 80,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Text(record.lotNumber.toString())),
                                Container(
                                  width: 200,
                                  height: 48,
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedDrawingNumber =
                                            record.drawNumber;
                                      });
                                      loadDataPage(
                                          page: 1, pageSize: _rowsPerPage);
                                      _dateRangeController.clear();
                                      _buttonsEnabled = false;
                                    },
                                    child: Text(record.drawNumber.toString(),
                                        style: TextStyle(
                                            color: Colors.blueGrey.shade600)),
                                  ),
                                ),
                                SizedBox(
                                  width: 220,
                                  height: 48,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedIdEmployeeFinish =
                                            record.idEmployeeFinish;
                                        _dateRangeController.clear();
                                        _buttonsEnabled = false;
                                      });
                                      loadDataPage(
                                          page: 1, pageSize: _rowsPerPage);
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
                                          child: Text(record.operatorName,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 62, 134, 175))),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                    width: 150,
                                    height: 48,
                                    alignment: Alignment.centerLeft,
                                    child: Text(record.machineName,
                                        style: TextStyle(
                                            color: Colors.lightBlue.shade900))),
                                Container(
                                    width: 120,
                                    height: 48,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        record.productCategory.toString())),
                                Container(
                                    width: 120,
                                    height: 48,
                                    alignment: Alignment.centerLeft,
                                    child: Text(record.productType.toString())),
                                Container(
                                    width: 150,
                                    height: 48,
                                    alignment: Alignment.centerLeft,
                                    child: Text(formatDateTime(
                                        record.startTime.toString()))),
                                Container(
                                    width: 150,
                                    height: 48,
                                    alignment: Alignment.centerLeft,
                                    child: Text(formatDateTime(
                                        record.finishTime.toString()))),
                                Container(
                                    width: 120,
                                    height: 48,
                                    alignment: Alignment.centerLeft,
                                    child: Text(record.totalTime.toString())),
                                Container(
                                    width: 120,
                                    height: 48,
                                    alignment: Alignment.centerLeft,
                                    child: Text(record.downtime.toString())),
                                Container(
                                    width: 120,
                                    height: 48,
                                    alignment: Alignment.centerLeft,
                                    child: Text(record.cycleTime.toString())),
                                Container(
                                    width: 100,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Text(record.startQty.toString())),
                                Container(
                                    width: 100,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Text(record.ng.toString(),
                                        style: TextStyle(
                                            color: record.ng == 0
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold))),
                                Container(
                                    width: 100,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Text(record.good.toString())),
                              ]),
                            );
                          },

                          itemCount: paginatedData?.results.length ?? 0,
                          rowSeparatorWidget:
                              const Divider(color: Colors.grey, height: 1),
                        ),
                ),
              ),

              // const SizedBox(height: 80), // <== Tambahkan ruang agar tidak tertutup
            ],
          ),

          // ==========================
          // SEARCH JOBNUMBER
          // ==========================

          if (_showSearch)
            Positioned(
              top: kToolbarHeight + 8,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 107, 102, 102),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search by Jobnumber...',
                            labelText: 'JOBNUMBER',
                            labelStyle:
                                TextStyle(fontSize: 12, color: Colors.grey),
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent,
                              Colors.lightBlueAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedJobNumber = _searchController.text.trim();
                              _currentPage = 1;
                              _buttonsEnabled = false;
                            });
                            loadDataPage(page: 1, pageSize: _rowsPerPage);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            'SEARCH',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showSearch = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_showSearchEmployee)
            Positioned(
              top: kToolbarHeight + 8,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _isEmployeeLoading
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownSearch<EmployeeModel>(
                                items: (f, cs) => _employeeList,
                                itemAsString: (EmployeeModel? item) =>
                                    item?.fullName ?? '',
                                compareFn:
                                    (EmployeeModel? a, EmployeeModel? b) =>
                                        a?.idEmployee == b?.idEmployee,
                                onChanged: (EmployeeModel? selected) async {
                                  if (_isSelectingEmployee || selected == null)
                                    return; // cegah double tap

                                  _isSelectingEmployee = true;

                                  if (!mounted) return;
                                  setState(() {
                                    selectedEmployeeItem = selected;
                                    selectedIdEmployeeFinish =
                                        selected.idEmployee;
                                    _buttonsEnabled = false;
                                  });

                                  // Tambahan delay singkat supaya UX lebih smooth
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));

                                  if (mounted) {
                                    loadDataPage(
                                        page: 1,
                                        pageSize:
                                            _rowsPerPage); // langsung load data
                                  }

                                  _isSelectingEmployee = false;
                                },
                                decoratorProps: const DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: "Pilih Operator",
                                    hintText: "Nama Operator",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 5, top: 10, bottom: 10, right: 8),
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      labelText: "Cari Operator",
                                      hintText: "Ketik nama Operator...",
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    keyboardType: TextInputType.text,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                  ),
                                  itemBuilder: (context, EmployeeModel item,
                                      isDisabled, isSelected) {
                                    final imageUrl =
                                        '${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png';
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 10.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0)),
                                      elevation: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.grey.shade100,
                                              Colors.grey.shade400
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                          child: ListTile(
                                            leading: ClipOval(
                                              child: Image.network(
                                                imageUrl,
                                                width: 52,
                                                height: 52,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const CircleAvatar(
                                                    radius: 21,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Icon(Icons.person,
                                                        color: Colors.grey,
                                                        size: 26),
                                                  );
                                                },
                                              ),
                                            ),
                                            title: Text(
                                              item.fullName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                            subtitle: Text(
                                              item.nrp,
                                              style: const TextStyle(
                                                  color: Colors.blueGrey),
                                            ),
                                            onTap: () {
                                              if (_isSelectingEmployee) {
                                                return;
                                              } // cegah double tap
                                              _isSelectingEmployee = true;

                                              if (!mounted) return;
                                              setState(() {
                                                selectedEmployeeItem = item;
                                                selectedIdEmployeeFinish =
                                                    item.idEmployee;
                                              });

                                              // delay untuk loadDataPage tanpa menyentuh context
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 200), () {
                                                if (!mounted) return;
                                                loadDataPage(
                                                    page: 1,
                                                    pageSize: _rowsPerPage);
                                                Navigator.of(context).pop(item);
                                                _isSelectingEmployee = false;
                                              });
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
                                            0.80,
                                    minWidth:
                                        MediaQuery.of(context).size.width *
                                            0.98,
                                  ),
                                  menuProps: const MenuProps(
                                    margin: EdgeInsets.only(top: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showSearchEmployee = false;
                            selectedEmployeeItem = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_showSearchDrawing)
            Positioned(
              top: kToolbarHeight + 8,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _isDrawingLoading
                            ? Center(
                                child: SizedBox(
                                  width: 10,
                                  height: 10,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : DropdownSearch<ProductModel>(
                                items: (f, cs) => _productList,
                                itemAsString: (ProductModel? item) =>
                                    item?.drawingNumber ?? '',
                                compareFn: (ProductModel? a, ProductModel? b) =>
                                    a?.drawingNumber == b?.drawingNumber,
                                onChanged: (ProductModel? selected) async {
                                  if (_isSelectingDrawing || selected == null) {
                                    return;
                                  }

                                  _isSelectingDrawing = true;

                                  if (!mounted) return;
                                  setState(() {
                                    selectedDrawingItem = selected;
                                    selectedDrawingNumber =
                                        selected.drawingNumber;
                                    _buttonsEnabled = false;
                                  });

                                  // Segera load data
                                  await loadDataPage(
                                      page: 1, pageSize: _rowsPerPage);

                                  _isSelectingDrawing = false;
                                },
                                decoratorProps: const DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: "Pilih Drawing No",
                                    hintText: "Drawing No",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 5, top: 10, bottom: 10, right: 8),
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      labelText: "Cari Drawing No",
                                      hintText: "Drawing No...",
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    keyboardType: TextInputType.text,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                  ),
                                  itemBuilder: (context, ProductModel item,
                                      isDisabled, isSelected) {
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 10.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0)),
                                      elevation: 2,
                                      child: ListTile(
                                        title: Text(
                                          item.drawingNumber,
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14.0,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        subtitle: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: item.productCategory,
                                                style: TextStyle(
                                                  color: Colors.purple[
                                                      400], // warna default
                                                  fontSize: 14,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' - ', // tanda pemisah
                                                style: const TextStyle(
                                                  color: Colors
                                                      .blueGrey, // tetap blueGrey
                                                  fontSize: 14,
                                                ),
                                              ),
                                              TextSpan(
                                                text: item.productType,
                                                style: TextStyle(
                                                  color: Colors.blue[
                                                      400], // warna cyan[100]
                                                  fontSize: 14,
                                                  fontWeight: FontWeight
                                                      .normal, // optional
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' - ', // tanda pemisah
                                                style: const TextStyle(
                                                  color: Colors
                                                      .blueGrey, // tetap blueGrey
                                                  fontSize: 14,
                                                ),
                                              ),
                                              TextSpan(
                                                text: item.companyName,
                                                style: TextStyle(
                                                  color: Colors.cyan[
                                                      400], // warna cyan[100]
                                                  fontSize: 14,
                                                  fontWeight: FontWeight
                                                      .normal, // optional
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () async {
                                          if (_isSelectingDrawing) return;
                                          _isSelectingDrawing = true;

                                          if (!mounted) return;
                                          setState(() {
                                            selectedDrawingItem = item;
                                            selectedDrawingNumber =
                                                item.drawingNumber;
                                          });

                                          // Tunggu frame selesai agar state benar-benar update
                                          await Future.delayed(Duration.zero);
                                          if (!mounted) return;
                                          await loadDataPage(
                                              page: 1, pageSize: _rowsPerPage);
                                          Navigator.of(context).pop(item);
                                          _isSelectingDrawing = false;
                                        },
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
                                            0.80,
                                    minWidth:
                                        MediaQuery.of(context).size.width *
                                            0.98,
                                  ),
                                  menuProps: const MenuProps(
                                    margin: EdgeInsets.only(top: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showSearchDrawing = false;
                            selectedDrawingItem = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ==========================
          // LOADING OVERLAY
          // ==========================
          if (isLoading)
            const Opacity(
              opacity: 0.3,
              child: ModalBarrier(
                dismissible: false,
                color: Colors.black,
              ),
            ),
        ],
      ),
      bottomNavigationBar: paginatedData != null
          ? SafeArea(
              // <== penting supaya tidak tertutup sistem (gesture bar)
              child: Container(
                height: 60,
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
                          ? () => loadDataPage(
                              page: _currentPage - 1, pageSize: _rowsPerPage)
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.grey.shade400,
                      ),
                      child: const Text('PREVIOUS'),
                    ),
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
                                  underline: const SizedBox(),
                                  style: const TextStyle(color: Colors.black),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 20, child: Text('20')),
                                    DropdownMenuItem(
                                        value: 40, child: Text('40')),
                                    DropdownMenuItem(
                                        value: 80, child: Text('80')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      loadDataPage(page: 1, pageSize: value);
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
                    TextButton(
                      onPressed: paginatedData!.next != null
                          ? () => loadDataPage(
                              page: _currentPage + 1, pageSize: _rowsPerPage)
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.grey.shade400,
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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(0),
                  child: Text("Halaman Menu"),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child:
                        paginatedData == null || paginatedData!.results.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : const Center(child: Text("Testing 1..2..3")),
                  ),
                ),
              ],
            ),

            // ==========================
            // SEARCH JOBNUMBER
            // ==========================
            if (_showSearch)
              Positioned(
                top: kToolbarHeight + 8,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 107, 102, 102),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search by Jobnumber...',
                              labelText: 'JOBNUMBER',
                              labelStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blueAccent,
                                Colors.lightBlueAccent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedJobNumber =
                                    _searchController.text.trim();
                                _currentPage = 1;
                                _buttonsEnabled = false;
                              });
                              loadDataPage(page: 1, pageSize: _rowsPerPage);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            child: const Text(
                              'SEARCH',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showSearch = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ==========================
            // SEARCH EMPLOYEE
            // ==========================
            if (_showSearchEmployee)
              Positioned(
                top: kToolbarHeight + 8,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _isEmployeeLoading
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownSearch<EmployeeModel>(
                                  items: (f, cs) => _employeeList,
                                  itemAsString: (EmployeeModel? item) =>
                                      item?.fullName ?? '',
                                  compareFn:
                                      (EmployeeModel? a, EmployeeModel? b) =>
                                          a?.idEmployee == b?.idEmployee,
                                  onChanged: (EmployeeModel? selected) async {
                                    if (_isSelectingEmployee ||
                                        selected == null)
                                      return; // cegah double tap

                                    _isSelectingEmployee = true;

                                    if (!mounted) return;
                                    setState(() {
                                      selectedEmployeeItem = selected;
                                      selectedIdEmployeeFinish =
                                          selected.idEmployee;
                                      _buttonsEnabled = false;
                                    });

                                    // Tambahan delay singkat supaya UX lebih smooth
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));

                                    if (mounted) {
                                      loadDataPage(
                                          page: 1,
                                          pageSize:
                                              _rowsPerPage); // langsung load data
                                    }

                                    _isSelectingEmployee = false;
                                  },
                                  decoratorProps: const DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: "Pilih Operator",
                                      hintText: "Nama Operator",
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 5,
                                          top: 10,
                                          bottom: 10,
                                          right: 8),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Cari Operator",
                                        hintText: "Ketik nama Operator...",
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      keyboardType: TextInputType.text,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                    ),
                                    itemBuilder: (context, EmployeeModel item,
                                        isDisabled, isSelected) {
                                      final imageUrl =
                                          '${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png';
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 10.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0)),
                                        elevation: 2,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.grey.shade100,
                                                Colors.grey.shade400
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
                                            child: ListTile(
                                              leading: ClipOval(
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 52,
                                                  height: 52,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const CircleAvatar(
                                                      radius: 21,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(Icons.person,
                                                          color: Colors.grey,
                                                          size: 26),
                                                    );
                                                  },
                                                ),
                                              ),
                                              title: Text(
                                                item.fullName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14.0,
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                              subtitle: Text(
                                                item.nrp,
                                                style: const TextStyle(
                                                    color: Colors.blueGrey),
                                              ),
                                              onTap: () {
                                                if (_isSelectingEmployee) {
                                                  return;
                                                } // cegah double tap
                                                _isSelectingEmployee = true;

                                                if (!mounted) return;
                                                setState(() {
                                                  selectedEmployeeItem = item;
                                                  selectedIdEmployeeFinish =
                                                      item.idEmployee;
                                                });

                                                // delay untuk loadDataPage tanpa menyentuh context
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 200), () {
                                                  if (!mounted) return;
                                                  loadDataPage(
                                                      page: 1,
                                                      pageSize: _rowsPerPage);
                                                  Navigator.of(context)
                                                      .pop(item);
                                                  _isSelectingEmployee = false;
                                                });
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
                                              0.80,
                                      minWidth:
                                          MediaQuery.of(context).size.width *
                                              0.98,
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
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showSearchEmployee = false;
                              selectedEmployeeItem = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ==========================
            // SEARCH DRAWING
            // ==========================
            if (_showSearchDrawing)
              Positioned(
                top: kToolbarHeight + 8,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _isDrawingLoading
                              ? Center(
                                  child: SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : DropdownSearch<ProductModel>(
                                  items: (f, cs) => _productList,
                                  itemAsString: (ProductModel? item) =>
                                      item?.drawingNumber ?? '',
                                  compareFn:
                                      (ProductModel? a, ProductModel? b) =>
                                          a?.drawingNumber == b?.drawingNumber,
                                  onChanged: (ProductModel? selected) async {
                                    if (_isSelectingDrawing ||
                                        selected == null) {
                                      return;
                                    }

                                    _isSelectingDrawing = true;

                                    if (!mounted) return;
                                    setState(() {
                                      selectedDrawingItem = selected;
                                      selectedDrawingNumber =
                                          selected.drawingNumber;
                                      _buttonsEnabled = false;
                                    });

                                    // Segera load data
                                    await loadDataPage(
                                        page: 1, pageSize: _rowsPerPage);

                                    _isSelectingDrawing = false;
                                  },
                                  decoratorProps: const DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: "Pilih Drawing No",
                                      hintText: "Drawing No",
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 5,
                                          top: 10,
                                          bottom: 10,
                                          right: 8),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Cari Drawing No",
                                        hintText: "Drawing No...",
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      keyboardType: TextInputType.text,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                    ),
                                    itemBuilder: (context, ProductModel item,
                                        isDisabled, isSelected) {
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 10.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0)),
                                        elevation: 2,
                                        child: ListTile(
                                          title: Text(
                                            item.drawingNumber,
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14.0,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                          subtitle: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: item.productCategory,
                                                  style: TextStyle(
                                                    color: Colors.purple[
                                                        400], // warna default
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' - ', // tanda pemisah
                                                  style: const TextStyle(
                                                    color: Colors
                                                        .blueGrey, // tetap blueGrey
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: item.productType,
                                                  style: TextStyle(
                                                    color: Colors.blue[
                                                        400], // warna cyan[100]
                                                    fontSize: 14,
                                                    fontWeight: FontWeight
                                                        .normal, // optional
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' - ', // tanda pemisah
                                                  style: const TextStyle(
                                                    color: Colors
                                                        .blueGrey, // tetap blueGrey
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: item.nameCompany,
                                                  style: TextStyle(
                                                    color: Colors.cyan[
                                                        400], // warna cyan[100]
                                                    fontSize: 14,
                                                    fontWeight: FontWeight
                                                        .normal, // optional
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () async {
                                            if (_isSelectingDrawing) return;
                                            _isSelectingDrawing = true;

                                            if (!mounted) return;
                                            setState(() {
                                              selectedDrawingItem = item;
                                              selectedDrawingNumber =
                                                  item.drawingNumber;
                                            });

                                            // Tunggu frame selesai agar state benar-benar update
                                            await Future.delayed(Duration.zero);
                                            if (!mounted) return;
                                            await loadDataPage(
                                                page: 1,
                                                pageSize: _rowsPerPage);
                                            Navigator.of(context).pop(item);
                                            _isSelectingDrawing = false;
                                          },
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
                                              0.80,
                                      minWidth:
                                          MediaQuery.of(context).size.width *
                                              0.98,
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
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showSearchDrawing = false;
                              selectedDrawingItem = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ==========================
            // LOADING OVERLAY
            // ==========================
            if (isLoading)
              const Opacity(
                opacity: 0.3,
                child: ModalBarrier(
                  dismissible: false,
                  color: Colors.black,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: paginatedData != null
          ? Container(
              height: 60, // <--- penting, jangan sampai container otomatis fill
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // PREVIOUS Button
                  TextButton(
                    onPressed: paginatedData!.previous != null
                        ? () => loadDataPage(
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.0),
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
                                      value: 80, child: Text('80')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    loadDataPage(
                                        page: 1,
                                        pageSize: value); // reset ke halaman 1
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
                        ? () => loadDataPage(
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
            )
          : null,

    );

*/
  }
}


/*
      SafeArea(
          child: Stack(children: [
        Column(
          children: [
            // Content utama
            Padding(
              padding: const EdgeInsets.all(0),
              child: Text("Halaman Menu"),
            ),

            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 0.6,
                  child: paginatedData == null || paginatedData!.results.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Text("Testing 1..2..3."),
                )),

            if (_showSearch)
              Positioned(
                top: kToolbarHeight + 8, // posisinya dibawah AppBar
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            keyboardType:
                                TextInputType.number, // keyboard numeric
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // hanya boleh angka
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 107, 102, 102),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search by Jobnumber...',
                              labelText: 'JOBNUMBER',
                              labelStyle: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.lightBlueAccent.shade100,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                8), // ubah sesuai kebutuhan
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedJobNumber = _searchController.text
                                    .trim(); // ambil input user
                                _currentPage = 1; // reset page ke 1
                                _buttonsEnabled = false;
                              });

                              // Panggil load data dengan filter job number
                              loadDataPage(page: 1, pageSize: _rowsPerPage);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .transparent, // biar gradient container kelihatan
                              shadowColor: Colors
                                  .transparent, // hilangkan shadow default
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // sama dengan container
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              'SEARCH',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showSearch = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            //Overlay pencarian berdasarkan nama employee

            if (_showSearchEmployee)
              Positioned(
                top: kToolbarHeight + 8,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _isEmployeeLoading
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownSearch<EmployeeModel>(
                                  items: (f, cs) => _employeeList,
                                  itemAsString: (EmployeeModel? item) =>
                                      item?.fullName ?? '',
                                  compareFn:
                                      (EmployeeModel? a, EmployeeModel? b) =>
                                          a?.idEmployee == b?.idEmployee,
                                  onChanged: (EmployeeModel? selected) async {
                                    if (_isSelectingEmployee ||
                                        selected == null)
                                      return; // cegah double tap

                                    _isSelectingEmployee = true;

                                    if (!mounted) return;
                                    setState(() {
                                      selectedEmployeeItem = selected;
                                      selectedIdEmployeeFinish =
                                          selected.idEmployee;
                                      _buttonsEnabled = false;
                                    });

                                    // Tambahan delay singkat supaya UX lebih smooth
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));

                                    if (mounted) {
                                      loadDataPage(
                                          page: 1,
                                          pageSize:
                                              _rowsPerPage); // langsung load data
                                    }

                                    _isSelectingEmployee = false;
                                  },
                                  decoratorProps: const DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: "Pilih Operator",
                                      hintText: "Nama Operator",
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 5,
                                          top: 10,
                                          bottom: 10,
                                          right: 8),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Cari Operator",
                                        hintText: "Ketik nama Operator...",
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      keyboardType: TextInputType.text,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                    ),
                                    itemBuilder: (context, EmployeeModel item,
                                        isDisabled, isSelected) {
                                      final imageUrl =
                                          '${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png';
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 10.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0)),
                                        elevation: 2,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.grey.shade100,
                                                Colors.grey.shade400
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
                                            child: ListTile(
                                              leading: ClipOval(
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 52,
                                                  height: 52,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const CircleAvatar(
                                                      radius: 21,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(Icons.person,
                                                          color: Colors.grey,
                                                          size: 26),
                                                    );
                                                  },
                                                ),
                                              ),
                                              title: Text(
                                                item.fullName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14.0,
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                              subtitle: Text(
                                                item.nrp,
                                                style: const TextStyle(
                                                    color: Colors.blueGrey),
                                              ),
                                              onTap: () {
                                                if (_isSelectingEmployee) {
                                                  return;
                                                } // cegah double tap
                                                _isSelectingEmployee = true;

                                                if (!mounted) return;
                                                setState(() {
                                                  selectedEmployeeItem = item;
                                                  selectedIdEmployeeFinish =
                                                      item.idEmployee;
                                                });

                                                // delay untuk loadDataPage tanpa menyentuh context
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 200), () {
                                                  if (!mounted) return;
                                                  loadDataPage(
                                                      page: 1,
                                                      pageSize: _rowsPerPage);
                                                  Navigator.of(context)
                                                      .pop(item);
                                                  _isSelectingEmployee = false;
                                                });
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
                                              0.80,
                                      minWidth:
                                          MediaQuery.of(context).size.width *
                                              0.98,
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
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showSearchEmployee = false;
                              selectedEmployeeItem = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            //Pencarian berdasarkan drawing number
            if (_showSearchDrawing)
              Positioned(
                top: kToolbarHeight + 8,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _isDrawingLoading
                              ? Center(
                                  child: SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : DropdownSearch<ProductModel>(
                                  items: (f, cs) => _productList,
                                  itemAsString: (ProductModel? item) =>
                                      item?.drawingNumber ?? '',
                                  compareFn:
                                      (ProductModel? a, ProductModel? b) =>
                                          a?.drawingNumber == b?.drawingNumber,
                                  onChanged: (ProductModel? selected) async {
                                    if (_isSelectingDrawing ||
                                        selected == null) {
                                      return;
                                    }

                                    _isSelectingDrawing = true;

                                    if (!mounted) return;
                                    setState(() {
                                      selectedDrawingItem = selected;
                                      selectedDrawingNumber =
                                          selected.drawingNumber;
                                      _buttonsEnabled = false;
                                    });

                                    // Segera load data
                                    await loadDataPage(
                                        page: 1, pageSize: _rowsPerPage);

                                    _isSelectingDrawing = false;
                                  },
                                  decoratorProps: const DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: "Pilih Drawing No",
                                      hintText: "Drawing No",
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 5,
                                          top: 10,
                                          bottom: 10,
                                          right: 8),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Cari Drawing No",
                                        hintText: "Drawing No...",
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      keyboardType: TextInputType.text,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                    ),
                                    itemBuilder: (context, ProductModel item,
                                        isDisabled, isSelected) {
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 10.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0)),
                                        elevation: 2,
                                        child: ListTile(
                                          title: Text(
                                            item.drawingNumber,
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14.0,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                          subtitle: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: item.productCategory,
                                                  style: TextStyle(
                                                    color: Colors.purple[
                                                        400], // warna default
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' - ', // tanda pemisah
                                                  style: const TextStyle(
                                                    color: Colors
                                                        .blueGrey, // tetap blueGrey
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: item.productType,
                                                  style: TextStyle(
                                                    color: Colors.blue[
                                                        400], // warna cyan[100]
                                                    fontSize: 14,
                                                    fontWeight: FontWeight
                                                        .normal, // optional
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' - ', // tanda pemisah
                                                  style: const TextStyle(
                                                    color: Colors
                                                        .blueGrey, // tetap blueGrey
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: item.nameCompany,
                                                  style: TextStyle(
                                                    color: Colors.cyan[
                                                        400], // warna cyan[100]
                                                    fontSize: 14,
                                                    fontWeight: FontWeight
                                                        .normal, // optional
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () async {
                                            if (_isSelectingDrawing) return;
                                            _isSelectingDrawing = true;

                                            if (!mounted) return;
                                            setState(() {
                                              selectedDrawingItem = item;
                                              selectedDrawingNumber =
                                                  item.drawingNumber;
                                            });

                                            // Tunggu frame selesai agar state benar-benar update
                                            await Future.delayed(Duration.zero);
                                            if (!mounted) return;
                                            await loadDataPage(
                                                page: 1,
                                                pageSize: _rowsPerPage);
                                            Navigator.of(context).pop(item);
                                            _isSelectingDrawing = false;
                                          },
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
                                              0.80,
                                      minWidth:
                                          MediaQuery.of(context).size.width *
                                              0.98,
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
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showSearchDrawing = false;
                              selectedDrawingItem = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            //

            // Loading overlay

            if (isLoading)
              const Opacity(
                opacity: 0.3,
                child: ModalBarrier(dismissible: false, color: Colors.black),
              ),
          ],
        ),
      ]
      
      )
      
      ),
*/
/*
      bottomNavigationBar: paginatedData != null
          ? Container(
              height: 60, // <--- penting, jangan sampai container otomatis fill
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // PREVIOUS Button
                  TextButton(
                    onPressed: paginatedData!.previous != null
                        ? () => loadDataPage(
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.0),
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
                                      value: 80, child: Text('80')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    loadDataPage(
                                        page: 1,
                                        pageSize: value); // reset ke halaman 1
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
                        ? () => loadDataPage(
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
            )
          : null,

*/

/*
    );
  }
}
*/