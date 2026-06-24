import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/employee_monitoring_grid.dart';
import 'package:flutter_provider_data/page/001-molding/machine_monitoring_grid.dart';
import 'package:flutter_provider_data/page/001-molding/record_on_progress.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';

enum MonitoringView { machineGrid, employeeGrid, jobList }

class MonitoringMasterPage extends StatefulWidget {
  final String title;
  final String idProses;
  const MonitoringMasterPage(
      {super.key, required this.title, required this.idProses});

  @override
  State<MonitoringMasterPage> createState() => _MonitoringMasterPageState();
}

class _MonitoringMasterPageState extends State<MonitoringMasterPage> {
  // State untuk melacak tampilan mana yang sedang aktif
  MonitoringView _currentView = MonitoringView.machineGrid;

  @override
  Widget build(BuildContext context) {
    final myAppBar = customAppBar(
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
          // --- BAGIAN 1: CUSTOM SEGMENTED CONTROL / MENU BUTTONS ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton(
                  title: "VIEW ON MESIN",
                  view: MonitoringView.machineGrid,
                  icon: Icons.grid_view,
                ),
                _buildTabButton(
                  title: "VIEW ON OPERATOR",
                  view: MonitoringView.employeeGrid,
                  icon: Icons.menu,
                ),
                _buildTabButton(
                  title: "VIEW ON JOBNUMBER",
                  view: MonitoringView.jobList,
                  icon: Icons.list_alt,
                ),
                // Tambahkan button menu lainnya di sini
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1), // Garis pemisah

          // --- BAGIAN 2: BODY KONTEN (MENGGUNAKAN EXPANDED) ---
          Expanded(
            child: IndexedStack(
              index: _currentView.index,
              children: [
                // 0. Tampilan Grid Mesin
                MachineMonitoringGridBody(
                    title: widget.title, idProses: widget.idProses),

                EmployeeMonitoringGridBody(
                    title: widget.title, idProses: widget.idProses),

                // Widget Grid yang kamu buat

                // 1. Tampilan List Job Number
                JobNumberListPage(
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

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _currentView = view;
            });
          },
          icon: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.blue.shade800,
          ),
          label: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.blue.shade800,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue.shade700 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.blue.shade700, width: 1.5),
            ),
            elevation: isSelected ? 4 : 1,
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
        ),
      ),
    );
  }
}

// ASUMSI: Wrapper untuk GridView agar bisa menjadi children dari IndexedStack
class MachineMonitoringGridBody extends StatelessWidget {
  final String title;
  final String idProses;

  const MachineMonitoringGridBody(
      {super.key, required this.title, required this.idProses});

  @override
  Widget build(BuildContext context) {
    // Memanggil MachineMonitoringGrid, tapi tanpa Scaffold/AppBar agar pas di body
    return MachineMonitoringGrid(title: title, idProses: idProses);
  }
}

class EmployeeMonitoringGridBody extends StatelessWidget {
  final String title;
  final String idProses;

  const EmployeeMonitoringGridBody(
      {super.key, required this.title, required this.idProses});

  @override
  Widget build(BuildContext context) {
    // Memanggil MachineMonitoringGrid, tapi tanpa Scaffold/AppBar agar pas di body
    return EmployeeMonitoringGrid(title: title, idProses: idProses);
  }
}

// ASUMSI: Widget list data job number milikmu
class JobNumberListPage extends StatelessWidget {
  final String title;
  final String idProses;
  const JobNumberListPage(
      {super.key, required this.title, required this.idProses});

  @override
  Widget build(BuildContext context) {
    return RecordOnProgress(title: title, idProses: idProses);
  }
}
