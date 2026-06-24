import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_pending_model.dart';
import 'package:flutter_provider_data/page/001-molding/dialog_confirm_mass_running.dart';
import 'package:flutter_provider_data/page/001-molding/show_warning_dialog.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/page/001-molding/show_running_dialog.dart';

class StopGridView extends StatefulWidget {
  final String title;
  final String idProses;

  const StopGridView({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  _StopGridViewState createState() => _StopGridViewState();
}

class _StopGridViewState extends State<StopGridView> {
  final List<RecordPendingModel> _selectedItems = [];

  final String _errorMessage = '';

  String getcode = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<PendingProvider>();
      prov.fetchPending(widget.idProses);
    });
  }

  Future<void> scanAndFilterJobNumber() async {
    try {
      final prov = Provider.of<PendingProvider>(context, listen: false);

      // 📷 Step 1: Scan pakai MobileScannerPage
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
          reverseTransitionDuration:
              const Duration(milliseconds: 300), // pop halus
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // 📌 Step 2: Validasi format QRCode (ubah regex sesuai kebutuhan)
      if (!RegExp(r'^[a-zA-Z0-9]{9}[0-9]{10}[0-9]{5}$').hasMatch(getcode)) {
        CustomSnackbar.show(
          context,
          "Invalid QR Code format.",
          isSuccess: false,
        );

        return;
      }

      // 🔹 Ambil 10 karakter dari index ke-9
      String joblot = getcode.substring(9, 19).trim();

      // ✅ Step 3: Update state dan filter list
      if (!mounted) return;
      setState(() {
        prov.scannedJobNumber = joblot;
        // prov.applyFilter();
      });
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Error scanning: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> scanAndFilterEmployee() async {
    try {
      // 📷 Step 1: Scan pakai MobileScannerPage
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
          reverseTransitionDuration:
              const Duration(milliseconds: 300), // pop halus
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // 📌 Step 2: Validasi QRCode Employee (8 digit)
      if (getcode.length != 8) {
        CustomSnackbar.show(
          context,
          "Yang discan bukan ID Employee",
          isSuccess: false,
        );

        return;
      }

      // ✅ Step 3: Update state dan filter list
      if (!mounted) return;
      setState(() {
        prov.scannedEmployeeFinishId = getcode;
        // prov.applyFilter();
      });
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Error scanning operator: $e",
        isSuccess: false,
      );
    }
  }

  void _onContinuePressed() async {
    // VALIDASI PILIHAN ITEM
    if (_selectedItems.isEmpty) {
      await showWarningDialog(context, "Belum ada data yang dipilih.");
      return;
    }

    // VALIDASI SEMUA EMPLOYEE SAMA
    final firstEmployee = _selectedItems.first.employeeName;
    final sameEmployee = _selectedItems.every(
      (item) => item.employeeName == firstEmployee,
    );

    if (!sameEmployee) {
      await showWarningDialog(
        context,
        "HARAP PILIH OPERATOR YANG SAMA AGAR PROSES DAPAT DI LANJUTKAN",
      );
      return;
    }

    // VALIDASI CODE REASON
    final codereason = _selectedItems.first.idReason;
    const reasonMessages = {
      '02': 'REASON WORKDAY OVER TIDAK BISA DI RUNNING DARI MENU INI',
      '03': 'REASON CHANGE OPERATOR TIDAK BISA DI RUNNING DARI MENU INI',
      '06': 'REASON CHANGE MACHINE TIDAK BISA DI RUNNING DARI MENU INI',
    };

    if (reasonMessages.containsKey(codereason)) {
      await showWarningDialog(context, reasonMessages[codereason]!);
      return;
    }

    // JIKA VALIDASI LULUS
    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return DialogConfirmMassRunning(
            selectedItems: _selectedItems,
            idProses: widget.idProses,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widthApp = MediaQuery.of(context).size.width;
    final prov = Provider.of<PendingProvider>(context);

    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    if (prov.hasError) return Center(child: Text('Error: $_errorMessage'));

    final filteredList = prov.filteredPending;

    return Scaffold(
      body: Column(
        children: [
          _buildTopRow(widthApp, prov),
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) =>
                        _buildGridItem(filteredList[index], prov),
                  ),
          ),
        ],
      ),
    );
  }

// ================= TOP ROW (FILTER + CONTINUES + TOTAL) =================
  Widget _buildTopRow(double widthApp, PendingProvider prov) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Row(
        children: [
          _filterButton(widthApp * 0.20, prov.isFilterActive,
              Icons.search_sharp, 'JOBNUMBER', scanAndFilterJobNumber),
          SizedBox(width: widthApp * 0.01),
          _filterButton(widthApp * 0.20, prov.isFilterActive,
              Icons.person_search, 'OPERATOR', scanAndFilterEmployee),
          SizedBox(width: widthApp * 0.01),
          if (prov.isFilterActive) _clearButton(),
          const Spacer(),
          _continueButton(widthApp * 0.20),
          SizedBox(width: widthApp * 0.02),
          _totalText(prov.filteredPending.length),
        ],
      ),
    );
  }

// ================= FILTER BUTTON =================
  Widget _filterButton(double width, bool isDisabled, IconData icon,
      String label, Future<void> Function() onTap) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          side: BorderSide(
            color: isDisabled ? Colors.grey.shade400 : Colors.green.shade400,
            width: 1,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color:
                    isDisabled ? Colors.grey.shade400 : Colors.green.shade400),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDisabled ? Colors.grey.shade400 : Colors.green.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ================= CLEAR BUTTON =================
  Widget _clearButton() {
    return SizedBox(
      width: 52,
      child: InkWell(
        onTap: () =>
            Provider.of<PendingProvider>(context, listen: false).clearFilter(),
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
                  offset: const Offset(1, 2))
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.clear, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

// ================= CONTINUE BUTTON =================
  Widget _continueButton(double width) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: _selectedItems.isEmpty
              ? LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500])
              : LinearGradient(
                  colors: [Colors.greenAccent, Colors.green.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          borderRadius: BorderRadius.circular(26),
        ),
        child: OutlinedButton(
          onPressed: _selectedItems.isEmpty ? null : _onContinuePressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            backgroundColor: Colors.transparent,
            side: BorderSide.none,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow_rounded,
                  size: 20,
                  color: _selectedItems.isEmpty
                      ? Colors.grey.shade300
                      : Colors.white),
              const SizedBox(width: 4),
              Text(
                'CONTINUE',
                style: GoogleFonts.poppins(
                  color: _selectedItems.isEmpty
                      ? Colors.grey.shade300
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// ================= TOTAL TEXT =================
  Widget _totalText(int total) {
    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          shadows: [
            Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2,
                color: Colors.grey.withValues(alpha: 0.4))
          ],
        ),
        children: [
          TextSpan(
            text: 'TOTAL ',
            style: GoogleFonts.poppins(
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.w500,
                fontSize: 18),
          ),
          WidgetSpan(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                '$total',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
          TextSpan(
            text: ' MOLD STOP',
            style: GoogleFonts.poppins(
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.w500,
                fontSize: 18),
          ),
        ],
      ),
    );
  }

// ================= EMPTY STATE =================
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'TIDAK ADA STOP MOLDING.',
        style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
            letterSpacing: 0.5),
      ),
    );
  }

// ================= GRID ITEM =================
  Widget _buildGridItem(dynamic item, PendingProvider prov) {
    final isSelected = _selectedItems.contains(item);

    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected ? _selectedItems.remove(item) : _selectedItems.add(item);
        });
      },
      child: Stack(
        children: [
          _gridItemCard(item, isSelected, prov),
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
        ],
      ),
    );
  }

// ================= GRID ITEM CARD =================
  Widget _gridItemCard(dynamic item, bool isSelected, PendingProvider prov) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  Colors.green.shade200.withValues(alpha: 0.6),
                  Colors.green.shade100.withValues(alpha: 0.3)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.green.shade400.withValues(alpha: 0.3)
                : Colors.grey.shade300.withValues(alpha: 0.2),
            blurRadius: isSelected ? 14 : 6,
            spreadRadius: isSelected ? 3 : 1,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isSelected ? Colors.lightGreen.shade500 : Colors.transparent,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // JOB NUMBER
          Text(
            item.jobnumber ?? '-',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.grey.shade800
                    : Colors.blueGrey.shade600,
                letterSpacing: 1.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _operatorPhoto(item),
          const SizedBox(height: 6),
          Text(
            item.employeeName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green.shade700 : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          _gridItemTable(item),
          const Spacer(),
          _gridItemContinueButton(item),
        ],
      ),
    );
  }

// ================= OPERATOR PHOTO =================
  Widget _operatorPhoto(dynamic item) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.green.shade300.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.1),
            ],
            stops: const [0.4, 1.0],
          ),
          border: Border.all(color: Colors.green.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade400.withValues(alpha: 0.25),
              blurRadius: 25,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.green.shade200.withValues(alpha: 0.2),
              blurRadius: 35,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.green.shade100.withValues(alpha: 0.15),
              blurRadius: 45,
              spreadRadius: 6,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(
            "${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png",
          ),
          onBackgroundImageError: (_, __) =>
              const Icon(Icons.person, size: 28, color: Colors.grey),
        ),
      ),
    );
  }

// ================= GRID ITEM TABLE =================
  Widget _gridItemTable(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(6),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _tableRow('MACHINE', item.machineName),
          const TableRow(children: [SizedBox(height: 4), SizedBox(height: 2)]),
          _tableRow('DRAW NO', item.drawingNumber),
          const TableRow(children: [SizedBox(height: 4), SizedBox(height: 2)]),
          _tableRow('REASON', item.reason ?? '-', color: Colors.red.shade700),
        ],
      ),
    );
  }

  TableRow _tableRow(String title, String value, {Color? color}) {
    return TableRow(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            ': $value',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey.shade900,
            ),
          ),
        ),
      ],
    );
  }

// ================= GRID ITEM CONTINUE BUTTON =================
  Widget _gridItemContinueButton(dynamic item) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          colors: _selectedItems.contains(item)
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : [Colors.greenAccent, Colors.green.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ElevatedButton(
        onPressed: () async {
          // ✅ Simpan reference sebelum await
          final pendingProvider =
              Provider.of<PendingProvider>(context, listen: false);
          final overlay = Overlay.of(context, rootOverlay: true);

          try {
            final result = await showRunningDialog(
              context,
              item.idPending.toString(),
              item.idReason.toString(),
              widget.idProses,
              item.productType,
            );

            if (!mounted) return;

            if (result == true) {
              pendingProvider.fetchPending(widget.idProses);
              CustomSnackbar.show(
                context,
                "Record updated successfully!",
                isSuccess: true,
              );
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
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          "CONTINUE",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
