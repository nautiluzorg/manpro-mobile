import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/technician/record_chocotei/dialogs/action_picker_dialog.dart';
import 'package:flutter_provider_data/page/technician/record_chocotei/model/action_record.dart';
import 'package:flutter_provider_data/page/technician/record_chocotei/widgets/dynamic_action_table_view.dart';
import 'package:flutter_provider_data/page/technician/record_chocotei/widgets/record_action_buttons.dart';
import 'package:flutter_provider_data/page/technician/record_chocotei/widgets/record_form_grid.dart';
import 'package:flutter_provider_data/page/technician/record_chocotei/widgets/record_info_panel.dart';
// import 'package:flutter_provider_data/page/technician/record_chocotei/widgets/record_machine_info_table.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';

class RecordChocotei extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordChocotei({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<RecordChocotei> createState() => _RecordChocoteiState();
}

class _RecordChocoteiState extends State<RecordChocotei>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final TextEditingController mixLotNumberController = TextEditingController();
  final TextEditingController idEmployeeController = TextEditingController();
  final TextEditingController goldPillController = TextEditingController();
  final TextEditingController carbonPillController = TextEditingController();
  final TextEditingController idMachineController = TextEditingController();
  final TextEditingController jobNumberController = TextEditingController();
  final TextEditingController qtyActualController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController actionController = TextEditingController();
  final List<ActionRecord> _selectedActions = [];

  @override
  void initState() {
    super.initState();

    // Semua provider form bersifat global. Reset setelah frame pertama agar
    // notifyListeners() tidak dipanggil ketika widget masih sedang build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<JobNumberProvider>().clearAll(context, qtyActualController);
      context.read<NGProvider>().clearAll();
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  Future<void> _scanEmployee() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );

    if (!mounted || code == null || code.trim().isEmpty || code == '-1') {
      return;
    }

    final employeeProvider = context.read<EmployeeProvider>();
    final success = await employeeProvider.scanEmployee(code.trim());

    if (!mounted) return;

    if (!success) {
      CustomSnackbar.show(
        context,
        employeeProvider.errorMessage ?? 'Employee tidak ditemukan.',
        isSuccess: false,
      );
      return;
    }

    // Dipakai kembali saat submit record.
    idEmployeeController.text = employeeProvider.employee.idEmployee;
  }

  String _nextActionCode(String parentCode) {
    var nextNumber = 1;

    while (_selectedActions.any(
      (action) => action.code == '$parentCode.$nextNumber',
    )) {
      nextNumber++;
    }

    return '$parentCode.$nextNumber';
  }

  @override
  void dispose() {
    // Dispose semua TextEditingController
    mixLotNumberController.dispose();
    idEmployeeController.dispose();
    goldPillController.dispose();
    carbonPillController.dispose();
    idMachineController.dispose();
    jobNumberController.dispose();
    qtyActualController.dispose();

    problemController.dispose();
    actionController.dispose();

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
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    double heightApp = MediaQuery.of(context).size.height;
    double paddingTop = MediaQuery.of(context).padding.top;

    // bool isTablet = widthApp > 600;
    double screenWidth = MediaQuery.of(context).size.width;

    final myAppBar = customSubAppBar(
      context: context,
      title: 'RECORD CHOCOTEI',
      kode: widget.idProses,
      proses: "MOLDING",
      navigateToBuilder: (kode, proses) => Menu(kode: kode, proses: proses),
    );

    double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

// Deklarasi controller satu per satu

    return Scaffold(
      appBar: myAppBar,

      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            5.0,
            5.0,
            5.0,
            MediaQuery.of(context).padding.bottom + 32.0,
          ),
          scrollDirection: Axis.vertical,
          child: Column(children: [
            _container(
              height: 80,
              child: AnimatedTextKit(
                repeatForever: true,
                pause: const Duration(seconds: 3),
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
                animatedTexts: [
                  TyperAnimatedText(
                    '🚀 Fokus dan presisi adalah kunci sukses produksi hari ini!',
                    speed: const Duration(milliseconds: 100),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),
                  FadeAnimatedText(
                    '📢 Pastikan data yang diinput sesuai dengan hasil produksi',
                    duration: const Duration(seconds: 5),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  ColorizeAnimatedText(
                    '💡 Jaga konsistensi & ketelitian karena kualitas dimulai dari sini!',
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
                  FadeAnimatedText(
                    '🔥 Semangat! Proses Molding bagian penting kualitas produk',
                    duration: const Duration(seconds: 4),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  TyperAnimatedText(
                    '🫶 Jaga kualitas, jaga kebanggaan tim Molding!',
                    speed: const Duration(milliseconds: 100),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5.0),

            RecordInfoPanel(
              heightBody: heightBody,
              widthApp: widthApp,
              qtyActualController: qtyActualController,
              onScanEmployee: _scanEmployee,
            ),

            SizedBox(height: 5.0),

            RecordFormGrid(
              idProses: widget.idProses,
              idMachineController: idMachineController,
              jobNumberController: jobNumberController,
              problemController: problemController,
              actionController: actionController,
              onBuildTextField: _buildTextField, // method tetap di parent
            ),

            //####################BATAS CONTAINER KE 3 DISINI ######################******

            SizedBox(
              width: widthApp,
              height: heightBody * 0.1,
              child: RecordActionButtons(
                onSubmit: (ctx) async {
                  final jobProvider = ctx.read<JobNumberProvider>();
                  final ngProvider = ctx.read<NGProvider>();
                  final materialProvider = ctx.read<MaterialProvider>();
                  final machineProvider = ctx.read<MachineProvider>();

                  // Guard: sedang submit
                  if (jobProvider.isSubmitting) return;

                  // Validasi QRCode
                  if (idEmployeeController.text.isEmpty ||
                      !machineProvider.machine.isValid ||
                      mixLotNumberController.text.isEmpty) {
                    CustomSnackbar.show(ctx, "Please complete QRCode Scanning.",
                        isSuccess: false);
                    return;
                  }

                  // Validasi METAL PILL
                  if (jobProvider.productCategory == "METAL PILL") {
                    // ← pakai isValid, bukan cek id == 0
                    final goldId = materialProvider.goldPillData.isValid
                        ? materialProvider.goldPillData.id.toString()
                        : "";

                    final carbonId = materialProvider.carbonPillData.isValid
                        ? materialProvider.carbonPillData.id.toString()
                        : "";

                    if (goldId.isEmpty && carbonId.isEmpty) {
                      CustomSnackbar.show(
                        ctx,
                        "Gold Pill or Carbon Pill must be scanned!",
                        isSuccess: false,
                      );
                      return;
                    }

                    jobProvider.goldPill = goldId;
                    jobProvider.carbonPill = carbonId;
                  }

                  // ✅ Sync semua data dari controller & provider sebelum submit
                  jobProvider.idEmployee = idEmployeeController.text.trim();
                  // Field menampilkan nama mesin, tetapi payload tetap memakai ID mesin.
                  jobProvider.idMachine = machineProvider.machine.idMc;
                  jobProvider.mixLotNo =
                      materialProvider.mixLotNumber; // ← tambah ini

                  jobProvider.setSubmitting(true);

                  try {
                    final isSuccess =
                        await jobProvider.submitRecord(ngProvider, ctx);
                    if (!ctx.mounted) return;

                    CustomSnackbar.show(
                      ctx,
                      isSuccess
                          ? "Data submitted successfully!"
                          : "Failed to submit data.",
                      isSuccess: isSuccess,
                    );
                    if (isSuccess) {
                      setState(() => _selectedActions.clear());
                    }
                  } finally {
                    if (ctx.mounted) jobProvider.setSubmitting(false);
                  }
                },
                onClear: (ctx) {
                  final ngProvider = ctx.read<NGProvider>();
                  final jobProvider = ctx.read<JobNumberProvider>();
                  final qtyActualController =
                      TextEditingController(text: jobProvider.qtyActual);

                  ngProvider.clearAll();
                  setState(() => _selectedActions.clear());
                  actionController.clear();
                  jobProvider.clearAll(ctx, qtyActualController);
                  qtyActualController.clear();
                  jobProvider.setQtyActual('');
                },
                onAddAction: (ctx) async {
                  // final provider = ctx.read<JobNumberProvider>();

/*
                  if (provider.bcode.isEmpty) {
                    CustomSnackbar.show(
                        ctx, "HARAP SCAN JOBNUMBER TERLEBIH DAHULU!.",
                        isSuccess: false);
                    return;
                  }

                  if (!provider.isAvailable) {
                    CustomSnackbar.show(
                      ctx,
                      "START RECORD PROSES TIDAK BISA MENAMBAHKAN ACTION.",
                      isSuccess: false,
                    );
                    return;
                  }
                  */

                  final parentAction = actionController.text.trim();
                  if (parentAction.isEmpty) {
                    CustomSnackbar.show(
                      ctx,
                      'Pilih ACTION induk terlebih dahulu.',
                      isSuccess: false,
                    );
                    return;
                  }

                  final selectedAction = await showDialog<ActionOption>(
                    context: ctx,
                    barrierDismissible: false,
                    builder: (_) => ActionPickerDialog(
                      parentAction: parentAction,
                    ),
                  );

                  if (!mounted || !ctx.mounted || selectedAction == null) {
                    return;
                  }

                  setState(() {
                    _selectedActions.add(
                      ActionRecord(
                        parentCode: selectedAction.parentCode,
                        code: _nextActionCode(selectedAction.parentCode),
                        label: selectedAction.label,
                      ),
                    );
                  });
                },
              ),
            ),
            SizedBox(height: 5.0),

            DynamicActionTableView(
              heightBody: heightBody,
              screenWidth: screenWidth,
              actions: _selectedActions,
              onDelete: (action) {
                setState(() => _selectedActions.remove(action));
              },
              onStart: (action) {
                setState(() => action.startTime = DateTime.now());
              },
              onFinish: (action) {
                setState(() => action.finishTime = DateTime.now());
              },
            ),

/*

            RecordMachineInfoTable(
              heightBody: heightBody,
              widthApp: widthApp,
              isTablet: isTablet,
            ),
*/
          ]),
        );
      }),
      //SINGLECHILDSCROLLVIEW SAMPAI SINI
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onIconTap,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    const double fieldHeight = 65;
    const double fieldRadius = 4;
    const double innerRadius = fieldRadius - 1;
    const double iconBoxWidth = 58; // <-- lebar prefix & suffix
    const double iconSize = 30; // <-- ikut dibesarkan biar proporsional
    final bool hasPrefixIcon = icon != null;

    return TextField(
      controller: controller,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      keyboardType:
          inputFormatters != null ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(
          fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: Colors.blueGrey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),

        // ===== PREFIX ICON: GRADIENT blueAccent -> blue.shade900 =====
        prefixIcon: hasPrefixIcon
            ? Container(
                width: iconBoxWidth,
                height: fieldHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(innerRadius),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onIconTap,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(innerRadius),
                    ),
                    child: Center(
                      child: Icon(icon, size: iconSize, color: Colors.white),
                    ),
                  ),
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: iconBoxWidth,
          maxWidth: iconBoxWidth,
          minHeight: fieldHeight,
          maxHeight: fieldHeight,
        ),
        suffixIcon: suffixIcon != null
            ? Container(
                width: iconBoxWidth,
                height: fieldHeight,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(innerRadius),
                  ),
                ),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: iconBoxWidth,
          maxWidth: iconBoxWidth,
          minHeight: fieldHeight,
          maxHeight: fieldHeight,
        ),
        hintStyle: GoogleFonts.poppins(
          color: Colors.blueGrey.shade400,
          fontSize: 14.0,
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
              Colors.blueAccent,
              Colors.blue.shade600, // 🔥 warna tengah
              Colors.blue.shade900,
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
