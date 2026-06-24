import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:flutter_provider_data/page/001-molding/reason_dialog_mass/mass_reason_dialog.dart';
import 'package:flutter_provider_data/provider/reason_provider.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/page/001-molding/running_grid_view/widget/running_grid_top_menu.dart';
import 'package:flutter_provider_data/page/001-molding/running_grid_view/widget/running_molding_grid_body.dart';

class RunningGridView extends StatefulWidget {
  final String title;
  final String idProses;
  const RunningGridView(
      {super.key, required this.title, required this.idProses});

  @override
  State<RunningGridView> createState() => _RunningGridViewState();
}

class _RunningGridViewState extends State<RunningGridView> {
  late Future<List<RecordRunningModel>> records;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<RunningProvider>();
      prov.loadRunningRecords(widget.idProses);
    });
  }

  Future<void> scanFilterJobNumber() async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final prov = context.read<RunningProvider>();

    try {
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MobileScannerPage(),
          transitionsBuilder: (_, animation, __, child) =>
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

      prov.setFilterSearch(jobNumber: getcode.substring(9, 19).trim());
    } catch (e) {
      CustomSnackbar.showWithOverlay(
        overlay,
        "Error scanning: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> scanFilterEmployee() async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final prov = context.read<RunningProvider>();

    try {
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MobileScannerPage(),
          transitionsBuilder: (_, animation, __, child) =>
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

      prov.setFilterSearch(employee: getcode);
    } catch (e) {
      CustomSnackbar.showWithOverlay(
        overlay,
        "Error scanning employee: $e",
        isSuccess: false,
      );
    }
  }

  void _onStopPressed() async {
    final prov = context.read<RunningProvider>();

    if (prov.selectedItems.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Peringatan"),
          content: const Text("Belum ada data yang dipilih."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      );
      return;
    }

    final firstEmployee =
        prov.selectedItems.first.activeEmployee?.fullName ?? '';
    final sameEmployee = prov.selectedItems.every(
      (item) => item.activeEmployee?.fullName == firstEmployee,
    );

    if (!sameEmployee) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.shade600,
                      width: 2.2,
                    ),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Peringatan",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            content: Text(
              "Harap pilih Operator yang sama agar proses dapat dilanjutkan.",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "MENGERTI",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    final reasonProvider = context.read<ReasonProvider>();
    await reasonProvider.loadReasonData(idProses: widget.idProses);

    if (!mounted) return; // ← cek setelah await

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, _, __) {
        return Center(
          child: ReasonSelectedMassdialog(
            idProses: widget.idProses,
          ),
        );
      },
      transitionBuilder: (ctx, anim, __, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: curved,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildProviderLoading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildProviderError(String message) {
    return Scaffold(
      body: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widthApp = MediaQuery.of(context).size.width;
    final prov = context.watch<RunningProvider>();

    if (prov.isLoading) return _buildProviderLoading();
    if (prov.hasError) return _buildProviderError(prov.errorMessage);

    return Scaffold(
      body: Column(
        children: [
          RunningGridTopMenu(
            widthApp: widthApp,
            prov: prov,
            onScanJobNumber: scanFilterJobNumber,
            onScanEmployee: scanFilterEmployee,
            onClearFilter: prov.clearFilterSearch,
            onStopSelected: _onStopPressed,
          ),
          RunningMoldingGridBody(
            list: prov.filteredRecords,
          ),
        ],
      ),
    );
  }
}
