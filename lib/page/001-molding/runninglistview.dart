import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:flutter_provider_data/page/001-molding/reason_dialog/reason_dialog.dart';
import 'package:flutter_provider_data/page/001-molding/recordprocess.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:provider/provider.dart';

class RunningListView extends StatefulWidget {
  final String title;
  final String idProses;

  const RunningListView({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  _RunningListViewState createState() => _RunningListViewState();
}

class _RunningListViewState extends State<RunningListView> {
  late Future<List<RecordRunningModel>> records;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<RunningProvider>();
      prov.loadRunningRecords(widget.idProses);
    });
  }

  Future<void> scanAndFilterJobNumber() async {
    // ✅ Simpan reference sebelum await
    final overlay = Overlay.of(context, rootOverlay: true);
    final prov = context.read<RunningProvider>();

    try {
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      if (!RegExp(r'^[a-zA-Z0-9]{9}[0-9]{10}[0-9]{5}$').hasMatch(getcode)) {
        CustomSnackbar.showWithOverlay(
          overlay,
          "Invalid QR Code format.",
          isSuccess: false,
        );
        return;
      }

      String joblot = getcode.substring(9, 19).trim();
      prov.setFilterSearch(
        jobNumber: joblot,
        employee: prov.scannedFilterEmployee,
      );
    } catch (e) {
      CustomSnackbar.showWithOverlay(
        overlay,
        "Error scanning: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> scanAndFilterEmployeeFinish() async {
    // ✅ Simpan reference sebelum await
    final overlay = Overlay.of(context, rootOverlay: true);
    final prov = context.read<RunningProvider>();

    try {
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      if (getcode.length != 8) {
        CustomSnackbar.showWithOverlay(
          overlay,
          "Yang discan bukan ID Employee",
          isSuccess: false,
        );
        return;
      }

      prov.setFilterSearch(
        jobNumber: prov.scannedFilterJobNumber,
        employee: getcode,
      );
    } catch (e) {
      CustomSnackbar.showWithOverlay(
        overlay,
        "Error scanning employee: $e",
        isSuccess: false,
      );
    }
  }

  /*FUNCTION UNTUK MEMBUKA DIALOG UNTUK PROSES STOP DENGAN MENGISI REASON */

  Future<void> _openStopDialog(String idRecord) async {
    final prov = context.read<RunningProvider>();

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Dialog.fullscreen(
            backgroundColor: Colors.transparent,
            child: FadeTransition(
              opacity: animation,
              child: ReasonSelectDialog(
                idRecord: idRecord,
                onSuccess: () async {
                  // ✅ Satu-satunya tempat refresh
                  await prov.refresh(widget.idProses);
                },
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );

    // ✅ Tidak perlu handle result lagi
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;

    final prov = context.watch<RunningProvider>();

    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    if (prov.hasError) {
      return Center(child: Text('Error: ${prov.errorMessage}'));
    }

    return Scaffold(
        body: Column(children: [
      Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
            padding: const EdgeInsets.only(bottom: 5.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                children: [
                  SizedBox(
                    width: widthApp * 0.20,
                    child: Consumer<RunningProvider>(
                      builder: (context, prov, child) {
                        return OutlinedButton(
                          onPressed: prov.isSearchDisabled
                              ? null
                              : scanAndFilterJobNumber,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10), // dikurangin dari 12
                            side: BorderSide(
                              color: prov.isSearchDisabled
                                  ? Colors.grey.shade400
                                  : Colors.blue.shade400,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_sharp,
                                size: 18, // dikecilin dikit
                                color: prov.isSearchDisabled
                                    ? Colors.grey.shade400
                                    : Colors.blue.shade400,
                              ),
                              const SizedBox(width: 4), // dikurangin dari 6
                              Flexible(
                                child: Text(
                                  'JOBNUMBERS',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12, // dikurangin dari 14
                                    fontWeight: FontWeight.w500,
                                    color: prov.isSearchDisabled
                                        ? Colors.grey.shade400
                                        : Colors.blue.shade400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: widthApp * 0.01),
                  SizedBox(
                    width: widthApp * 0.20,
                    child: OutlinedButton(
                      onPressed: prov.isSearchDisabled
                          ? null
                          : scanAndFilterEmployeeFinish,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10), // dikurangin dari 12
                        side: BorderSide(
                          color: prov.isSearchDisabled
                              ? Colors.grey.shade400
                              : Colors.blue.shade400,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 18, // dikecilin dikit
                            color: prov.isSearchDisabled
                                ? Colors.grey.shade400
                                : Colors.blue.shade400,
                          ),
                          const SizedBox(width: 4), // dikurangin dari 8
                          Flexible(
                            child: Text(
                              'OPERATORS',
                              style: GoogleFonts.poppins(
                                fontSize: 12, // dikurangin dari 14
                                fontWeight: FontWeight.w500,
                                color: prov.isSearchDisabled
                                    ? Colors.grey.shade400
                                    : Colors.blue.shade400,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: widthApp * 0.01),
                  if (prov.isFilterSearchActive)
                    SizedBox(
                      width: 52, // menjaga layout tetap stabil
                      child: InkWell(
                        onTap: () {
                          prov.clearFilterSearch();
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.redAccent,
                                Colors.red.shade600,
                                Colors.red.shade900,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 5,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.clear,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  SizedBox(width: widthApp * 0.02),
                  RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                      children: [
                        TextSpan(
                          text: 'TOTAL ',
                          style: GoogleFonts.poppins(
                            color: Colors.blueGrey.shade400,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        WidgetSpan(
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade800
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(Rect.fromLTWH(
                                0, 0, bounds.width, bounds.height)),
                            child: Text(
                              '${prov.filteredRecords.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' MOLD RUNNING ',
                          style: GoogleFonts.poppins(
                            color: Colors.blueGrey.shade400,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
      Expanded(
        child: Consumer<RunningProvider>(
          builder: (context, prov, child) {
            if (prov.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (prov.hasError) {
              return Center(child: Text('Error: ${prov.errorMessage}'));
            }

            final filteredList = prov.filteredRecords;

            if (filteredList.isEmpty) {
              return Center(
                child: Text(
                  'SAAT INI TIDAK ADA RUNNING MOLDING.',
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final record = filteredList[index];

                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.black.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- bagian gradient header (idRecord, company, kode, etc) ---
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.blue.shade900],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                record.idRecord,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              Text(
                                record.detailsRecord.isNotEmpty
                                    ? record.detailsRecord[0].bcode.companyName
                                    : '',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              Text(
                                record.detailsRecord.isNotEmpty
                                    ? record.detailsRecord[0].bcode.bcode
                                    : '',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              Flexible(
                                child: Text(
                                  record.detailsRecord.isNotEmpty
                                      ? record.detailsRecord[0].bcode
                                          .productCategory
                                      : '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              Text(
                                record.detailsRecord.isNotEmpty
                                    ? record.detailsRecord[0].bcode.productType
                                    : '',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        Container(
                          // Area abu-abu muda di gambar.
                          decoration: BoxDecoration(
                            color: Colors
                                .grey.shade50, // Warna abu-abu muda/off-white
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // FOTO OPERATOR dan Keterangan
                              SizedBox(
                                width: widthApp *
                                    0.20, // Sesuaikan lebar agar proporsional
                                child: Column(
                                  children: [
                                    // Lingkaran Foto
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Aura / glow di belakang
                                        Container(
                                          width: widthApp *
                                              0.18, // sedikit lebih besar dari foto
                                          height: widthApp * 0.18,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.grey.withValues(
                                                    alpha:
                                                        0.4), // pusat lebih tegas
                                                Colors.white.withValues(
                                                    alpha: 0.1), // tepi lembut
                                              ],
                                              stops: const [0.5, 1.0],
                                              center: Alignment.center,
                                              radius: 0.8,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withValues(alpha: 0.5),
                                                spreadRadius: 4,
                                                blurRadius: 14,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Border dan foto
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              // Soft outer glow
                                              BoxShadow(
                                                color: Colors.blueAccent
                                                    .withValues(alpha: 30),
                                                blurRadius: 12, // Glow lembut
                                                spreadRadius: 2, // Aura tipis
                                              ),
                                              // White soft inner glow
                                              BoxShadow(
                                                color: Colors.white
                                                    .withValues(alpha: 25),
                                                blurRadius: 18,
                                                spreadRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: Image.network(
                                              "${AppConfig.baseUrl}/media/img/employee/${record.activeEmployee?.idEmployee}.png",
                                              width: widthApp * 0.16,
                                              height: widthApp * 0.16,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.person_pin,
                                                size: 70,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                    const SizedBox(height: 8.0),
                                    // Detail Operator
                                    Text(
                                      record.activeEmployee?.fullName ??
                                          'Name Operator Finish tidak ditemukan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 4),
                                    Text(
                                      record.activeEmployee?.nrp ??
                                          'NRP Operator finish tidak di temukan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    Text(
                                      record.activeEmployee?.section
                                              .toUpperCase() ??
                                          'SECTION OPERATOR FINISH TIDAK DITEMUKAN',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      record.activeEmployee?.division
                                              .toUpperCase() ??
                                          'DIVISION OPERATOR FINISH TIDAK DITEMUKAN',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),

                              // TABLE + BUTTONS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // TABLE INFORMASI dengan warna selang-seling
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(4),
                                          1: FlexColumnWidth(6),
                                        },
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        children: [
                                          for (int i = 0; i < 7; i++)
                                            TableRow(
                                              decoration: BoxDecoration(
                                                color: i.isEven
                                                    ? Colors.grey.shade200
                                                    : Colors.white,
                                              ),
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Text(
                                                      [
                                                        'JOB NUMBER',
                                                        'DRAW NO',
                                                        'MACHINE',
                                                        'QTY',
                                                        'SHOOT QTY',
                                                        'START TIME',
                                                        'STATUS'
                                                      ][i],
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight: i == 0
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        fontSize: 15,
                                                      )),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Text(
                                                    [
                                                      ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].jobNumber : ''}",
                                                      ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].bcode.drawingNumber : ''}",
                                                      ": ${record.activeMachine?.nmMc ?? ''}",
                                                      ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].startQty.toString() : ''}",
                                                      ": ${record.detailsRecord.isNotEmpty ? record.detailsRecord[0].shootQty.toString() : ''}",
                                                      ": ${formatDateTime(record.startTime.toString())}",
                                                      ": ${record.runStatus.toUpperCase()}",
                                                    ][i],
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    // BUTTONS STOP & FINISH dengan gradient

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 70,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.redAccent,
                                                    Colors.red
                                                        .shade600, // ✅ tambah tengah
                                                    Colors.red.shade900,
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red.shade200
                                                        .withValues(alpha: 0.5),
                                                    offset: const Offset(2, 3),
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                  )
                                                ],
                                              ),
                                              child: OutlinedButton.icon(
                                                icon: const Icon(
                                                  FontAwesomeIcons.hand,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                                label: Text(
                                                  "STOP",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight
                                                        .w600, // optional, bisa ditambah jika mau tebal
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    _openStopDialog(
                                                        record.idRecord),
                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  side: BorderSide.none,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              height: 70,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blueAccent,
                                                    Colors.blue.shade600,
                                                    Colors.blue.shade900
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue.shade200
                                                        .withValues(alpha: 0.5),
                                                    offset: const Offset(2, 3),
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                  )
                                                ],
                                              ),
                                              child: OutlinedButton.icon(
                                                icon: const Icon(
                                                  FontAwesomeIcons
                                                      .flagCheckered,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                                label: Text(
                                                  "FINISH",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight
                                                        .w600, // optional, bisa ditambah jika mau tebal
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pushReplacement(
                                                    PageRouteBuilder(
                                                      pageBuilder: (_, __,
                                                              ___) =>
                                                          RecordProcess(
                                                              title: "Molding",
                                                              idProses: record
                                                                  .idProses),
                                                      transitionsBuilder:
                                                          (_, a, sa, child) =>
                                                              FadeTransition(
                                                                  opacity: a,
                                                                  child: child),
                                                      transitionDuration:
                                                          Duration(
                                                              milliseconds:
                                                                  1200),
                                                    ),
                                                  );
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  side: BorderSide.none,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 2.0),

                        // Garis di bagian paling bawah
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                              color: Colors
                                  .grey.shade100, // Warna abu-abu sangat muda
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ]));
  }
}
