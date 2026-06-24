import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/batch_summary_model.dart';
import 'package:flutter_provider_data/model/master/product_model.dart';
import 'package:flutter_provider_data/page/001-molding/report/paginated_batch_summary.dart';
import 'package:flutter_provider_data/page/001-molding/report/record_completed.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/page/001-molding/report/batch_summary_detail.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:dropdown_search/dropdown_search.dart';

class BatchSummary extends StatefulWidget {
  final String title;
  final String idProses;

  const BatchSummary({super.key, required this.title, required this.idProses});

  @override
  _BatchSummaryState createState() => _BatchSummaryState();
}

class _BatchSummaryState extends State<BatchSummary> {
  PaginatedBatchSummary? paginatedData;
  late Future<BatchSummaryModel> futureData;

  List<ProductModel> _productList = [];
  ProductModel? selectedDrawingItem;

  bool isLoading = true;
  int _rowsPerPage = 20; // Jumlah row per page
  int _totalRecords = 0; // Total data dari API
  int _currentPage = 1; // Halaman saat ini
  // bool _buttonsEnabled = true;
  int pageIndex = 0; // 0-based index halaman
  int pageSize = 20; // default page size

  String? selectedBatchNumber;
  String? selectedDrawingNumber;
  String? selectedCompanyName;
  String? selectedProductCategory;
  String? selectedProductType;

  DateTimeRange? selectedDateRange;
  String? startDate;
  String? endDate;
  bool _isSelectingDrawing = false;
  bool _isDrawingLoading = false;
  TextEditingController dateRangeController = TextEditingController();
  final TextEditingController _drawingController = TextEditingController();

  String formatMinutesToHours(int totalMinutes) {
    int hours = totalMinutes ~/ 60; // hitung jam
    int minutes = totalMinutes % 60; // sisa menit
    return '$hours:$minutes'; // format: 2h 5m
  }

  @override
  void initState() {
    super.initState();
    _loadDrawingList(); // ambil list saat mulai
    // Tampilkan UI dulu, data di-load setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadNgPage(page: 1, pageSize: _rowsPerPage);
    });
  }

  @override
  void dispose() {
    _drawingController.dispose();
    dateRangeController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      selectedBatchNumber = null;
      selectedDrawingItem = null;
      selectedDrawingNumber = null;
      selectedCompanyName = null;
      selectedProductCategory = null;
      selectedProductType = null;
      selectedDateRange = null;
      startDate = null;
      endDate = null;
      dateRangeController.clear();
    });

    // Load semua data tanpa filter
    loadNgPage(page: 1, pageSize: _rowsPerPage);
  }

  Future<PaginatedBatchSummary> fetchCompletedDataFuture({
    int page = 1,
    int pageSize = 20,
    String? batchNumber,
    String? drawingNumber,
    String? companyName,
    String? productCategory,
    String? productType,
    String? startDate,
    String? endDate,
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (batchNumber != null && batchNumber.isNotEmpty) {
      queryParams['batch_number'] = batchNumber;
    }

    if (drawingNumber != null && drawingNumber.isNotEmpty) {
      queryParams['drawing_number'] = drawingNumber;
    }

    if (companyName != null && companyName.isNotEmpty) {
      queryParams['name_company'] = companyName;
    }

    if (productCategory != null && productCategory.isNotEmpty) {
      queryParams['product_category'] = productCategory;
    }

    if (productType != null && productType.isNotEmpty) {
      queryParams['product_type'] = productType;
    }

// Tambahkan date range
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['end_date'] = endDate;
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/api/batch-summary/')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PaginatedBatchSummary.fromJson(jsonData);
    } else {
      throw Exception('Failed to load Record Summary data');
    }
  }

  Future<void> loadNgPage({required int page, required int pageSize}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await fetchCompletedDataFuture(
        page: page,
        pageSize: pageSize,
        batchNumber: selectedBatchNumber,
        drawingNumber: selectedDrawingNumber,
        companyName: selectedCompanyName,
        productCategory: selectedProductCategory,
        productType: selectedProductType,
        startDate: startDate,
        endDate: endDate,
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
          selectedBatchNumber = jobnumber; // simpan jobnumber ke state
          _currentPage = 1;
          // _buttonsEnabled = false; // disable tombol sementara
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

  void showFullScreenDialog(BuildContext context, BatchSummaryModel r) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          BatchSummaryDetail(batchNumber: r.batchNumber),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ));
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

  @override
  Widget build(BuildContext context) {
    Widget buildShimmerPlaceholder() {
      return ListView.builder(
        itemCount: 10, // jumlah baris shimmer
        itemBuilder: (context, index) {
          return Shimmer(
            duration: const Duration(seconds: 4),
            interval: const Duration(milliseconds: 500),
            color: Colors.grey.shade400,
            colorOpacity: 0.5,
            enabled: isLoading,
            direction: ShimmerDirection.fromLeftToRight(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        },
      );
    }

    Widget buildDataTable() {
      return ConstrainedBox(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: IntrinsicWidth(
          child: Stack(
            children: [
              // Gradient di belakang header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 50, // tinggi header sama dengan headingRowHeight
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1565C0), // biru gelap
                        Color(0xFF42A5F5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // DataTable dengan header transparan
              DataTable(
                headingRowHeight: 50,
                headingRowColor: WidgetStateProperty.all(Colors.transparent),
                columns: const [
                  DataColumn(
                      label: Text('NO',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('JOB CODE',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('TOTAL LOT',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('DRAWING NUMBER',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('CUSTOMER',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('CATEGORY',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('TYPE',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: [
                          Text('TOTAL DOWNTIME',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('(Hour:Min)',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 12.0)),
                        ],
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: [
                          Text('TOTAL CYCLETIME',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('(Hour:Min)',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 12.0)),
                        ],
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: [
                          Text('TOTAL TIME',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('(Hour:Min)',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 12.0)),
                        ],
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: [
                          Text('TOTAL QUANTITY',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('(Pcs)',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 12.0)),
                        ],
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: [
                          Text('TOTAL NG',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('(Pcs)',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 12.0)),
                        ],
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: [
                          Text('TOTAL GOOD',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('(Pcs)',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 12.0)),
                        ],
                      ),
                    ),
                  ),
                ],
                rows: paginatedData!.results.asMap().entries.map((entry) {
                  int index = entry.key;
                  var record = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text(
                          ((_currentPage - 1) * _rowsPerPage + index + 1)
                              .toString())),
                      DataCell(
                        InkWell(
                          onTap: () => showFullScreenDialog(context, record),
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            child: Text(
                              record.batchNumber,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors
                                    .grey.shade900, // terlihat bisa diklik
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(record.totalJobnumber)),
                      DataCell(Text(record.drawingNumber)),
                      DataCell(Text(record.nameCompany)),
                      DataCell(Text(record.productCategory)),
                      DataCell(Text(record.productType)),
                      DataCell(
                        Text(formatMinutesToHours(record.totalPending)),
                      ),
                      DataCell(
                          Text(formatMinutesToHours(record.totalCycleTime))),
                      DataCell(Text(formatMinutesToHours(record.totalTime))),
                      DataCell(Text(record.totalStartQty.toString())),
                      DataCell(Text(record.totalNg.toString())),
                      DataCell(Text(record.totalFinishQty.toString())),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(kToolbarHeight + 48), // AppBar + TabBar
          child: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Text(
              widget.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontFamily: "Montserrat"),
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
                      var tween = Tween<double>(begin: 0.0, end: 1.0)
                          .chain(CurveTween(curve: Curves.easeIn));
                      var opacityAnimation = animation.drive(tween);
                      return FadeTransition(
                          opacity: opacityAnimation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  icon: Icon(Icons.table_chart, size: 18),
                  child: Text(
                    'JOBCODE',
                    style: TextStyle(fontSize: 14), // ukuran teks
                  ),
                ),
                Tab(
                  icon: Icon(Icons.table_chart, size: 18),
                  child: Text(
                    'DRAWING NO',
                    style: TextStyle(fontSize: 14), // ukuran teks
                  ),
                ),
                Tab(
                  icon: Icon(Icons.table_chart, size: 18),
                  child: Text(
                    'PRODUCT TYPE',
                    style: TextStyle(fontSize: 14), // ukuran teks
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // ================= TAB 1 =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buttons di atas
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 6.0),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      final screenWidth = MediaQuery.of(context).size.width;

                      final List<Widget> children = [
                        SizedBox(
                          width: screenWidth *
                              0.18, // lebar tetap agar tombol tidak loncat
                          child: ElevatedButton.icon(
                            onPressed: () {
                              navigateWithSlideRight(
                                context,
                                RecordCompleted(
                                  title: 'MOLD FINISH',
                                  idProses: widget.idProses,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons
                                  .list_outlined, // ganti dengan icon yang diinginkan
                              size: 20,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'MOLD FINISH',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(4), // border radius 5
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        SizedBox(
                            width: screenWidth * 0.25,
                            child: _isDrawingLoading
                                ? Center(
                                    child: SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  )
                                : DropdownSearch<ProductModel>(
                                    items: (f, cs) => _productList,
                                    selectedItem: selectedDrawingItem,
                                    itemAsString: (ProductModel? item) =>
                                        item?.drawingNumber ?? '',
                                    compareFn: (ProductModel? a,
                                            ProductModel? b) =>
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
                                        // _buttonsEnabled = false;
                                      });

                                      await Future.delayed(
                                          const Duration(milliseconds: 300));

                                      _isSelectingDrawing = false;
                                    },
                                    dropdownBuilder:
                                        (context, ProductModel? selectedItem) {
                                      if (selectedItem == null) {
                                        return const SizedBox();
                                      }
                                      return Text(
                                        selectedItem.drawingNumber,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors
                                                .black), // ukuran & warna value
                                      );
                                    },
                                    decoratorProps:
                                        const DropDownDecoratorProps(
                                      decoration: InputDecoration(
                                        labelText: "DRAWING NO",
                                        hintText: "DRAWING NO",
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 5,
                                            top: 10,
                                            bottom: 10,
                                            right: 8),

                                        hintStyle: TextStyle(
                                            fontSize: 14), // untuk placeholder
                                        labelStyle: TextStyle(
                                            fontSize: 14), // untuk label
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
                                      // 🔧 inilah bagian itemBuilder yang sudah cocok dengan versi kamu
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
                                              style: const TextStyle(
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
                                                        color:
                                                            Colors.purple[400],
                                                        fontSize: 14),
                                                  ),
                                                  const TextSpan(
                                                    text: ' - ',
                                                    style: TextStyle(
                                                        color: Colors.blueGrey,
                                                        fontSize: 14),
                                                  ),
                                                  TextSpan(
                                                    text: item.productType,
                                                    style: TextStyle(
                                                        color: Colors.blue[400],
                                                        fontSize: 14),
                                                  ),
                                                  const TextSpan(
                                                    text: ' - ',
                                                    style: TextStyle(
                                                        color: Colors.blueGrey,
                                                        fontSize: 14),
                                                  ),
                                                  TextSpan(
                                                    text: item.companyName,
                                                    style: TextStyle(
                                                        color: Colors.cyan[400],
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              if (_isSelectingDrawing) return;
                                              _isSelectingDrawing = true;

                                              if (!mounted) return;
                                              setState(() {
                                                selectedDrawingItem = item;
                                                selectedDrawingNumber =
                                                    item.drawingNumber;
                                              });
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
                                  )),
                        SizedBox(width: screenWidth * 0.01),
                        SizedBox(
                          width: screenWidth * 0.25,
                          child: TextField(
                            readOnly: true,
                            controller:
                                dateRangeController, // pakai controller tetap
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 107, 102, 102),
                            ),
                            decoration: InputDecoration(
                              labelText: 'RECORD DATE',
                              hintText: "RECORD DATE",
                              labelStyle: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 14),
                              prefixIcon:
                                  const Icon(Icons.calendar_month, size: 20),
                              prefixIconConstraints:
                                  BoxConstraints(minWidth: 35, minHeight: 30),
                            ),
                            onTap: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2023),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                                initialDateRange: selectedDateRange,
                              );

                              if (picked != null) {
                                setState(() {
                                  selectedDateRange = picked;
                                  startDate = picked.start
                                      .toIso8601String()
                                      .split('T')[0];
                                  endDate = picked.end
                                      .toIso8601String()
                                      .split('T')[0];
                                  dateRangeController.text =
                                      "${picked.start.toString().split(' ')[0]} - ${picked.end.toString().split(' ')[0]}";
                                });

                                loadNgPage(page: 1, pageSize: _rowsPerPage);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
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

                      return orientation == Orientation.portrait
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: children),
                            )
                          : Row(children: children);
                    },
                  ),
                ),

                // Expanded content (DataTable)
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: isLoading
                                ? buildShimmerPlaceholder()
                                : paginatedData == null ||
                                        paginatedData!.results.isEmpty
                                    ? const Center(
                                        child: Text('DATA TIDAK ADA'))
                                    : SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: buildDataTable(),
                                        ),
                                      ),
                          ),
                          // BottomNavigation untuk Tab 1
                          if (paginatedData != null)
                            Container(
                              height: 60,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1565C0),
                                    Color(0xFF42A5F5)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: paginatedData!.previous != null
                                        ? () => loadNgPage(
                                            page: _currentPage - 1,
                                            pageSize: _rowsPerPage)
                                        : null,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      disabledForegroundColor:
                                          Colors.grey.shade400,
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
                                                color: Colors.white,
                                                fontSize: 14.0),
                                          ),
                                          const SizedBox(width: 20),
                                          const Text(
                                            'ROW PER PAGE: ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.0),
                                          ),
                                          const SizedBox(width: 5),
                                          SizedBox(
                                            width: 60,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6),
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: DropdownButton<int>(
                                                value: _rowsPerPage,
                                                isExpanded: true,
                                                underline: const SizedBox(),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                items: const [
                                                  DropdownMenuItem(
                                                      value: 20,
                                                      child: Text('20')),
                                                  DropdownMenuItem(
                                                      value: 40,
                                                      child: Text('40')),
                                                  DropdownMenuItem(
                                                      value: 80,
                                                      child: Text('80')),
                                                ],
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    loadNgPage(
                                                        page: 1,
                                                        pageSize: value);
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 40),
                                          Text(
                                            'PAGE $_currentPage OF ${(_totalRecords / _rowsPerPage).ceil()}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: paginatedData!.next != null
                                        ? () => loadNgPage(
                                            page: _currentPage + 1,
                                            pageSize: _rowsPerPage)
                                        : null,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      disabledForegroundColor:
                                          Colors.grey.shade400,
                                    ),
                                    child: const Text('NEXT'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (isLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withAlpha(77),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // ================= TAB 2 =================
            Column(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      "Detail Data atau Grafik bisa ditampilkan di sini",
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                    ),
                  ),
                ),
                // BottomNavigation untuk Tab 2 (contoh sama)
                if (paginatedData != null)
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: paginatedData!.previous != null
                              ? () => loadNgPage(
                                  page: _currentPage - 1,
                                  pageSize: _rowsPerPage)
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButton<int>(
                                      value: _rowsPerPage,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      style:
                                          const TextStyle(color: Colors.black),
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
                                          loadNgPage(page: 1, pageSize: value);
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
                              ? () => loadNgPage(
                                  page: _currentPage + 1,
                                  pageSize: _rowsPerPage)
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
              ],
            ),

            // ================= TAB 3 =================
            Column(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      "Detail Data atau Grafik bisa ditampilkan di sini",
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                    ),
                  ),
                ),
                // BottomNavigation untuk Tab 2 (contoh sama)
                if (paginatedData != null)
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: paginatedData!.previous != null
                              ? () => loadNgPage(
                                  page: _currentPage - 1,
                                  pageSize: _rowsPerPage)
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButton<int>(
                                      value: _rowsPerPage,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      style:
                                          const TextStyle(color: Colors.black),
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
                                          loadNgPage(page: 1, pageSize: value);
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
                              ? () => loadNgPage(
                                  page: _currentPage + 1,
                                  pageSize: _rowsPerPage)
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
