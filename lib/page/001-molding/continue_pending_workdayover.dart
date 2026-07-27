import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart'; // ← untuk TextInputFormatter

class ContinuePendingWorkdayOver extends StatefulWidget {
  final String idPending;
  final String idProses;
  final String productType;

  final void Function(bool)? onSuccess;

  const ContinuePendingWorkdayOver({
    Key? key,
    required this.idPending,
    required this.idProses,
    required this.productType,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<ContinuePendingWorkdayOver> createState() =>
      _ContinuePendingWorkdayOverState();
}

class _ContinuePendingWorkdayOverState
    extends State<ContinuePendingWorkdayOver> {
  // ── State untuk New Operator Form ──────────────────────────────────────

  bool _showNewOperatorForm = false;

  final TextEditingController _qtyShootController = TextEditingController();
  final TextEditingController _ngController = TextEditingController();
  String _scannedEmployeeId = '';
  String _scannedEmployeeName = '';
  String _scannedEmployeeSection = '';
  String _scannedEmployeeDivision = '';
  String? _selectedNgId;
  String? _selectedNgName;
  int _qtyNg = 0;

  final List<Map<String, dynamic>> _addedNgItems = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pendingProv = context.read<PendingProvider>();
      final ngProvider = context.read<NGProvider>();

      pendingProv.resetPendingDetail();
      pendingProv.resetEmployeeScanState();
      pendingProv.clearNextMachine();

      // ← jalankan parallel, tidak saling tunggu
      await Future.wait([
        pendingProv.fetchPendingDetail(widget.idPending),
        ngProvider.loadNGList(
          productType: widget.productType,
          idProses: widget.idProses,
        ),
      ]);
    });
  }

  @override
  void dispose() {
    _qtyShootController.dispose();
    _ngController.dispose();
    super.dispose();
  }

  // ── Reset form new operator ─────────────────────────────────────────────
  void _resetNewOperatorForm() {
    setState(() {
      _showNewOperatorForm = false;
      _qtyShootController.clear();
      _ngController.clear();
      _scannedEmployeeId = '';
      _scannedEmployeeName = '';
      _scannedEmployeeSection = '';
      _scannedEmployeeDivision = '';
      _selectedNgId = null; // ← reset dropdown
      _selectedNgName = null; // ← reset nama NG
      _qtyNg = 0; // ← reset qty NG
      _addedNgItems.clear(); // ← clear list tabel NG ✅
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PendingProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: customDialogAppBar(
          title: _showNewOperatorForm
              ? "CONTINUE WORKDAY OVER WITH NEW OPERATOR"
              : "CONTINUE WORKDAY OVER WITH SAME OPERATOR",
        ),
      ),
      body: SafeArea(
        child: prov.isLoading || prov.pendingDetail.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          // ← Ganti konten berdasarkan state
                          if (_showNewOperatorForm) ...[
                            _buildNewOperatorForm(prov),
                          ] else ...[
                            _buildHeader(prov),
                            const SizedBox(height: 12),
                            _buildMainContent(prov),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(PendingProvider prov) {
    final data = prov.pendingDetail.first;

    Widget headerText(String text) => Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          headerText(data.idRecord),
          headerText(data.customer),
          headerText(data.productCategory),
          headerText(data.productType),
        ],
      ),
    );
  }

  // ================= MAIN CONTENT =================
  Widget _buildMainContent(PendingProvider prov) {
    final data = prov.pendingDetail.first;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── AREA OPERATOR & TABLE ────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── FOTO OPERATOR + INFO ─────────────────────────────
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.20,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.18,
                              height: MediaQuery.of(context).size.width * 0.18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.green.shade100
                                        .withValues(alpha: 0.3),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade300
                                        .withValues(alpha: 0.4),
                                    spreadRadius: 4,
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1.5),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  "${AppConfig.baseUrl}/media/img/employee/${data.idEmployee}.png",
                                  width:
                                      MediaQuery.of(context).size.width * 0.16,
                                  height:
                                      MediaQuery.of(context).size.width * 0.16,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.employeeName,
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.nrp,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          data.section.toUpperCase(),
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          data.division,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ── TABLE INFORMASI ──────────────────────────────────

                  Expanded(
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(4),
                        1: FlexColumnWidth(6),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        for (int i = 0; i < 8; i++)
                          TableRow(
                            decoration: BoxDecoration(
                              color: i.isEven
                                  ? Colors.grey.shade200
                                  : Colors.white,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  [
                                    'JOB NUMBER',
                                    'DRAW NO',
                                    'MACHINE',
                                    'QTY',
                                    'TIME STOP',
                                    'PENDING REASON',
                                    'STOP DURATION',
                                    'EMPLOYEE CONFIRM',
                                  ][i],
                                  style: GoogleFonts.poppins(
                                    fontWeight: i == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: i == 7
                                    ? Row(
                                        children: [
                                          Text(
                                            ": ${prov.isEmployeeScanned ? prov.employeeName : "BELUM CONFIRM"}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: prov.isEmployeeScanned
                                                  ? Colors.green
                                                  : Colors.black,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (prov.isEmployeeScanned)
                                            Row(
                                              children: const [
                                                Text(
                                                  "CONFIRMED",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                        ],
                                      )
                                    : Text(
                                        [
                                          ": ${data.jobnumber}",
                                          ": ${data.drawingNumber}",
                                          ": ${data.machineName}",
                                          ": ${data.qty}",
                                          ": ${formatDateTime(data.startPending)}",
                                          ": ${data.reason}",
                                          ": ${getStopDuration(data.startPending)}",
                                        ][i],
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: i == 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: i == 5
                                              ? Colors.red
                                              : Colors.black,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            _buildActionButtons(prov),
            const SizedBox(height: 8),

            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACTION BUTTONS =================
  Widget _buildActionButtons(PendingProvider prov) {
    return Column(
      children: [
        // ── Row 1: CANCEL, CONFIRM, SUBMIT ────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // CANCEL
            Expanded(
              child: SizedBox(
                height: 80,
                child: OutlinedButton(
                  onPressed: () {
                    prov.resetEmployeeState();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // CONFIRM

            Expanded(
              child: SizedBox(
                height: 80,
                child: buildCustomButton(
                  text: 'CONFIRM',
                  height: 80,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  gradient: LinearGradient(
                    colors: [
                      Colors.greenAccent,
                      Colors.green.shade600,
                      Colors.green.shade900,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  onPressed: () async {
                    final ctx =
                        context; // ⬅ simpan context aman sebelum async gap
                    final overlay = Overlay.of(ctx, rootOverlay: true);

                    final employeeProv = ctx.read<EmployeeProvider>();
                    final pendingProv = ctx.read<PendingProvider>();

                    final code = await Navigator.push<String>(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => const MobileScannerPage(),
                      ),
                    );

                    if (!ctx.mounted) return;
                    if (code == null || code.isEmpty || code == "-1") return;

                    // 🔥 Scan employee lewat EmployeeProvider
                    final success = await employeeProv.scanEmployee(code);

                    if (!ctx.mounted) return;

                    if (!success) {
                      CustomSnackbar.showWithOverlay(
                        overlay,
                        employeeProv.errorMessage ?? "Scan failed",
                        isSuccess: false,
                      );
                      return;
                    }

                    // 🔥 Employee valid → simpan ke PendingProvider
                    pendingProv.attachEmployee(employeeProv.employee);
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // SUBMIT
            Expanded(
              child: SizedBox(
                height: 80,
                child: Builder(
                  builder: (context) {
                    final bool isEnabled =
                        prov.isEmployeeValid() && !prov.isSubmitting;

                    return buildCustomButton(
                      text: 'SUBMIT',
                      height: 80,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      gradient: LinearGradient(
                        colors: isEnabled
                            ? [
                                Colors.blueAccent,
                                Colors.blue.shade600,
                                Colors.blue.shade900,
                              ]
                            : [Colors.grey.shade400, Colors.grey.shade600],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      onPressed: isEnabled
                          ? () async {
                              if (!prov.isEmployeeConfirmationValid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("CONFIRM TIDAK SAMA"),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              final navigator =
                                  Navigator.of(context, rootNavigator: true);

                              final success =
                                  await prov.updatePendingWorkdayOver(
                                idPending: int.parse(widget.idPending),
                                idEmployee: prov.confirmedEmployee.idEmployee,
                              );

                              if (!mounted) return;
                              // 🔥 TAMBAHAN: refresh list-nya di sini, gak gantung ke pop chain
                              if (success) {
                                await prov.fetchPending(widget.idProses);
                              }

                              if (!mounted) return;

                              widget.onSuccess?.call(success);
                              navigator.pop(success);
                            }
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Row 2: CONTINUE NEW OPERATOR ──────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 70,
          child: buildCustomButton(
            text: 'CONTINUE NEW OPERATOR',
            height: 70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            gradient: LinearGradient(
              colors: [
                Colors.orangeAccent,
                Colors.orange.shade700,
                Colors.deepOrange.shade900,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            onPressed: () {
              setState(() {
                _showNewOperatorForm = true; // ← ganti konten
              });
            },
          ),
        ),
      ],
    );
  }

  // ================= NEW OPERATOR FORM =================

  Widget _buildNewOperatorForm(PendingProvider prov) {
    final data = prov.pendingDetail.first;
    final ngProvider = context.watch<NGProvider>();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ─────────────────────────────────────────────

            _container(
              height: 80,
              child: AnimatedTextKit(
                repeatForever: true,
                pause: const Duration(seconds: 3),
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
                animatedTexts: [
                  TyperAnimatedText(
                    '📢 Scan QRCode ID Card Employee untuk operator baru',
                    speed: const Duration(milliseconds: 100),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),
                  FadeAnimatedText(
                    '📢 Jangan lupa input qty Shoot last operator',
                    duration: const Duration(seconds: 10),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  ColorizeAnimatedText(
                    '💡 Jangan lupa input data NG last Operator jika ada!',
                    speed: const Duration(milliseconds: 50),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    colors: const [
                      Colors.cyanAccent,
                      Colors.lightGreenAccent,
                      Colors.yellowAccent,
                      Colors.white,
                    ],
                  ),
                  TyperAnimatedText(
                    '🫶 Tetap jaga kualitas Molding!',
                    speed: const Duration(milliseconds: 100),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            _buildHeader(prov),
            const SizedBox(height: 5),

            // ── MAIN CONTENT ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── FOTO OPERATOR + INFO ─────────────────────────

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.20,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.18,
                              height: MediaQuery.of(context).size.width * 0.18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _scannedEmployeeId.isNotEmpty
                                        ? Colors.orange.shade100
                                            .withValues(alpha: 0.3)
                                        : Colors.grey.shade300
                                            .withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _scannedEmployeeId.isNotEmpty
                                        ? Colors.orange.shade300
                                            .withValues(alpha: 0.4)
                                        : Colors.grey.shade400
                                            .withValues(alpha: 0.3),
                                    spreadRadius: 4,
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: _scannedEmployeeId.isNotEmpty
                                    ? Image.network(
                                        "${AppConfig.baseUrl}/media/img/employee/$_scannedEmployeeId.png",
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.16,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.16,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                          Icons.person,
                                          size: 70,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.16,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.16,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.person,
                                          size: 70,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _scannedEmployeeName.isEmpty
                              ? 'OPERATOR NAME'
                              : _scannedEmployeeName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _scannedEmployeeId.isEmpty
                              ? 'ID SAP'
                              : _scannedEmployeeId,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        Text(
                          _scannedEmployeeSection.isEmpty
                              ? 'Section'
                              : _scannedEmployeeSection.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        Text(
                          _scannedEmployeeDivision.isEmpty
                              ? 'Division'
                              : _scannedEmployeeDivision,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        // ── BUTTON SCAN QR ─────────────────────────

                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.blue.shade900,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                final code = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MobileScannerPage(),
                                  ),
                                );

                                if (!mounted) return;

                                // ── VALIDASI HASIL SCAN ─────────────────────────────
                                if (code == null ||
                                    code.isEmpty ||
                                    code == '-1') {
                                  return;
                                }

                                // ── VALIDASI FORMAT ID EMPLOYEE ────────────────────
                                if (code.length != 8) {
                                  CustomSnackbar.show(
                                    context,
                                    'QRCode bukan ID Employee',
                                    isSuccess: false,
                                  );
                                  return;
                                }

                                // ── VALIDASI TIDAK BOLEH SCAN OPERATOR YANG SAMA ──
                                if (code == data.idEmployee) {
                                  CustomSnackbar.show(
                                    context,
                                    'Operator baru tidak boleh sama dengan operator sebelumnya',
                                    isSuccess: false,
                                  );
                                  return;
                                }

                                final employeeProv =
                                    context.read<EmployeeProvider>();

                                final success =
                                    await employeeProv.scanEmployee(code);

                                if (!mounted) return;

                                if (success) {
                                  setState(() {
                                    _scannedEmployeeId =
                                        employeeProv.employee.idEmployee;

                                    _scannedEmployeeName =
                                        employeeProv.employee.fullName;

                                    _scannedEmployeeSection =
                                        employeeProv.employee.section;

                                    _scannedEmployeeDivision =
                                        employeeProv.employee.division;
                                  });
                                } else {
                                  CustomSnackbar.show(
                                    context,
                                    employeeProv.errorMessage ?? 'Scan gagal',
                                    isSuccess: false,
                                  );
                                }
                              },
                              child: const Icon(
                                Icons.qr_code_scanner,
                                size: 55,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ── RIGHT : DETAIL & FORM ───────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── TABLE INFORMASI ─────────────────

                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(4),
                            1: FlexColumnWidth(6),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            for (int i = 0; i < 8; i++)
                              TableRow(
                                decoration: BoxDecoration(
                                  color: i.isEven
                                      ? Colors.grey.shade200
                                      : Colors.white,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      [
                                        'JOB NUMBER',
                                        'DRAW NO',
                                        'MACHINE',
                                        'QTY',
                                        'TIME STOP',
                                        'PENDING REASON',
                                        'STOP DURATION',
                                        'NEW OPERATOR',
                                      ][i],
                                      style: GoogleFonts.poppins(
                                        fontWeight: i == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: i == 7

                                        // ── ROW OPERATOR ─────────
                                        ? Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _scannedEmployeeId.isNotEmpty
                                                      ? ": $_scannedEmployeeName"
                                                      : ": BELUM SCAN",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: _scannedEmployeeId
                                                            .isNotEmpty
                                                        ? Colors.green
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                              if (_scannedEmployeeId.isNotEmpty)
                                                Row(
                                                  children: const [
                                                    Text(
                                                      "READY",
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 18,
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          )

                                        // ── NORMAL ROW ───────────
                                        : Text(
                                            [
                                              ": ${data.jobnumber}",
                                              ": ${data.drawingNumber}",
                                              ": ${data.machineName}",
                                              ": ${data.qty}",
                                              ": ${formatDateTime(data.startPending)}",
                                              ": ${data.reason}",
                                              ": ${getStopDuration(data.startPending)}",
                                            ][i],
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: i == 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: i == 5
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 70,
                                child: OutlinedButton(
                                  onPressed: _resetNewOperatorForm,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                    side: BorderSide(
                                      color: Colors.red.shade700,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'BACK',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildCustomButton(
                                text: 'SUBMIT',
                                height: 70,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: _scannedEmployeeId.isNotEmpty
                                      ? [
                                          Colors.blueAccent,
                                          Colors.blue.shade900,
                                        ]
                                      : [
                                          Colors.grey.shade400,
                                          Colors.grey.shade600,
                                        ],
                                ),
                                onPressed: _scannedEmployeeId.isEmpty ||
                                        _qtyShootController.text.isEmpty
                                    ? null
                                    : () async {
                                        final overlay = Overlay.of(context);

                                        try {
                                          final data = prov.pendingDetail.first;

                                          final success = await prov
                                              .continueWorkdayOverNewOperator(
                                            idRecord: data.idRecord,
                                            idEmployeeLama: data.idEmployee,
                                            idEmployeeBaru: _scannedEmployeeId,
                                            qtyShoot: int.parse(
                                                _qtyShootController.text),
                                            ngData: _addedNgItems,
                                          );

                                          if (!mounted) return;

                                          if (success) {
                                            widget.onSuccess?.call(true);

                                            CustomSnackbar.showWithOverlay(
                                              overlay,
                                              "Continue process berhasil",
                                              isSuccess: true,
                                            );

                                            // ✅ CLOSE DIALOG + RETURN TRUE
                                            Navigator.pop(context, true);
                                          }
                                        } catch (e) {
                                          if (!mounted) return;

                                          CustomSnackbar.showWithOverlay(
                                            overlay,
                                            "Error: $e",
                                            isSuccess: false,
                                          );
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ── SECTION QTY SHOOT + NG ─────────────────────────────────────

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── QTY SHOOT ───────────────────────────────────────────

                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ADD QTY SHOOT & QTY NG FOR ',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey.shade700,
                            letterSpacing: 0.4,
                          ),
                        ),

                        // Employee Name dengan gradient
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.orangeAccent,
                                Colors.deepOrange.shade900,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: Text(
                              data.employeeName.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _qtyShootController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // ← hanya angka
                      NoLeadingZeroFormatter(), // ← tidak boleh mulai 0
                    ],
                    decoration: InputDecoration(
                      hintText: 'Input Qty Shoot',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.normal,
                        fontSize: 13,
                      ),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── NG ROW ───────────────────────────────────────────────

                  // ── 1 ROW: Dropdown + (-) + QtyNG + (+) + ADD ───────────

                  Row(
                    children: [
                      // Dropdown NG Name

                      Expanded(
                        flex: 4,
                        child: DropdownSearch<NgDropdownModel>(
                          items: (f, cs) => ngProvider.listNG,
                          itemAsString: (NgDropdownModel? item) =>
                              item?.ngName ?? '',
                          compareFn: (a, b) => a.idNg == b.idNg,
                          selectedItem: ngProvider.listNG
                                  .where(
                                    (e) => e.idNg == _selectedNgId,
                                  )
                                  .isNotEmpty
                              ? ngProvider.listNG.firstWhere(
                                  (e) => e.idNg == _selectedNgId,
                                )
                              : null,
                          onChanged: (NgDropdownModel? selected) {
                            if (selected == null) return;

                            setState(() {
                              _selectedNgId = selected.idNg;
                              _selectedNgName = selected.ngName;
                            });

                            logPrint(
                              'Selected NG : ${selected.idNg} - ${selected.ngName}',
                            );
                          },
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                              hintText: "PILIH NG",
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 14,
                              ),
                            ),
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            fit: FlexFit.loose,
                            containerBuilder: (context, popupWidget) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).padding.bottom +
                                          20,
                                ),
                                child: popupWidget,
                              );
                            },
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: "Search NG",
                                prefixIcon: const Icon(Icons.search),
                                border: const OutlineInputBorder(),
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                ),
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                              ),
                            ),
                            itemBuilder:
                                (context, item, isDisabled, isSelected) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                constraints: const BoxConstraints(
                                  minHeight: 75,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.indigoAccent,
                                      Colors.indigo.shade900,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  dense: false,
                                  title: Text(
                                    item.ngName,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context, item);
                                  },
                                ),
                              );
                            },
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.70,
                              minWidth:
                                  MediaQuery.of(context).size.width * 0.80,
                            ),
                            scrollbarProps: const ScrollbarProps(
                              thumbVisibility: true,
                              trackVisibility: true,
                            ),
                            menuProps: const MenuProps(
                              margin: EdgeInsets.only(top: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Button Decrease (-)
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.red.shade500,
                            shape: const CircleBorder(),
                          ),
                          onPressed: () {
                            setState(() {
                              if (_qtyNg > 0) _qtyNg--;
                            });
                          },
                          child: const Icon(Icons.remove,
                              size: 18, color: Colors.white),
                        ),
                      ),

                      const SizedBox(width: 4),

                      // TextField QTY NG
                      // Text QTY NG
                      Container(
                        width: 55,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _qtyNg.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),

                      const SizedBox(width: 4),

                      // Button Increase (+)
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.green,
                            shape: const CircleBorder(),
                          ),
                          onPressed: () {
                            setState(() {
                              _qtyNg++;
                            });
                          },
                          child: const Icon(Icons.add,
                              size: 18, color: Colors.white),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Button ADD
                      SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          onPressed: () {
                            if (_selectedNgId == null) {
                              CustomSnackbar.show(
                                context,
                                'Pilih NG terlebih dahulu',
                                isSuccess: false,
                              );
                              return;
                            }

                            if (_qtyNg <= 0) {
                              CustomSnackbar.show(
                                context,
                                'QTY NG harus lebih dari 0',
                                isSuccess: false,
                              );
                              return;
                            }

                            setState(() {
                              final existingIndex = _addedNgItems.indexWhere(
                                (item) =>
                                    item['id_ng'].toString() == _selectedNgId,
                              );

                              if (existingIndex != -1) {
                                _addedNgItems[existingIndex]['qty'] =
                                    (_addedNgItems[existingIndex]['qty']
                                            as int) +
                                        _qtyNg;
                              } else {
                                _addedNgItems.add({
                                  'id_ng': _selectedNgId,
                                  'ng_name': _selectedNgName,
                                  'qty': _qtyNg,
                                });
                              }

                              _selectedNgId = null;
                              _selectedNgName = null;
                              _qtyNg = 0;
                            });
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.blueAccent,
                                  Colors.blue.shade900,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'ADD',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  // ── TABEL NG YANG SUDAH DI-ADD ──────────────────────────
                  if (_addedNgItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(5),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(1),
                        },
                        children: [
                          // Header

                          TableRow(
                            children: [
                              // NG NAME
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blueAccent,
                                      Colors.blue.shade900,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'NG NAME',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              // QTY
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blueAccent,
                                      Colors.blue.shade900,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Text(
                                  'QTY',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              // ACTION
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blueAccent,
                                      Colors.blue.shade900,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'ACTION',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          // Rows
                          ..._addedNgItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final rowColor = index.isEven
                                ? Colors.grey.shade100
                                : Colors.white;

                            return TableRow(
                              decoration: BoxDecoration(
                                color: rowColor,
                              ),
                              children: [
                                // NG NAME
                                Container(
                                  height: 48,
                                  alignment: Alignment.centerLeft,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    item['ng_name'] ?? '-',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // QTY
                                Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${item['qty']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // DELETE BUTTON
                                Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red.shade400,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _addedNgItems.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _container({required Widget child, double? height}) {
    return LayoutBuilder(// Gunakan LayoutBuilder untuk tahu ruang tersedia
        builder: (context, constraints) {
      return Container(
        height: height ?? 80,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // Perlebar padding horizontal
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orangeAccent,
              Colors.orange.shade600, // 🔥 warna tengah
              Colors.orange.shade900,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 5,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Center(
          child: FittedBox(
            // Memastikan teks selalu muat dalam satu baris
            fit: BoxFit.scaleDown,
            child: child,
          ),
        ),
      );
    });
  }
}

// Taruh di luar class, atau di file utils terpisah
class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Kosong — boleh
    if (text.isEmpty) return newValue;

    // Tidak boleh mulai dari 0
    if (text.startsWith('0')) return oldValue;

    // Hanya angka
    if (!RegExp(r'^[0-9]+$').hasMatch(text)) return oldValue;

    return newValue;
  }
}
