import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/widgets/ng_table_view.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/widgets/record_action_buttons.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/widgets/record_form_grid.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/widgets/record_info_panel.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/widgets/record_machine_info_table.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/dialogs/mix_lot_dialog.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/ng_dialog/num_block_keyboard_dialog.dart';

class RecordProcess extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordProcess({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<RecordProcess> createState() => _RecordProcessState();
}

class _RecordProcessState extends State<RecordProcess>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  int sisaShoot = 0;
  final TextEditingController mixLotNumberController = TextEditingController();
  final TextEditingController idEmployeeController = TextEditingController();
  final TextEditingController goldPillController = TextEditingController();
  final TextEditingController carbonPillController = TextEditingController();
  final TextEditingController idMachineController = TextEditingController();
  final TextEditingController jobNumberController = TextEditingController();
  final TextEditingController drawNumberController = TextEditingController();
  final TextEditingController qtyLotController = TextEditingController();
  final TextEditingController moldCavityController = TextEditingController();
  final TextEditingController totalShotController = TextEditingController();
  final TextEditingController qtyActualController = TextEditingController();

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

  @override
  void dispose() {
    // Dispose semua TextEditingController
    mixLotNumberController.dispose();
    idEmployeeController.dispose();
    goldPillController.dispose();
    carbonPillController.dispose();
    idMachineController.dispose();
    jobNumberController.dispose();
    drawNumberController.dispose();
    qtyLotController.dispose();
    // moldNumberController.dispose();
    moldCavityController.dispose();
    totalShotController.dispose();
    qtyActualController.dispose();

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

    bool isTablet = widthApp > 600;
    double screenWidth = MediaQuery.of(context).size.width;

    final myAppBar = customSubAppBar(
      context: context,
      title: 'RECORD PROSES MOLDING',
      kode: widget.idProses,
      proses: "MOULDING",
      navigateToBuilder: (kode, proses) => Menu(kode: kode, proses: proses),
    );

    double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

// Deklarasi controller satu per satu

    return Scaffold(
      appBar: myAppBar,

      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(5.0),
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
            ),

            SizedBox(height: 5.0),
            RecordFormGrid(
              idProses: widget.idProses,
              mixLotNumberController: mixLotNumberController,
              idEmployeeController: idEmployeeController,
              goldPillController: goldPillController,
              carbonPillController: carbonPillController,
              idMachineController: idMachineController,
              jobNumberController: jobNumberController,
              drawNumberController: drawNumberController,
              qtyLotController: qtyLotController,
              moldCavityController: moldCavityController,
              totalShotController: totalShotController,
              qtyActualController: qtyActualController,
              onBuildTextField: _buildTextField, // method tetap di parent
              onEditMixLotNumber: (ctx) => showMixLotDialog(ctx),
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

                  // Guard: sedang submit
                  if (jobProvider.isSubmitting) return;

                  // Validasi QRCode
                  if (idEmployeeController.text.isEmpty ||
                      idMachineController.text.isEmpty ||
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
                  jobProvider.idMachine = idMachineController.text.trim();
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
                  jobProvider.clearAll(ctx, qtyActualController);
                  qtyActualController.clear();
                  jobProvider.setQtyActual('');
                },
                onAddNg: (ctx) {
                  final provider = ctx.read<JobNumberProvider>();

                  if (provider.bcode.isEmpty) {
                    CustomSnackbar.show(
                        ctx, "HARAP SCAN JOBNUMBER TERLEBIH DAHULU!.",
                        isSuccess: false);
                    return;
                  }

                  if (provider.isAvailable) {
                    _showFullScreenDialog(
                      ctx,
                      provider.idProcess,
                      provider.idEmployee,
                      provider.jobNumber,
                      provider.productType,
                      provider.idRecord,
                    );
                  } else {
                    CustomSnackbar.show(ctx,
                        "START RECORD PROSES TIDAK BISA MENAMBAHKAN DATA NG.",
                        isSuccess: false);
                  }
                },
              ),
            ),
            SizedBox(height: 5.0),

            NgTableView(
              heightBody: heightBody,
              screenWidth: screenWidth,
            ),

            SizedBox(height: 5.0),

            RecordMachineInfoTable(
              heightBody: heightBody,
              widthApp: widthApp,
              isTablet: isTablet,
            ),
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
    IconData? icon, // nullable
    bool readOnly = false,
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
        inputFormatters: inputFormatters,
        keyboardType:
            inputFormatters != null ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.poppins(
          fontSize: 13.0,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          // Gunakan widget label dengan padding bawah
          label: Padding(
            padding: const EdgeInsets.only(bottom: 6), // jarak bawah label
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: hasPrefixIcon ? 0 : 12,
            vertical: 12,
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
                    icon: Icon(
                      icon,
                      size: 20,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? Container(
                  width: 36,
                  height: 36,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.shade50,
                        Colors.blueGrey.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.blueGrey.shade300,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: suffixIcon,
                )
              : null,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
            fontSize: 14.0,
          ),
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

  //FUNCTION INPUT DIALOG (FUNCTION BARU)
  void _showFullScreenDialog(
    BuildContext context,
    String idProses,
    String idEmployee,
    String jobNumber,
    String typeProduct,
    String idRecord,
  ) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog.fullscreen(
          backgroundColor:
              Colors.transparent, // Menghilangkan latar belakang dialog
          child: FadeTransition(
            opacity: animation,
            child: NumBlockKeyboardDialog(
                idProses: idProses,
                idEmployee: idEmployee,
                jobNumber: jobNumber,
                idRecordUpdate: idRecord,
                qtyShoot: sisaShoot,
                typeProduct: typeProduct),
          ),
        );
      },
      transitionDuration: const Duration(seconds: 1), // Durasi transisi fade-in
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation, // Mengubah opasitas widget secara animasi
          child: child, // Widget anak (konten dialog fullscreen)
        );
      },
    ));
  }
}
