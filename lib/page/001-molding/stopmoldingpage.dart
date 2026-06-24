import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/stop_grid_view/stop_grid_view.dart';
import 'package:flutter_provider_data/page/001-molding/stoplistview.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

enum MonitoringView { listViewGrid, tableViewGrid }

class StopMoldingPage extends StatefulWidget {
  final String title;
  final String idProses;
  const StopMoldingPage(
      {super.key, required this.title, required this.idProses});

  @override
  State<StopMoldingPage> createState() => _StopMoldingPageState();
}

class _StopMoldingPageState extends State<StopMoldingPage> {
  // State untuk melacak tampilan mana yang sedang aktif
  MonitoringView _currentView = MonitoringView.listViewGrid;

  @override
  Widget build(BuildContext context) {
    final myAppBar = customSubAppBar(
      context: context,
      title: widget.title,
      kode: widget.idProses,
      proses: "MOLDING",
      navigateToBuilder: (kode, proses) => Menu(kode: kode, proses: proses),
    );

    return Scaffold(
      appBar: myAppBar,
      body: Column(
        children: [
          // --- BAGIAN 1: CUSTOM SEGMENTED CONTROL / MENU BUTTONS ---
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              child: Container(
                color: Colors.grey.shade100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Row(
                  children: [
                    // BAGIAN KIRI: Tombol
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTabButton(
                          title: "LIST",
                          view: MonitoringView.listViewGrid,
                          icon: Icons.list_alt,
                        ),
                        _buildTabButton(
                          title: "GRID",
                          view: MonitoringView.tableViewGrid,
                          icon: Icons.grid_view,
                        ),
                      ],
                    ),

                    const SizedBox(width: 10), // jarak tombol dan teks

                    // BAGIAN KANAN: AnimatedTextKit
                    Expanded(
                        // <-- penting! biar teks memanfaatkan semua sisa ruang
                        child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          '🚀 Pilih Jobnumber & scan ID Card anda',
                          textStyle: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800, // lebih kontras
                          ),
                          speed: const Duration(milliseconds: 80),
                        ),
                        FadeAnimatedText(
                          '📢 Pastikan menggunakan APD lengkap',
                          textStyle: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent.shade400
                                .withValues(alpha: 0.5), // lebih “pop” di grey
                          ),
                        ),
                        ColorizeAnimatedText(
                          '💡 Pastikan selalu focus dan hati-hati!...',
                          textStyle: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          colors: [
                            Colors.blue.shade700,
                            Colors.cyan.shade400,
                            Colors.lightGreenAccent.shade400,
                            Colors.orangeAccent.shade700,
                          ],
                        ),
                      ],
                      repeatForever: true,
                      pause: const Duration(milliseconds: 800),
                      displayFullTextOnTap: true,
                      stopPauseOnTap: true,
                    )),
                  ],
                ),
              )),

          const Divider(height: 1, thickness: 1), // Garis pemisah

          // --- BAGIAN 2: BODY KONTEN (MENGGUNAKAN EXPANDED) ---
          Expanded(
            child: IndexedStack(
              index: _currentView.index,
              children: [
                // 0. Tampilan Grid Mesin
                ListViewMoldStop(
                    title: widget.title,
                    idProses: widget.idProses), // Widget Grid yang kamu buat

                // 1. Tampilan List Job Number
                GridViewMoldStop(
                    title: widget.title,
                    idProses:
                        widget.idProses), // ASUMSI: Widget List Job Number-mu
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk Tombol Tab
  Widget _buildTabButton({
    required String title,
    required MonitoringView view,
    required IconData icon,
  }) {
    final bool isSelected = _currentView == view;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 120,
          maxWidth: 120,
          minHeight: 50,
          maxHeight: 50,
        ),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _currentView = view;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.green.shade300.withValues(alpha: 0.95),
                        Colors.lightGreen.shade500.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.blue.shade100.withValues(alpha: 0.3),
                      ],
                    ),
              boxShadow: isSelected
                  ? [
                      // Efek tombol masuk (pressed)
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        offset: const Offset(-2, -2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      // Efek tombol biasa
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.25),
                        offset: const Offset(2, 2),
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ],
              border: Border.all(
                color:
                    isSelected ? Colors.green.shade900 : Colors.green.shade700,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      color: isSelected ? Colors.white : Colors.green.shade800),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ASUMSI: Wrapper untuk GridView agar bisa menjadi children dari IndexedStack
class ListViewMoldStop extends StatelessWidget {
  final String title;
  final String idProses;

  const ListViewMoldStop(
      {super.key, required this.title, required this.idProses});

  @override
  Widget build(BuildContext context) {
    // Memanggil MachineMonitoringGrid, tapi tanpa Scaffold/AppBar agar pas di body
    return StopListView(title: title, idProses: idProses);
  }
}

// ASUMSI: Widget list data job number milikmu
class GridViewMoldStop extends StatelessWidget {
  final String title;
  final String idProses;
  const GridViewMoldStop(
      {super.key, required this.title, required this.idProses});

  @override
  Widget build(BuildContext context) {
    return StopGridView(title: title, idProses: idProses);
    // return RunningGridView(title: title, idProses: idProses);
  }
}
