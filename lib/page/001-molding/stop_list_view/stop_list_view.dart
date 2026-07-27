import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'widget/stop_list_top_menu.dart';
import 'widget/stop_list_body.dart';

class StopListView extends StatefulWidget {
  final String title;
  final String idProses;

  const StopListView({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<StopListView> createState() => _StopListViewState();
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

  // Scan/navigation logic tetap di UI layer (bukan di provider), sesuai
  // arsitektur project: provider tidak boleh menerima BuildContext.

  Future<void> _scanJobNumber() async {
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

      if (!mounted || getcode == null || getcode.isEmpty || getcode == "-1") {
        return;
      }

      if (!RegExp(r'^[a-zA-Z0-9]{9}[0-9]{10}[0-9]{5}$').hasMatch(getcode)) {
        if (!mounted) return;
        CustomSnackbar.show(context, "Invalid QR Code format.",
            isSuccess: false);
        return;
      }

      final joblot = getcode.substring(9, 19).trim();

      final prov = context.read<PendingProvider>();
      prov.scannedJobNumber = joblot;
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(context, "Error scanning: $e", isSuccess: false);
    }
  }

  Future<void> _scanEmployee() async {
    try {
      final prov = context.read<PendingProvider>();

      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );

      if (!mounted || getcode == null || getcode.isEmpty || getcode == "-1") {
        return;
      }

      if (getcode.length != 8) {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Yang discan bukan ID Employee",
          isSuccess: false,
        );
        return;
      }

      setState(() {
        prov.scannedEmployeeFinishId = getcode;
      });
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Error scanning operator: $e",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthApp = MediaQuery.of(context).size.width;
    final prov = context.watch<PendingProvider>();

    return Scaffold(
      body: Column(
        children: [
          StopListTopMenu(
            widthApp: widthApp,
            prov: prov,
            onScanJobNumber: _scanJobNumber,
            onScanEmployee: _scanEmployee,
            onClearFilter: prov.clearFilter,
          ),
          Expanded(
            child: StopListBody(
              prov: prov,
              idProses: widget.idProses,
            ),
          ),
        ],
      ),
    );
  }
}
