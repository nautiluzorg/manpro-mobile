import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:flutter_provider_data/page/001-molding/reason_dialog/reason_dialog.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/page/001-molding/running_list_view/widget/running_list_top_menu.dart';
import 'package:flutter_provider_data/page/001-molding/running_list_view/widget/running_list_body.dart';

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
      context.read<RunningProvider>().loadRunningRecords(widget.idProses);
    });
  }

  Future<void> scanAndFilterJobNumber() async {
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
        CustomSnackbar.showWithOverlay(overlay, "Invalid QR Code format.",
            isSuccess: false);
        return;
      }

      prov.setFilterSearch(
        jobNumber: getcode.substring(9, 19).trim(),
        employee: prov.scannedFilterEmployee,
      );
    } catch (e) {
      CustomSnackbar.showWithOverlay(overlay, "Error scanning: $e",
          isSuccess: false);
    }
  }

  Future<void> scanAndFilterEmployeeFinish() async {
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
        CustomSnackbar.showWithOverlay(overlay, "Yang discan bukan ID Employee",
            isSuccess: false);
        return;
      }

      prov.setFilterSearch(
        jobNumber: prov.scannedFilterJobNumber,
        employee: getcode,
      );
    } catch (e) {
      CustomSnackbar.showWithOverlay(overlay, "Error scanning employee: $e",
          isSuccess: false);
    }
  }

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
                  await prov.refresh(widget.idProses);
                },
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final widthApp = MediaQuery.of(context).size.width;
    final prov = context.watch<RunningProvider>();

    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    if (prov.hasError) {
      return Center(child: Text('Error: ${prov.errorMessage}'));
    }

    return Scaffold(
      body: Column(
        children: [
          RunningListTopMenu(
            widthApp: widthApp,
            prov: prov,
            onScanJobNumber: scanAndFilterJobNumber,
            onScanEmployee: scanAndFilterEmployeeFinish,
            onClearFilter: prov.clearFilterSearch,
          ),
          RunningListBody(
            idProses: widget.idProses,
            onStopDialog: _openStopDialog,
          ),
        ],
      ),
    );
  }
}
