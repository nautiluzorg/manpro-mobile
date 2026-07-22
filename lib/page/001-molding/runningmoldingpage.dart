import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/running_grid_view/runninggridview.dart';
import 'package:flutter_provider_data/page/001-molding/running_list_view/running_list_view.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

enum MonitoringView { listViewGrid, tableViewGrid }

class RunningMoldingPage extends StatefulWidget {
  final String title;
  final String idProses;
  const RunningMoldingPage(
      {super.key, required this.title, required this.idProses});

  @override
  State<RunningMoldingPage> createState() => _RunningMoldingPageState();
}

class _RunningMoldingPageState extends State<RunningMoldingPage> {
  // State untuk melacak tampilan mana yang sedang aktif
  MonitoringView _currentView = MonitoringView.listViewGrid;

  // Helper untuk menghitung fontSize responsif berdasarkan lebar area teks.
  // Base: di lebar ~800px fontSize = 22. Di-clamp biar gak kekecilan/kegedean.
  double _responsiveFontSize(double width) {
    double size = width * 0.0275;
    return size.clamp(14.0, 22.0);
  }

  @override
  Widget build(BuildContext context) {
    final myAppBar = customSubAppBar(
      context: context,
      title: widget.title,
      kode: widget.idProses,
      proses: "MOULDING",
      navigateToBuilder: (kode, proses) => Menu(kode: kode, proses: proses),
    );

    return Scaffold(
      appBar: myAppBar,
      body: Column(
        children: [
          //##### BAGIAN BUTTON LIST & GRID #####//

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

                    // BAGIAN KANAN: AnimatedTextKit (RESPONSIVE)

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final fontSize =
                              _responsiveFontSize(constraints.maxWidth);
                          return AnimatedTextKit(
                            animatedTexts: [
                              TyperAnimatedText(
                                '🚀 Perhatikan nama operator ketika Stop',
                                textStyle: GoogleFonts.poppins(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800, // lebih kontras
                                ),
                                speed: const Duration(milliseconds: 80),
                              ),
                              FadeAnimatedText(
                                '📢 Jangan salah Jobnumber ketika Stop',
                                textStyle: GoogleFonts.poppins(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrangeAccent.shade400
                                      .withValues(
                                          alpha: 0.5), // lebih "pop" di grey
                                ),
                              ),
                              ColorizeAnimatedText(
                                '💡 Konfirmasi dengan scan QRcode Anda',
                                textStyle: GoogleFonts.poppins(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                colors: [
                                  Colors.blue.shade700,
                                  Colors.cyan.shade400,
                                  Colors.lightGreenAccent.shade400,
                                  Colors.deepPurpleAccent.shade100,
                                ],
                              ),
                            ],
                            repeatForever: true,
                            pause: const Duration(milliseconds: 800),
                            displayFullTextOnTap: true,
                            stopPauseOnTap: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )),

          const Divider(height: 1, thickness: 1),

          // --- BAGIAN 2: BODY KONTEN (MENGGUNAKAN EXPANDED) ---
          Expanded(
            child: IndexedStack(
              index: _currentView.index,
              children: [
                // 0. Tampilan Grid Mesin
                ListViewMoldRunning(
                    title: widget.title,
                    idProses: widget.idProses), // Widget Grid yang kamu buat

                // 1. Tampilan List Job Number
                TableViewMoldRunning(
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
                        Colors.blue.shade300.withValues(alpha: 0.95),
                        Colors.lightBlue.shade500.withValues(alpha: 0.85),
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
                        color: Colors.black.withValues(alpha: 0.25),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        offset: const Offset(-2, -2),
                        blurRadius: 4,
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
                color: isSelected ? Colors.blue.shade900 : Colors.blue.shade700,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      color: isSelected ? Colors.white : Colors.blue.shade800),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.blue.shade800,
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
class ListViewMoldRunning extends StatelessWidget {
  final String title;
  final String idProses;

  const ListViewMoldRunning(
      {super.key, required this.title, required this.idProses});

  @override
  Widget build(BuildContext context) {
    return RunningListView(title: title, idProses: idProses);
  }
}

class TableViewMoldRunning extends StatelessWidget {
  final String title;
  final String idProses;
  const TableViewMoldRunning(
      {super.key, required this.title, required this.idProses});

  @override
  Widget build(BuildContext context) {
    return RunningGridView(title: title, idProses: idProses);
  }
}
