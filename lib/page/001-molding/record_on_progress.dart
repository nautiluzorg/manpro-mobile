import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/master/product_model.dart';
import 'package:flutter_provider_data/page/001-molding/paginated_record_progress.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

class RecordOnProgress extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordOnProgress(
      {super.key, required this.title, required this.idProses});

  @override
  _RecordOnProgressState createState() => _RecordOnProgressState();
}

class _RecordOnProgressState extends State<RecordOnProgress> {
  PaginatedRecordProgress? paginatedData;
  final List<EmployeeModel> _employeeList = [];
  final List<ProductModel> _productList = [];
  EmployeeModel? selectedEmployeeItem;
  ProductModel? selectedDrawingItem;
  final bool _isEmployeeLoading = false;
  final bool _isDrawingLoading = false;
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

  // bool _buttonsEnabled = true;
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

  Future<PaginatedRecordProgress> fetchCompletedDataFuture({
    int page = 1,
    int pageSize = 20,
    String? jobNumber,
    String? idEmployeeFinish,
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

    final uri = Uri.parse('${AppConfig.baseUrl}/api/onprogress-records/')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PaginatedRecordProgress.fromJson(jsonData);
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
          // _buttonsEnabled = false; // disable tombol sementara
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
        // _buttonsEnabled = false; // disable tombol sementara
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content utama
          Column(children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                width:
                    double.infinity, // 👈 WAJIB: biar container selebar layar
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
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
                      // === Tombol JOBNUMBER ===
                      SizedBox(width: screenWidth * 0.01),
                      SizedBox(
                        width: screenWidth * 0.20,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: const StadiumBorder(),
                            side: BorderSide.none,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade200,
                                  Colors.blue.shade600,
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.search_sharp, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'JOB NUMBER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.01),

                      // === Tombol OPERATOR ===
                      SizedBox(
                        width: screenWidth * 0.20,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: const StadiumBorder(),
                            side: BorderSide.none,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade200,
                                  Colors.blue.shade600,
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.person_search,
                                      color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'OPERATOR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.1),

                      Text(
                        'TOTAL ON PROCESS:$_totalRecords',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ];

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.start, // 👈 ini penting
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children,
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
                child: paginatedData == null || paginatedData!.results.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : HorizontalDataTable(
                        leftHandSideColumnWidth: 180, // kolom NO + JOBNUMBER
                        rightHandSideColumnWidth: 1470, // total kolom kanan
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
                            width: 150,
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('STATUS',
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
                            width: 180,
                            height: 50,
                            alignment: Alignment.centerLeft,
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
                            width: 140,
                            height: 50,
                            alignment: Alignment.centerLeft,
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
                                Text('START TIME',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                          ),

                          Container(
                            width: 190,
                            height: 50,
                            alignment: Alignment.centerLeft,
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
                            width: 140,
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
                            child: const Text('JOBCODE',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),

                          Container(
                            width: 80,
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
                            width: 150,
                            height: 50,
                            alignment: Alignment.centerLeft,
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
                            width: 100,
                            height: 50,
                            alignment: Alignment.centerLeft,
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
                                Container(
                                  width: 120,
                                  alignment: Alignment.center,
                                  child: Text(
                                    record.jobNumber,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
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
                                width: 150,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors
                                      .transparent, // biar container utama transparan
                                ),
                                child: Container(
                                  width:
                                      130, // dikurangi sedikit dari 150 agar ada jarak
                                  height:
                                      40, // dikurangi dari 50 agar ada jarak
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: record.runStatus.toLowerCase() ==
                                            "running"
                                        ? Colors.green
                                        : record.runStatus.toLowerCase() ==
                                                "pending"
                                            ? Colors.red
                                            : Colors.grey,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    record.runStatus.toLowerCase() == "running"
                                        ? "RUNNING"
                                        : record.runStatus.toLowerCase() ==
                                                "pending"
                                            ? "STOP"
                                            : record.runStatus.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 220,
                                height: 48,
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
                              Container(
                                  width: 180,
                                  height: 48,
                                  alignment: Alignment.centerLeft,
                                  child: Text(record.machineName,
                                      style: TextStyle(
                                          color: Colors.lightBlue.shade900))),
                              Container(
                                  width: 140,
                                  height: 48,
                                  alignment: Alignment.centerLeft,
                                  child: Text(formatDateTime(
                                      record.startTime.toString()))),
                              Container(
                                width: 190,
                                height: 48,
                                alignment: Alignment.centerLeft,
                                child: Text(record.drawingNumber,
                                    style: TextStyle(
                                        color: Colors.blueGrey.shade600)),
                              ),
                              Container(
                                width: 140,
                                height: 48,
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(record.jobCode,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.blueGrey.shade600)),
                              ),
                              Container(
                                  width: 80,
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Text(record.lotNumber.toString())),
                              Container(
                                  width: 150,
                                  height: 48,
                                  alignment: Alignment.centerLeft,
                                  child:
                                      Text(record.productCategory.toString())),
                              Container(
                                  width: 120,
                                  height: 48,
                                  alignment: Alignment.centerLeft,
                                  child: Text(record.productType.toString())),
                              Container(
                                  width: 100,
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Text(record.startQty.toString())),
                            ]),
                          );
                        },

                        itemCount: paginatedData?.results.length ?? 0,
                        rowSeparatorWidget:
                            const Divider(color: Colors.grey, height: 1),
                      )),
          ]),

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
                          borderRadius:
                              BorderRadius.circular(8), // ubah sesuai kebutuhan
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedJobNumber = _searchController.text
                                  .trim(); // ambil input user
                              _currentPage = 1; // reset page ke 1
                              // _buttonsEnabled = false;
                            });

                            // Panggil load data dengan filter job number
                            loadDataPage(page: 1, pageSize: _rowsPerPage);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .transparent, // biar gradient container kelihatan
                            shadowColor:
                                Colors.transparent, // hilangkan shadow default
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
                                  if (_isSelectingEmployee || selected == null)
                                    return; // cegah double tap

                                  _isSelectingEmployee = true;

                                  if (!mounted) return;
                                  setState(() {
                                    selectedEmployeeItem = selected;
                                    selectedIdEmployeeFinish =
                                        selected.idEmployee;
                                    // _buttonsEnabled = false;
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
                                    // _buttonsEnabled = false;
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

          //

          // Loading overlay

          if (isLoading)
            const Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          // if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
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
  }
}
