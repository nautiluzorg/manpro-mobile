import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/page/001-molding/show_running_dialog.dart';

class StopListView extends StatefulWidget {
  final String title;
  final String idProses;

  const StopListView({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  _StopListViewState createState() => _StopListViewState();
}

class _StopListViewState extends State<StopListView> {
  @override
  void initState() {
    super.initState();
    // Fetch data dari provider setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<PendingProvider>();
      prov.fetchPending(widget.idProses);
    });
  }

  Future<void> scanJobNumber() async {
    try {
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );

      if (!mounted || getcode == null || getcode.isEmpty || getcode == "-1")
        return;

      if (!RegExp(r'^[a-zA-Z0-9]{9}[0-9]{10}[0-9]{5}$').hasMatch(getcode)) {
        CustomSnackbar.show(context, "Invalid QR Code format.",
            isSuccess: false);
        return;
      }

      String joblot = getcode.substring(9, 19).trim();

      // Update provider
      final prov = context.read<PendingProvider>();
      prov.scannedJobNumber = joblot;
      // prov.applyFilter(); // provider yang mengurus notifyListeners
    } catch (e) {
      CustomSnackbar.show(context, "Error scanning: $e", isSuccess: false);
    }
  }

  Future<void> scanEmployee() async {
    try {
      final prov = Provider.of<PendingProvider>(context, listen: false);

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
        ),
      );

      if (!mounted || getcode == null || getcode.isEmpty || getcode == "-1") {
        return;
      }

      if (getcode.length != 8) {
        CustomSnackbar.show(
          context,
          "Yang discan bukan ID Employee",
          isSuccess: false,
        );
        return;
      }

      setState(() {
        prov.scannedEmployeeFinishId = getcode;
        // prov.applyFilter();  // bisa diaktifkan jika ingin filter langsung
      });
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Error scanning operator: $e",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    final prov = context.watch<PendingProvider>();

    return Scaffold(
      body: Column(
        children: [
          // --- TOP MENU (UI Muncul Selalu) ---

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Container(
              padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    // JOBNUMBER BUTTON
                    SizedBox(
                      width: widthApp * 0.20,
                      child: OutlinedButton(
                        onPressed: prov.isFilterActive
                            ? null
                            : () async {
                                await scanJobNumber();
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          side: BorderSide(
                            color: prov.isFilterActive
                                ? Colors.grey.shade400
                                : Colors.green.shade400,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_sharp,
                                color: prov.isFilterActive
                                    ? Colors.grey.shade400
                                    : Colors.green.shade400),
                            const SizedBox(width: 8),
                            Text(
                              'JOBNUMBERX',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: prov.isFilterActive
                                    ? Colors.grey.shade400
                                    : Colors.green.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: widthApp * 0.01),

                    // OPERATOR BUTTON
                    SizedBox(
                      width: widthApp * 0.20,
                      child: OutlinedButton(
                        onPressed: prov.isFilterActive
                            ? null
                            : () async {
                                await scanEmployee();
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          side: BorderSide(
                            color: prov.isFilterActive
                                ? Colors.grey.shade400
                                : Colors.green.shade400,
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
                              color: prov.isFilterActive
                                  ? Colors.grey.shade400
                                  : Colors.green.shade400,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'OPERATOR',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: prov.isFilterActive
                                    ? Colors.grey.shade400
                                    : Colors.green.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: widthApp * 0.01),

                    // CLEAR BUTTON (Circle gradient)
                    if (prov.isFilterActive)
                      SizedBox(
                        width: 52,
                        child: InkWell(
                          onTap: () {
                            prov.clearFilter();
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.redAccent, Colors.red.shade900],
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
                              child: Icon(Icons.clear,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),

                    const Spacer(),

                    SizedBox(width: widthApp * 0.02),

                    // TOTAL DATA TEXT
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
                                  Colors.red.shade400,
                                  Colors.red.shade800
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(Rect.fromLTWH(
                                  0, 0, bounds.width, bounds.height)),
                              child: Text(
                                '${prov.filteredPending.length}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: ' MOLD STOP',
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
              ),
            ),
          ),

          // --- BODY LIST / DATA ---
          Expanded(
            child: Builder(
              builder: (context) {
                if (prov.isLoading) {
                  // Loading indikator di area list saja
                  return const Center(child: CircularProgressIndicator());
                }

                if (prov.hasError) {
                  return Center(child: Text('Error: ${prov.errorMessage}'));
                }

                if (prov.filteredPending.isEmpty) {
                  return Center(
                    child: Text(
                      'MOLDING STOP TIDAK ADA.',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }

                // Jika data ada
                return ListView.builder(
                  itemCount: prov.filteredPending.length,
                  itemBuilder: (context, index) {
                    final pending = prov.filteredPending[index];
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
                            // HEADER GRADIENT
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent,
                                    Colors.blue.shade900
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    pending.idRecord,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    pending.customer,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    pending.productCategory,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Flexible(
                                    child: Text(
                                      pending.productType,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // AREA OPERATOR & TABLE (tetap seperti kode original)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // FOTO OPERATOR + INFO
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    child: Column(
                                      children: [
                                        // Lingkaran foto dengan glow
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.18,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.18,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: [
                                                    Colors.green.shade100
                                                        .withValues(alpha: 0.3),
                                                    Colors.white
                                                        .withValues(alpha: 0.1),
                                                  ],
                                                  stops: const [0.5, 1.0],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.green.shade300
                                                        .withValues(alpha: 0.4),
                                                    spreadRadius: 4,
                                                    blurRadius: 14,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: ClipOval(
                                                child: Image.network(
                                                  "${AppConfig.baseUrl}/media/img/employee/${pending.idEmployee}.png",
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.16,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.16,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(Icons.person,
                                                          size: 70,
                                                          color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          pending.employeeName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          pending.nrp,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          pending.section.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          pending.division,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // TABLE INFORMASI + BUTTON CONTINUE
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Table(
                                          columnWidths: const {
                                            0: FlexColumnWidth(4),
                                            1: FlexColumnWidth(6),
                                          },
                                          defaultVerticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          children: [
                                            for (int i = 0;
                                                i < 7;
                                                i++) // sekarang cuma 6 baris
                                              TableRow(
                                                decoration: BoxDecoration(
                                                  color: i.isEven
                                                      ? Colors.grey.shade200
                                                      : Colors.white,
                                                ),
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Text(
                                                      [
                                                        'JOB NUMBER',
                                                        'DRAW NO',
                                                        'MACHINE',
                                                        'QTY SHOOT',
                                                        'REASON STOP', // sekarang di atas TIME STOP
                                                        'TIME STOP',
                                                        'STOP DURATION', // tetap di bawah TIME STOP
                                                      ][i],
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight: i == 0
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Text(
                                                      [
                                                        ": ${pending.jobnumber}",
                                                        ": ${pending.drawingNumber}",
                                                        ": ${pending.machineName}",
                                                        ": ${pending.qty}",
                                                        ": ${pending.reason}",
                                                        ": ${formatDateTime(pending.startPending)}",
                                                        ": ${getStopDuration(pending.startPending)}",
                                                      ][i],
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight: i == 0
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        color: i == 4
                                                            ? Colors.red
                                                            : Colors
                                                                .black, // warna merah untuk REASON STOP
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),
                                        // BUTTON CONTINUE

                                        Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.greenAccent,
                                                Colors.green.shade900
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // ✅ Simpan semua reference sebelum await
                                              final pendingProvider = context
                                                  .read<PendingProvider>();
                                              final overlay = Overlay.of(
                                                  context,
                                                  rootOverlay: true);

                                              try {
                                                // ← Hanya ini yang berubah (tambah widget.title)
                                                final result =
                                                    await showRunningDialog(
                                                  context,
                                                  pending.idPending.toString(),
                                                  pending.idReason.toString(),
                                                  widget.idProses,
                                                  pending.productType,
                                                );

                                                // ← Semua ini tetap sama, tidak dihapus
                                                if (!mounted) return;

                                                if (result == true) {
                                                  pendingProvider.fetchPending(
                                                      widget.idProses);
                                                }
                                              } catch (e) {
                                                if (!mounted) return;
                                                CustomSnackbar.showWithOverlay(
                                                  overlay,
                                                  "Terjadi kesalahan: $e",
                                                  isSuccess: false,
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              "CONTINUES",
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
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
                            const SizedBox(height: 8),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ); // Gunakan function yang sudah ada
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
