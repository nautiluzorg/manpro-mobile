import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/provider/record_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EmployeeMonitoringGrid extends StatefulWidget {
  final String title;
  final String idProses;
  const EmployeeMonitoringGrid(
      {Key? key, required this.title, required this.idProses})
      : super(key: key);

  @override
  State<EmployeeMonitoringGrid> createState() => _EmployeeMonitoringGridState();
}

class _EmployeeMonitoringGridState extends State<EmployeeMonitoringGrid> {
  // final TextEditingController _jobNumberController = TextEditingController();
  // final TextEditingController _employeeFinishController =TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecordProvider>(context, listen: false)
          .loadRecords(runStatus: 'pending,running');
    });
  }

  String widgetText(String status) {
    if (status.toLowerCase() == 'running') {
      return 'RUNNING'; // huruf besar
    } else {
      return 'STOP'; // jika pending, jadi stop
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Text('Error: ${provider.errorMessage}'),
            );
          }

          return Column(
            children: [
              // ================== FILTER ==================
              Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  width:
                      double.infinity, // 👈 WAJIB: biar container selebar layar
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
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
                                    Icon(Icons.search_sharp,
                                        color: Colors.white),
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
                          'TOTAL ON PROCESS: 0',
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

              const Divider(height: 1),

              // ================== GRID ==================

              Expanded(
                child: provider.filteredRecords.isEmpty
                    ? const Center(child: Text('No records found'))
                    : RefreshIndicator(
                        onRefresh: () => provider.refresh(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(4),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6, // 6 item per baris
                            childAspectRatio: 0.55,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: provider.filteredRecords.length,
                          itemBuilder: (context, index) {
                            final r = provider.filteredRecords[index];
                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor:
                                  Colors.blueGrey.withValues(alpha: 0.3),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widgetText(r.runStatus),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: r.runStatus.toLowerCase() ==
                                                'running'
                                            ? Colors.green
                                            : Colors.red.shade500
                                                .withValues(alpha: 0.8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    // FOTO BULAT DENGAN AURA API
                                    FireAuraAvatar(
                                      imageUrl:
                                          "${AppConfig.baseUrl}/media/img/employee/${r.idEmployeeFinish}.png",
                                      radius: 45,
                                      runStatus: r
                                          .runStatus, // "running" atau "pending"
                                    ),

                                    const SizedBox(height: 8),
                                    // INFO DI BAWAH FOTO
                                    Text(
                                      r.employeeFinish?.fullName ?? '-',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),

                                    Text(
                                      r.jobnumbers.isNotEmpty
                                          ? r.jobnumbers[0].jobNumber
                                          : '-',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blueGrey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 2),
                                    // ================= BUTTON DELETE =================
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Tampilkan konfirmasi
                                        bool? confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: const Text(
                                                'Are you sure you want to delete this record?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          try {
                                            await Provider.of<RecordProvider>(
                                                    context,
                                                    listen: false)
                                                .deleteRecord(r.idRecord);

                                            // Tampilkan Snackbar
                                            CustomSnackbar.show(
                                              context,
                                              "RECORD SUCCESSFULLY DELETE.",
                                              isSuccess: true,
                                            );
                                          } catch (e) {
                                            // Kalau ada error, tampilkan Snackbar error
                                            CustomSnackbar.show(
                                              context,
                                              "FAILED TO DELETE $e.",
                                              isSuccess: false,
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade400,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2, vertical: 2),
                                        textStyle: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================= FireAuraAvatar dengan status =================
class FireAuraAvatar extends StatefulWidget {
  final String imageUrl;
  final double radius;
  final String runStatus; // "running" atau "pending"

  const FireAuraAvatar({
    Key? key,
    required this.imageUrl,
    this.radius = 45,
    this.runStatus = 'pending',
  }) : super(key: key);

  @override
  _FireAuraAvatarState createState() => _FireAuraAvatarState();
}

class _FireAuraAvatarState extends State<FireAuraAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.runStatus == 'running') {
      // Animasi kedip-kedip untuk status running
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      )..repeat(reverse: true);
    } else {
      // Status pending, controller diam
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
        value: 1.0,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.runStatus == 'pending') {
      // BORDER MERAH TETAP
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 3),
        ),
        child: CircleAvatar(
          radius: widget.radius,
          backgroundImage: NetworkImage(widget.imageUrl),
          backgroundColor: Colors.grey.shade400,
          onBackgroundImageError: (_, __) {},
        ),
      );
    } else {
      // AURA HIJAU ANIMASI KEDIP-KEDIP
      return AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          double animValue = _controller.value;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.5 + 0.9 * animValue),
                  spreadRadius: 4 * animValue + 4,
                  blurRadius: 12 * animValue + 6,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: widget.radius,
              backgroundImage: NetworkImage(widget.imageUrl),
              backgroundColor: Colors.grey.shade400,
              onBackgroundImageError: (_, __) {},
            ),
          );
        },
      );
    }
  }
}
