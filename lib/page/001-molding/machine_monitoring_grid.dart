import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/machine_detail_running_dialog.dart';
import 'package:flutter_provider_data/page/001-molding/machine_detail_stop_dialog.dart';
import 'package:flutter_provider_data/page/001-molding/machine_detail_testing_dialog.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/model/machine_layout_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MachineMonitoringGrid extends StatefulWidget {
  final String title;
  final String idProses;

  const MachineMonitoringGrid({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<MachineMonitoringGrid> createState() => _MachineMonitoringGridState();
}

class _MachineMonitoringGridState extends State<MachineMonitoringGrid> {
  // ================= STATUS CONFIG (SAMA PERSIS) =================

  final Map<String, String> statusLabels = {
    'running': 'RUNNING',
    'pending': 'STOP',
    'available': 'AVAILABLE',
    'testing': 'TESTING',
  };

  String menuStatusLabel(String key) {
    final baseLabel = statusLabels[key] ?? key.toUpperCase();
    return 'MACHINE $baseLabel';
  }

  final Map<String, List<Color>> statusGradients = {
    'running': [Colors.greenAccent.shade400, Colors.green.shade800],
    'pending': [Colors.redAccent, Colors.red.shade800],
    'available': [Colors.blueAccent, Colors.blue.shade800],
    'testing': [Colors.orangeAccent, Colors.orange.shade800],
  };

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MachineProvider>().fetchMachineMonitoring();
    });
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Consumer<MachineProvider>(
      builder: (context, prov, _) {
        if (prov.isMonitoringLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (prov.monitoringError != null) {
          return const Center(
            child: Text('Gagal memuat data mesin.'),
          );
        }

        final machines = prov.monitoringList;
        final statusCounts = _countStatus(machines);

        final screenWidth = MediaQuery.of(context).size.width;
        final itemWidth = (screenWidth * 0.24).clamp(120.0, 220.0);

        return Scaffold(
          body: Column(
            children: [
              // ================= HEADER (IDENTIK) =================
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: statusLabels.keys.map((key) {
                              return Container(
                                width: itemWidth,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: statusGradients[key]!,
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  '${menuStatusLabel(key)} ${statusCounts[key]}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ================= GRID (IDENTIK) =================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GridView.builder(
                    itemCount: machines.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final machine = machines[index];
                      final gradient =
                          statusGradients[machine.runStatus.toLowerCase()] ??
                              [Colors.grey.shade400, Colors.grey.shade700];
                      final statusLabel =
                          statusLabels[machine.runStatus.toLowerCase()] ??
                              machine.runStatus;

                      return _buildMachineCard(
                        machine,
                        gradient,
                        statusLabel,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= CARD (IDENTIK) =================

  Widget _buildMachineCard(
    MachineLayoutModel machine,
    List<Color> gradient,
    String statusLabel,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        final status = machine.runStatus.toLowerCase();
        if (status != 'available') {
          _showMachineDialog(machine);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              machine.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DIALOG (IDENTIK) =================

  void _showMachineDialog(MachineLayoutModel machine) {
    Widget dialogPage;

    switch (machine.runStatus.toLowerCase()) {
      case 'running':
        dialogPage = MachineDetailRunningDialog(machine: machine);
        break;

      case 'pending':
      case 'stop':
        dialogPage = MachineDetailStopDialog(machine: machine);
        break;

      case 'testing':
        dialogPage = MachineDetailTestingDialog(machine: machine);
        break;

      default:
        dialogPage = MachineDetailRunningDialog(machine: machine);
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Machine Detail',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return dialogPage;
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: tween.animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // ================= HELPER (IDENTIK LOGIC) =================

  Map<String, int> _countStatus(List<MachineLayoutModel> machines) {
    Map<String, int> counts = {
      for (var key in statusLabels.keys) key: 0,
    };

    for (var m in machines) {
      final key = m.runStatus.toLowerCase();
      if (counts.containsKey(key)) {
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    return counts;
  }
}








/*

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_provider_data/config/app_config.dart';

class MachineMonitoringGrid extends StatefulWidget {
  final String title;
  final String idProses;
  const MachineMonitoringGrid({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<MachineMonitoringGrid> createState() => _MachineMonitoringGridState();
}

class _MachineMonitoringGridState extends State<MachineMonitoringGrid> {
  List<Machine> _machineList = [];
  bool _isLoading = true;
  bool _hasError = false;

  final Map<String, String> statusLabels = {
    'running': 'RUNNING',
    'pending': 'STOP',
    'available': 'AVAILABLE',
    'testing': 'TESTING',
  };

  String menuStatusLabel(String key) {
    final baseLabel = statusLabels[key] ?? key.toUpperCase();
    return 'MACHINE $baseLabel';
  }

  final Map<String, List<Color>> statusGradients = {
    'running': [Colors.green.shade400, Colors.green.shade800],
    'pending': [Colors.red.shade400, Colors.red.shade800],
    'available': [Colors.blue.shade400, Colors.blue.shade800],
    'testing': [Colors.orange.shade400, Colors.orange.shade800],
  };

  @override
  void initState() {
    super.initState();
    _fetchMachineData();
  }

  Future<void> _fetchMachineData() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/machine-layout-status/'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _machineList = machinesFromJson(jsonData)
              .where((m) => statusLabels.keys.contains(m.status.toLowerCase()))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Map<String, int> _countStatus() {
    Map<String, int> counts = {
      for (var key in statusLabels.keys) key: 0,
    };
    for (var m in _machineList) {
      final key = m.status.toLowerCase();
      if (counts.containsKey(key)) {
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return const Center(child: Text('Gagal memuat data mesin.'));
    }

    final statusCounts = _countStatus();

    final screenWidth = MediaQuery.of(context).size.width;

// contoh: 18% dari lebar layar
    final itemWidth = (screenWidth * 0.24).clamp(120.0, 220.0);

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade100.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth, // 🔥 KUNCI UTAMA
                    ),
                    child: Align(
                      alignment: Alignment.center, // ✅ sekarang BERFUNGSI
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: statusLabels.keys.map((key) {
                          return Container(
                            width: itemWidth,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: statusGradients[key]!,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              '${menuStatusLabel(key)} ${statusCounts[key]}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Grid mesin
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: GridView.builder(
                itemCount: _machineList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final machine = _machineList[index];
                  final gradient =
                      statusGradients[machine.status.toLowerCase()] ??
                          [Colors.grey.shade400, Colors.grey.shade700];
                  final statusLabel =
                      statusLabels[machine.status.toLowerCase()] ??
                          machine.status;
                  return _buildMachineCard(machine, gradient, statusLabel);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineCard(
      Machine machine, List<Color> gradient, String statusLabel) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        final status = machine.status.toLowerCase();

        // 🔴 HANYA BUKAN AVAILABLE
        if (status != 'available') {
          _showMachineDialog(machine);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
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
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nama mesin
            Text(
              machine.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            // Status mesin
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11, // 🔥 diperkecil sedikit biar tidak overflow
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMachineDialog(Machine machine) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            'Machine Status',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Machine : ${machine.name}'),
              const SizedBox(height: 6),
              Text(
                'Status : ${machine.status.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // aksi lanjutan jika perlu
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// MODEL DATA MESIN
class Machine {
  final String id;
  final String name;
  String status;

  Machine({
    required this.id,
    required this.name,
    required this.status,
  });
}

// PARSING JSON KE LIST<Machine>
List<Machine> machinesFromJson(Map<String, dynamic> json) {
  return List<Machine>.from(json['machines'].map(
    (m) => Machine(
      id: m['id_mc'],
      name: m['nm_mc'],
      status: m['run_status'],
    ),
  ));
}
*/