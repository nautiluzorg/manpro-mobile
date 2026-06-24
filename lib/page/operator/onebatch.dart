import 'package:flutter/material.dart';
// import 'package:flutter_provider_data/model/employee_model.dart';
import 'package:flutter_provider_data/model/job_row_model.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

class OneBatch extends StatefulWidget {
  final String title;
  final String idProses;

  const OneBatch({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<OneBatch> createState() => _OneBatchState();
}

class _OneBatchState extends State<OneBatch>
    with SingleTickerProviderStateMixin {
  double actionButtonHeight(bool isTablet) => isTablet ? 80 : 72;
  double fieldHeight(bool isTablet) => isTablet ? 48 : 48;

  late AnimationController _glowController;
  // EmployeeModel? selectedEmployeeItem;
  final TextEditingController prosesCtrl = TextEditingController();
  final TextEditingController machineCtrl = TextEditingController();
  final TextEditingController employeeCtrl = TextEditingController();
  final TextEditingController jobNumberCtrl = TextEditingController();
  final TextEditingController drawNumberCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();

  @override
  void dispose() {
    // Dispose semua TextEditingController

    // Kembalikan semua orientasi
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _glowController.dispose();

    super.dispose(); // jangan lupa panggil super.dispose()
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  void resetForm() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;
    final paddingTop = mq.padding.top;
    final isTablet = width > 600;

    final appBar = customSubAppBar(
      context: context,
      title: 'RECORD PROSES',
      kode: widget.idProses,
      proses: "MOULDING",
      navigateToBuilder: (kode, proses) => Menu(kode: kode, proses: proses),
    );
    final heightBody = height - paddingTop - appBar.preferredSize.height;

    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade50,
              Colors.grey.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 6 : 4),
          child: _buildBody(
            width: width,
            heightBody: heightBody,
            isTablet: isTablet,
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required double width,
    required double heightBody,
    required bool isTablet,
  }) {
    return Column(
      children: [
        _buildWarningBanner(),
        const SizedBox(height: 5),
        _buildEmployeeAndJobInfo(width, heightBody, isTablet),
        const SizedBox(height: 5),
        _buildFormGrid(width, heightBody, isTablet),
        const SizedBox(height: 5),
        _buildActionButtons(width, heightBody, isTablet),
        const SizedBox(height: 5),
        _buildFormWithButton(width, heightBody, false),
        const SizedBox(height: 5),
        _buildDataTableWithDummy(heightBody),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildWarningBanner() {
    final style = GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    return _container(
      child: AnimatedTextKit(
        repeatForever: true,
        animatedTexts: [
          _warningText(
            'Please be carefully for all process record...',
            [Colors.red, Colors.orange, Colors.yellow],
            style,
          ),
          _warningText(
            'Keep spirit for get good result..',
            [Colors.yellow, Colors.orange, Colors.red],
            style,
          ),
          _warningText(
            'Check all Progress carefully..',
            [Colors.yellow, Colors.orange, Colors.red],
            style,
          ),
        ],
      ),
    );
  }

  TyperAnimatedText _warningText(
    String text,
    List<Color> colors,
    TextStyle base,
  ) {
    return TyperAnimatedText(
      text,
      textStyle: base.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(colors: colors)
              .createShader(const Rect.fromLTWH(0, 0, 300, 70)),
      ),
    );
  }

  Widget _container({required Widget child, double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height ?? 80,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigoAccent,
                Colors.indigo.shade900,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withAlpha(90),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildEmployeeAndJobInfo(
    double width,
    double heightBody,
    bool isTablet,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: width,
      height: heightBody * 0.28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withAlpha(140),
                  Colors.indigo.shade700.withAlpha(12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.white.withAlpha(80),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildEmployeeCard(isTablet)),
                VerticalDivider(
                  width: 28,
                  thickness: 1,
                  color: Colors.white.withAlpha(50),
                ),
                Expanded(flex: 7, child: _buildJobInfoTable(isTablet)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormGrid(
    double width,
    double heightBody,
    bool isTablet,
  ) {
    final double rowHeight = fieldHeight(isTablet) + 8;

    return Container(
      width: width,
      height: rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: _surfaceDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildProcessDropdown(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildCustomTextField(
              controller: machineCtrl,
              label: 'MACHINE',
              hint: 'SCAN MACHINE',
              icon: Icons.qr_code_scanner,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildCustomTextField(
              controller: employeeCtrl,
              label: 'EMPLOYEE',
              hint: 'SCAN EMPLOYEE',
              icon: Icons.qr_code_scanner,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double width, double heightBody, bool isTablet) {
    final buttonHeight = actionButtonHeight(isTablet);

    return ClipRRect(
      borderRadius: BorderRadius.circular(isTablet ? 14 : 18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: width,

          // 🔥 FIX UTAMA DI SINI
          height: buttonHeight + 16, // padding atas + bawah

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withAlpha(160),
                Colors.white.withAlpha(100),
              ],
            ),
            border: Border.all(
              color: Colors.white.withAlpha(120),
            ),
          ),
          child: Center(
            // 🔥 biar button benar-benar center
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  'SUBMIT',
                  [Colors.blueAccent, Colors.indigo],
                  width: 300,
                  height: buttonHeight,
                  onPressed: () {},
                ),
                _outlineButton(
                  'CLEAR',
                  resetForm,
                  width: 300,
                  height: buttonHeight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _surfaceDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      gradient: LinearGradient(
        colors: [
          Colors.white.withAlpha(190),
          Colors.white.withAlpha(130),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: Colors.white.withAlpha(90),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(
    bool isTablet, {
    String? photoUrl, // ← dari API
  }) {
    final double radius = isTablet ? 50 : 32;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// ===== AVATAR GLASS RING =====
        ClipRRect(
          borderRadius: BorderRadius.circular(radius + 10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withAlpha(140),
                    Colors.white.withAlpha(20),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withAlpha(160),
                ),
              ),
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.blue.shade800.withAlpha(160),
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: isTablet ? 40 : 32,
                        color: Colors.white.withAlpha(200),
                      )
                    : null,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// ===== NAME =====
        Text(
          'EMPLOYEE NAME',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        /// ===== BADGES =====
        _employeeBadge('123456', fontSize: 10),
        _employeeBadge('METAL PILL', fontSize: 12),
        _employeeBadge('PRODUCTION', fontSize: 14),
      ],
    );
  }

  Widget _employeeBadge(
    String value, {
    double fontSize = 12,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withAlpha(30),
            Colors.white.withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white.withAlpha(40),
          width: 0.8,
        ),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInfoTable(bool isTablet) {
    final label = GoogleFonts.poppins(
      fontSize: isTablet ? 16 : 12,
      fontWeight: FontWeight.w600,
      color: Colors.white, // FULL WHITE
      shadows: [
        Shadow(
          color: Colors.black.withAlpha(140),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );

    final value = GoogleFonts.poppins(
      fontSize: isTablet ? 16 : 12,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      shadows: [
        Shadow(
          color: Colors.black.withAlpha(160),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );

    Widget row(String l, String v) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3, // 🔥 lebar label
              child: Text(l, style: label),
            ),
            const SizedBox(width: 8),
            Text(':', style: label),
            const SizedBox(width: 8),
            Expanded(
              flex: 7,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withAlpha(80),
                  ),
                ),
                child: Text(v, style: value),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JOB INFORMATION',
          style: GoogleFonts.poppins(
            fontSize: isTablet ? 18 : 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withAlpha(140),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        row('DATE TIME', '14:00 22-04-2025'),
        row('PROCESS', 'OVEN'),
        row('OPERATOR', 'VASCO VARRA'),
        row('MACHINE', 'MACHINE 01'),
        row('SHIFT', 'SHIFT 2'),
      ],
    );
  }

  //area dropdown process
  Widget _buildProcessDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: _showProcessBottomSheet,
        child: AbsorbPointer(
          child: TextField(
            controller: prosesCtrl,
            readOnly: true,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'PROCESS',
              hintText: 'SELECT PROCESS',
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blueGrey.shade900,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12, // 🔥 samakan dengan _buildCustomTextField
              ),
              prefixIcon: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade300,
                      Colors.blue.shade900,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.grey.shade500,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  onPressed: null,
                  icon: const Icon(Icons.assignment,
                      size: 20, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ),
      ),
    );
  }

  void _showProcessBottomSheet() {
    final List<String> processes = [
      'OVEN',
      'OY',
      'SPRAY',
    ];

    // 🔹 Gradient tunggal untuk semua item
    final LinearGradient itemGradient = LinearGradient(
      colors: [
        Colors.blueAccent,
        Colors.blue.shade900,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withAlpha(220),
                    Colors.white.withAlpha(180),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HANDLE
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  /// TITLE
                  Text(
                    'SELECT PROCESS',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// LIST PROCESS
                  Expanded(
                    child: ListView.separated(
                      itemCount: processes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) {
                        final process = processes[i];
                        final selected = prosesCtrl.text == process;

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setState(() {
                              prosesCtrl.text = process;
                            });
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              gradient: itemGradient,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? Colors.blueGrey.shade200
                                    : Colors.transparent,
                                width: selected ? 1.6 : 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                /// TEXT
                                Expanded(
                                  child: Text(
                                    process,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                /// SELECTED MARK
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: selected ? 1 : 0,
                                  child: Text(
                                    'SELECTED',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton(
    String title,
    List<Color> colors, {
    required VoidCallback onPressed,
    double? width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.black.withAlpha(40),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withAlpha(90),
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26, // ⬆️ sedikit naik biar balance
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlineButton(
    String title,
    VoidCallback onPressed, {
    double? width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: Colors.blue.shade500,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 26,
              letterSpacing: 1.2,
              color: Colors.blueAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormWithButton(double width, double heightBody, bool isTablet) {
    final double rowHeight = fieldHeight(isTablet) + 8;

    return Consumer<JobNumberProvider>(
      builder: (context, prov, _) {
        // 🔥 AUTO UPDATE TEXTFIELD DARI PROVIDER

        return Container(
          width: width,
          height: rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: _surfaceDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 JOBNUMBER

              Expanded(
                child: _buildCustomTextField(
                  controller: jobNumberCtrl,
                  label: 'JOBNUMBER',
                  hint: 'SCAN JOBNUMBER',
                  icon: Icons.qr_code_scanner,
                  onIconTap: () async {
                    final qrCode = await Navigator.push<String?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MobileScannerPage(),
                      ),
                    );

                    if (qrCode == null || qrCode.isEmpty) return;

                    try {
                      await prov.scanJobNumberSimple(qrCode: qrCode);

                      // 🔥 HANYA jobnumber yang pakai controller
                      jobNumberCtrl.text = prov.jobNumber;
                    } catch (e) {
                      CustomSnackbar.show(
                        context,
                        e.toString(),
                        isSuccess: false,
                      );
                    }
                  },
                ),
              ),

              const SizedBox(width: 8),

              // 🔹 DRAW NO

              Expanded(
                child: TextFormField(
                  key: ValueKey(prov.drawNumber), // 🔥 penting agar rebuild
                  initialValue: prov.drawNumber,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'DRAW NO',
                    hintText: 'DRAW NO',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blueGrey.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: TextFormField(
                  key: ValueKey(prov.qtyLot), // reset saat scan baru
                  initialValue:
                      prov.qtyActual.isNotEmpty ? prov.qtyActual : prov.qtyLot,
                  readOnly: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.startsWith('0') &&
                          newValue.text.length > 1) {
                        return oldValue;
                      }
                      return newValue;
                    }),
                  ],
                  onChanged: (value) {
                    prov.setQtyActual(value); // 🔥 INI KUNCI UTAMA
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'QTY',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              SizedBox(
                height: fieldHeight(isTablet),
                width: 90,
                child: _compactSubmitButton(
                  enabled: prov.isJobNumberScanned,
                  onPressed: () {
                    try {
                      prov.addCurrentJobToTable();
                      jobNumberCtrl.clear();
                    } catch (e) {
                      CustomSnackbar.show(
                        context,
                        e.toString(),
                        isSuccess: false,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _compactSubmitButton({
    required VoidCallback? onPressed,
    bool enabled = true,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black45,
        elevation: enabled ? 4 : 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity, // 🔥 AMAN
        child: Ink(
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    colors: [
                      Colors.blueAccent,
                      Colors.blue.shade900,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.shade400,
                      Colors.grey.shade600,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.white.withAlpha(60),
              width: 0.8,
            ),
          ),
          child: const Center(
            child: Text(
              'ADD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    bool readOnly = true,
    VoidCallback? onIconTap,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    final bool hasPrefixIcon = icon != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType:
            inputFormatters != null ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          filled: true, // 🔥 KUNCI
          fillColor: Colors.white, //
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.blueGrey.shade900,
            fontWeight: FontWeight.w500,
          ),
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),

          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),

          prefixIcon: hasPrefixIcon
              ? Container(
                  width: 36,
                  height: 36,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade300,
                        Colors.blue.shade900,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade500,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    onPressed: onIconTap,
                    icon: Icon(icon, size: 20, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                )
              : null,
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDataTableWithDummy(double heightBody) {
    return Consumer<JobNumberProvider>(
      builder: (context, prov, _) {
        final List<JobRowModel> data = prov.rows;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: heightBody * 0.6,
            width: double.infinity,
            decoration: _surfaceDecoration(),
            padding: const EdgeInsets.all(5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth;

                return Stack(
                  children: [
                    // 🔹 Background gradient header
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      height: 46,
                      child: Container(
                        width: tableWidth,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigoAccent,
                              Colors.indigo.shade900
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    // 🔹 DataTable
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 28,
                        headingRowHeight: 44,
                        dataRowMinHeight: 40,
                        dataRowMaxHeight: 44,
                        headingRowColor:
                            WidgetStateProperty.all(Colors.transparent),
                        columns: const [
                          DataColumn(
                            label: SizedBox(
                              width: 25,
                              child: Text(
                                'NO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'JOBNUMBER',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'LOT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 145,
                              child: Text(
                                'DRAWING NO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'QTY LOT ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'QTY ACTUAL',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 140,
                              child: Center(
                                child: Text(
                                  'ACTION',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'DATE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CATEGORY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'TYPE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'STATUS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CUSTOMER',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: List<DataRow>.generate(
                          data.length,
                          (index) {
                            final JobRowModel row = data[index];

                            const double btnHeight = 32;
                            const double btnWidth = 65;
                            const double btnRadius = 6;

                            return DataRow(
                              color: WidgetStateProperty.all(
                                index % 2 == 0
                                    ? Colors.blueGrey.shade50
                                    : Colors.white,
                              ),
                              cells: [
                                DataCell(
                                  SizedBox(width: 25, child: Text(row.no)),
                                ),
                                DataCell(Text(row.jobNumber)),
                                DataCell(Text(row.lot)),
                                DataCell(SizedBox(
                                    width: 135, child: Text(row.drawingNo))),
                                DataCell(Text(row.qtyLot)),
                                DataCell(Text(row.quantity)),
                                DataCell(
                                  SizedBox(
                                    width: 140,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // 🔴 ADD NG
                                        SizedBox(
                                          width: btnWidth,
                                          height: btnHeight,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(
                                                  btnWidth, btnHeight),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        btnRadius),
                                                side: const BorderSide(
                                                  color: Colors.red,
                                                  width: 1.2,
                                                ),
                                              ),
                                              foregroundColor: Colors.red,
                                            ),
                                            onPressed: () {},
                                            child: const Center(
                                              child: Text(
                                                'ADD NG',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),

                                        // 🗑 DELETE
                                        SizedBox(
                                          width: btnWidth,
                                          height: btnHeight,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(
                                                  btnWidth, btnHeight),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        btnRadius),
                                              ),
                                            ),
                                            onPressed: () {
                                              prov.removeRowAt(index);
                                              // prov.removeByJobNumber(row.jobNumber);
                                            },
                                            child: Ink(
                                              width: btnWidth,
                                              height: btnHeight,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.redAccent,
                                                    Colors.red.shade900,
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        btnRadius),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(Text(row.date)),
                                DataCell(Text(row.category)),
                                DataCell(Text(row.type)),
                                DataCell(Text(row.status)),
                                DataCell(Text(row.customer)),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
