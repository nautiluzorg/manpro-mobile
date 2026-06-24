import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/page/main_menu_admin.dart';
import 'package:flutter_provider_data/provider/record_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecordActiveProcess extends StatefulWidget {
  final String title;
  final String idProses;
  const RecordActiveProcess(
      {Key? key, required this.title, required this.idProses})
      : super(key: key);

  @override
  State<RecordActiveProcess> createState() => _RecordActiveProcessState();
}

class _RecordActiveProcessState extends State<RecordActiveProcess> {
  final TextEditingController _jobNumberController = TextEditingController();
  final TextEditingController _employeeFinishController =
      TextEditingController();

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
    final myAppBar = PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight), // Ukuran AppBar
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade800], // Gradasi warna
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          title: Text(
            'MOLD PROCESS',
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
                      MainMenuAdmin(),
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
          backgroundColor:
              Colors.transparent, // Menjadikan background AppBar transparan
        ),
      ),
    );

    return Scaffold(
      appBar: myAppBar,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _jobNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Job Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _employeeFinishController,
                        decoration: const InputDecoration(
                          labelText: 'Employee Finish ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        provider.setFilter(
                          jobNumber: _jobNumberController.text,
                          employeeFinishId: _employeeFinishController.text,
                          runStatus: 'pending,running',
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _jobNumberController.clear();
                        _employeeFinishController.clear();
                        provider.clearFilter();
                      },
                    ),
                  ],
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
