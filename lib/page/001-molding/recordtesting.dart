import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/machine_model_dropdown.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecordTesting extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordTesting({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<RecordTesting> createState() => _RecordTestingState();
}

class _RecordTestingState extends State<RecordTesting>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isFormInitialized = false;

  final TextEditingController mixLotNumberController = TextEditingController();
  final TextEditingController idEmployeeController = TextEditingController();
  final TextEditingController goldPillController = TextEditingController();
  final TextEditingController carbonPillController = TextEditingController();
  final TextEditingController idMachineController = TextEditingController();
  final TextEditingController jobNumberController = TextEditingController();
  final TextEditingController moldNumberController = TextEditingController();
  final TextEditingController qtyActualController = TextEditingController();
  final TextEditingController mcTempUpperCtrl = TextEditingController();
  final TextEditingController mcTempLowerCtrl = TextEditingController();
  final TextEditingController mcTempLowUpperCtrl = TextEditingController();
  final TextEditingController mcTempLowLowerCtrl = TextEditingController();
  final TextEditingController mcCuringCtrl = TextEditingController();
  final TextEditingController mcPressureCtrl = TextEditingController();
  final TextEditingController mcSettingsCtrl = TextEditingController();
  final TextEditingController noteController = TextEditingController();

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provid2 = context.watch<TestingProvider>();

    if (provid2.shouldClearMachineForm) {
      _clearFormControllers();
      provid2.acknowledgeClearMachineForm(); // reset flag
    }

    if (_isFormInitialized) return;

    if (provid2.mcTempUpper.isEmpty &&
        provid2.mcTempLower.isEmpty &&
        provid2.mcCuring.isEmpty) {
      return;
    }

    final valueUpper = provid2.mcTempUpper;
    final valueLower = provid2.mcTempLower;
    final valueCuri = provid2.mcCuring;
    final valuePressure = provid2.mcPressure;
    final valueSettings = provid2.mcSettings;

    if (valueUpper.contains('-')) {
      final parts = valueUpper.split('-');
      mcTempUpperCtrl.text = parts[0];
      mcTempLowerCtrl.text = parts[1];
    }

    if (valueLower.contains('-')) {
      final partsLow = valueLower.split('-');
      mcTempLowUpperCtrl.text = partsLow[0];
      mcTempLowLowerCtrl.text = partsLow[1];
    }

    mcCuringCtrl.text = valueCuri;
    mcPressureCtrl.text = valuePressure;
    mcSettingsCtrl.text = valueSettings;

    _isFormInitialized = true;
  }

  void _clearFormControllers() {
    mcTempUpperCtrl.clear();
    mcTempLowerCtrl.clear();
    mcTempLowUpperCtrl.clear();
    mcTempLowLowerCtrl.clear();
    mcCuringCtrl.clear();
    mcPressureCtrl.clear();
    mcSettingsCtrl.clear();

    _isFormInitialized = false;
  }

  @override
  void dispose() {
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

    final textStyle = GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    final myAppBar = customAppBar(
      context: context,
      title: 'RECORD PROSES MOLDING',
      kode: widget.idProses,
      proses: "MOULDING",
      navigateToBuilder: (kode, proses) => Menu(kode: kode, proses: proses),
    );

    double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    double conTextfieldHeight = heightBody * 0.12;

    return Scaffold(
      appBar: myAppBar,
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(2.0),
          scrollDirection: Axis.vertical,
          child: Column(children: [
            _container(
              gradient: LinearGradient(
                colors: [
                  Colors.indigoAccent,
                  Colors.indigo.shade900.withValues(alpha: 0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Check kembali setting mesin sebelum proses Molding...',
                    textStyle: textStyle.copyWith(
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.redAccent,
                            Colors.orange.shade900,
                            Colors.yellowAccent
                          ],
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                    ),
                  ),
                  TyperAnimatedText(
                    'Hati-hati, suhu dan tekanan harus sesuai standar..',
                    textStyle: textStyle.copyWith(
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.yellow.shade400, // terang dan kontras
                            Colors.orange.shade300,
                            Colors.red.shade300,
                          ],
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                    ),
                  ),
                  TyperAnimatedText(
                    'Jangan abaikan tanda abnormal pada mesin dan material!',
                    textStyle: textStyle.copyWith(
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.yellow.shade400,
                            Colors.orangeAccent,
                            Colors.red.shade500,
                          ],
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                    ),
                  ),
                ],
                repeatForever: true,
              ),
            ),

            SizedBox(height: 2.0),

            Container(
              // width: widthApp,
              height: heightBody * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEEF2FF), Color(0xFFD6E0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.grey.shade400, // garis lebih soft tapi kece
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.2),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Consumer<TestingProvider>(
                      builder: (context, provider, _) {
                        final employee = provider.employee;
                        final photoUrl = employee.isValid
                            ? "${AppConfig.baseUrl}/media/img/employee/${employee.idEmployee}.png"
                            : "${AppConfig.baseUrl}/media/img/employee/employee.png";

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blueGrey.shade200,
                                  width: 0.5,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // FOTO EMPLOYEE
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.blueGrey.shade100,
                                            width: 2.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: Image.network(
                                          photoUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // NAMA & NRP
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.all(4.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            employee.fullName.isNotEmpty
                                                ? employee.fullName
                                                : "EMPLOYEE NAME",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.blueGrey.shade900,
                                              fontSize:
                                                  constraints.maxWidth * 0.08,
                                            ),
                                          ),
                                          SizedBox(height: 1.0),
                                          Text(
                                            employee.nrp.isNotEmpty
                                                ? employee.nrp
                                                : "NRP",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueGrey.shade700,
                                              fontSize:
                                                  constraints.maxWidth * 0.06,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // DIVISI & SECTION
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.all(2.0),
                                      margin: EdgeInsets.only(bottom: 5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            employee.division.isNotEmpty
                                                ? employee.division
                                                : "DIVISION",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueGrey.shade700,
                                              fontSize:
                                                  constraints.maxWidth * 0.06,
                                            ),
                                          ),
                                          Text(
                                            employee.section.isNotEmpty
                                                ? employee.section
                                                : "SECTION",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.blueGrey.shade600,
                                              fontSize:
                                                  constraints.maxWidth * 0.05,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Container 60%
                  Expanded(
                    flex: 7,
                    child: Consumer<TestingProvider>(
                      builder: (context, provider, _) {
                        final job = provider;
                        final jobNumber =
                            job.jobNumber.isNotEmpty ? job.jobNumber : "";
                        final jobDate = provider.jobDate;
                        final jobProcess = provider.nmProses.isNotEmpty
                            ? provider.nmProses
                            : "";
                        final batchNumber = provider.batchNumber.isNotEmpty
                            ? provider.batchNumber
                            : "";
                        final drawno = provider.drawNumber.isNotEmpty
                            ? provider.drawNumber
                            : "";
                        final lotNumber = provider.lotNumber.isNotEmpty
                            ? provider.lotNumber
                            : "";
                        final totalLotNumber =
                            provider.totalLotNumber.isNotEmpty
                                ? provider.totalLotNumber
                                : "";
                        final qty = provider.qty.isNotEmpty ? provider.qty : "";
                        final categoryProduct =
                            provider.productCategory.isNotEmpty
                                ? provider.productCategory
                                : "";
                        final typeProduct = provider.productType.isNotEmpty
                            ? provider.productType
                            : "";
                        final germanSilverLn =
                            provider.goldPill?.germanSilverLotNumber ?? "";
                        final uedaUshinLn =
                            provider.goldPill?.uedaUshinLotNumber ?? "";
                        final materialLn =
                            provider.goldPill?.materialLotNumber ?? "";
                        final carbonLot =
                            provider.carbonPill?.carbonLotNumber ?? "";

                        final String moldCavity =
                            provider.selectedMoldCavity?.toString() ?? '';

                        final totalShoot = provider.totalShootQty > 0
                            ? provider.totalShootQty.toString()
                            : '';

                        final data = [
                          [
                            "DATE & TIME",
                            jobDate != null
                                ? formatDateTimeFromDateBln(jobDate)
                                : ""
                          ],
                          ["JOB NUMBER", jobNumber],
                          ["PROCESS", jobProcess],
                          ["JOBCODE", batchNumber],
                          ["LOT NUMBER", lotNumber],
                          ["MOLD CAVITY", moldCavity],
                          ["TOTAL SHOOT", totalShoot],
                          ["DRAW NUMBER", drawno],
                          ["TOTAL LOT", totalLotNumber],
                          ["QTY", qty],
                          ["CATEGORY", categoryProduct],
                          ["TYPE", typeProduct],
                          [
                            "GOLD PILL LOT NO",
                            "$germanSilverLn  $uedaUshinLn  $materialLn"
                          ],
                          ["CARBON PILL LOT NO", carbonLot],
                        ];

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: constraints.maxHeight * 1,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 10.0),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.blueGrey.shade100,
                                    width: 0.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.blueGrey.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Table(
                                  border: TableBorder(
                                    bottom: BorderSide(
                                        color: Colors.blueGrey.shade200,
                                        width: 1.0),
                                    horizontalInside: BorderSide(
                                        color: Colors.blueGrey.shade100,
                                        width: 0.5),
                                  ),
                                  columnWidths: {
                                    0: FlexColumnWidth(0.4),
                                    1: FlexColumnWidth(0.6),
                                  },
                                  children: List.generate(data.length, (index) {
                                    final rowColor = index % 2 == 0
                                        ? Colors.blueGrey.shade50
                                        : Colors.white;

                                    return TableRow(
                                      children: [
                                        Container(
                                          color: rowColor,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 6.0),
                                          child: Text(
                                            data[index][0],
                                            style: GoogleFonts.poppins(
                                              fontWeight:
                                                  data[index][0] == "JOB NUMBER"
                                                      ? FontWeight.bold
                                                      : FontWeight.w600,
                                              fontSize:
                                                  constraints.maxWidth * 0.025,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: rowColor,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 6.0),
                                          child: Text(
                                            ": ${data[index][1]}",
                                            style: GoogleFonts.poppins(
                                              fontWeight:
                                                  data[index][0] == "JOB NUMBER"
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                              fontSize:
                                                  constraints.maxWidth * 0.025,
                                              color: Colors.blueGrey.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5.0),

            Container(
              width: widthApp,
              height: conTextfieldHeight,
              padding: EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                color: Colors.blueAccent.shade100,
                border: Border.all(
                  color: Colors.grey.shade400, // Warna garis
                  width: 2.0, // Lebar garis
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                    8)), // Sudut container yang melengkung (opsional)
              ),
              child: Center(
                child: LayoutBuilder(builder: (context, constraints) {
                  int columnCount = 4;
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    alignment: Alignment.center,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 0.5, // Lebar garis
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(
                          8)), // Sudut container yang melengkung (opsional)
                    ),
                    child: Consumer<TestingProvider>(
                      builder: (context, prov, _) {
                        final String qtyTest =
                            prov.selectedMoldCavity?.toString() ?? '';

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (jobNumberController.text != prov.jobNumber) {
                            jobNumberController.text = prov.jobNumber;
                          }

                          if (mixLotNumberController.text != prov.mixLotNo) {
                            mixLotNumberController.text = prov.mixLotNo;
                          }

                          if (idMachineController.text != prov.machine.idMc) {
                            idMachineController.text = prov.machine.idMc;
                          }

                          if (idEmployeeController.text !=
                              prov.employee.idEmployee) {
                            idEmployeeController.text =
                                prov.employee.idEmployee;
                          }

                          if (qtyActualController.text != qtyTest) {
                            qtyActualController.text = qtyTest;
                          }

                          if (goldPillController.text != prov.goldPillLot) {
                            goldPillController.text = prov.goldPillLot;
                          }

                          if (carbonPillController.text != prov.carbonPillLot) {
                            carbonPillController.text = prov.carbonPillLot;
                          }
                        });

                        return Center(
                          child: GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: columnCount,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3.5,
                            shrinkWrap: true,
                            children: [
                              buildTextField(
                                controller: jobNumberController,
                                label: "Job Number",
                                hint: "Scan Job Number",
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
                                    await prov.scanJobNumber(
                                      qrCode: qrCode,
                                      idProses: widget.idProses,
                                    );
                                    // prov.debugPrintScanResult();
                                  } catch (e) {
                                    CustomSnackbar.show(
                                      context,
                                      e.toString(),
                                      isSuccess: false,
                                    );
                                  }
                                },
                                readOnly: true,
                              ),
                              buildTextField(
                                controller: mixLotNumberController,
                                label: "Mix Lot No",
                                hint: "MixLotNo",
                                icon: Icons.qr_code_scanner,
                                onIconTap: () async {
                                  if (!prov.isJobNumberScanned) {
                                    CustomSnackbar.show(
                                      context,
                                      "Mohon Scan Job Number terlebih dahulu.",
                                      isSuccess: false,
                                    );
                                    return;
                                  }

                                  try {
                                    await prov.scanMixLotNumberFromCamera(
                                        context: context);
                                    mixLotNumberController.text = prov.mixLotNo;
                                  } catch (e) {
                                    if (!mounted) return;
                                    CustomSnackbar.show(
                                      context,
                                      e.toString(),
                                      isSuccess: false,
                                    );
                                  }
                                },
                                readOnly: true,
                                inputFormatters: [MixLotFormatter()],
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.edit_note,
                                      color: Colors.grey.shade600, size: 24),
                                  onPressed: () {
                                    if (!prov.isJobNumberScanned) {
                                      CustomSnackbar.show(
                                        context,
                                        "Mohon Scan Job Number terlebih dahulu.",
                                        isSuccess: false,
                                      );
                                      return;
                                    }

                                    showMixLotDialog(context);
                                  },
                                ),
                              ),
                              buildTextField(
                                controller: idMachineController,
                                label: "Machine",
                                hint: "Scan Machine ID",
                                icon: Icons.qr_code_scanner,
                                readOnly: true,
                                onIconTap: () async {
                                  final machineProvider =
                                      context.read<MachineProvider>();
                                  final testingProvider =
                                      context.read<TestingProvider>();

                                  if (machineProvider.isLoading) return;

                                  try {
                                    testingProvider.validateBeforeScanMachine();
                                  } catch (e) {
                                    CustomSnackbar.show(
                                      context,
                                      e.toString(),
                                      isSuccess: false,
                                    );
                                    return;
                                  }

                                  final qrCode = await Navigator.push<String?>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MobileScannerPage(),
                                    ),
                                  );

                                  if (qrCode == null ||
                                      qrCode.isEmpty ||
                                      qrCode == "-1") return;
                                  if (!context.mounted) return;

                                  final error = await machineProvider
                                      .setMachineByIdTesting(qrCode);

                                  if (!context.mounted) return;

                                  if (error != null) {
                                    CustomSnackbar.show(context, error,
                                        isSuccess: false);
                                    return;
                                  }

                                  // 🔥 INI KUNCI UTAMA
                                  testingProvider
                                      .setMachine(machineProvider.machine);
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    size: 24,
                                    color:
                                        Colors.grey.shade600, // ⬅️ DEFAULT SAJA
                                  ),
                                  onPressed: () async {
                                    final testingProv =
                                        context.read<TestingProvider>();

                                    // ✅ VALIDASI YANG SAMA
                                    try {
                                      testingProv.validateBeforeScanMachine();
                                    } catch (e) {
                                      CustomSnackbar.show(
                                        context,
                                        e.toString(),
                                        isSuccess: false,
                                      );
                                      return;
                                    }

                                    await _showMachinePickerDialog(context);
                                  },
                                ),
                              ),
                              buildTextField(
                                controller: idEmployeeController,
                                label: "Employee",
                                hint: "Scan Employee ID",
                                icon: Icons.qr_code_scanner,
                                readOnly: true,
                                onIconTap: () async {
                                  final testingProv =
                                      context.read<TestingProvider>();

                                  // 🔐 VALIDASI WAJIB
                                  try {
                                    testingProv.validateBeforeScanEmployee();
                                  } catch (e) {
                                    CustomSnackbar.show(
                                      context,
                                      e.toString(),
                                      isSuccess: false,
                                    );
                                    return;
                                  }

                                  // ================= SCAN QR =================
                                  final qrCode = await Navigator.push<String?>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MobileScannerPage(),
                                    ),
                                  );

                                  if (qrCode == null ||
                                      qrCode.isEmpty ||
                                      qrCode == "-1") {
                                    return;
                                  }
                                  if (!context.mounted) return;

                                  final employeeProvider =
                                      context.read<EmployeeProvider>();

                                  final success = await employeeProvider
                                      .scanEmployee(qrCode);

                                  if (!context.mounted) return;

                                  if (!success) {
                                    CustomSnackbar.show(
                                      context,
                                      employeeProvider.errorMessage ??
                                          "Scan employee gagal",
                                      isSuccess: false,
                                    );
                                    return;
                                  }

                                  // ✅ SET KE TESTING PROVIDER
                                  testingProv
                                      .setEmployee(employeeProvider.employee);
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.person_search,
                                    size: 24,
                                    color: Colors.grey.shade700,
                                  ),
                                  onPressed: () async {
                                    final testingProv =
                                        context.read<TestingProvider>();

                                    try {
                                      testingProv.validateBeforeScanEmployee();
                                    } catch (e) {
                                      CustomSnackbar.show(
                                        context,
                                        e.toString(),
                                        isSuccess: false,
                                      );
                                      return;
                                    }

                                    showEmployeeDropdownDialog(context);
                                  },
                                ),
                              ),
                              buildTextField(
                                controller: goldPillController,
                                label: "Gold Pill",
                                hint: "Gold Pill",
                                icon: Icons.qr_code_scanner,
                                readOnly: true,
                                onIconTap: () async {
                                  final materialProv =
                                      context.read<MaterialProvider>();
                                  final testingProv =
                                      context.read<TestingProvider>();

                                  // 🔐 VALIDASI JOB NUMBER
                                  if (!testingProv.isJobNumberScanned) {
                                    CustomSnackbar.show(
                                      context,
                                      "Mohon Scan Job Number terlebih dahulu.",
                                      isSuccess: false,
                                    );
                                    return;
                                  }

                                  try {
                                    // 🔹 1️⃣ Misal kamu sudah punya QR code sebagai String
                                    // ganti ini dengan QR code hasil scan manual / dari tempat lain
                                    final qrCode =
                                        await Navigator.push<String?>(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const MobileScannerPage()),
                                    );

                                    if (qrCode == null ||
                                        qrCode.isEmpty ||
                                        qrCode == "-1") {
                                      return;
                                    }

                                    // 🔹 2️⃣ Scan menggunakan function dari MaterialProvider
                                    await materialProv
                                        .scanGoldPillFromCode(qrCode);

                                    if (!materialProv.isPillScanned ||
                                        !materialProv.goldPillData.isValid) {
                                      CustomSnackbar.show(
                                        context,
                                        "QR code tidak valid atau bukan Gold Pill",
                                        isSuccess: false,
                                      );
                                      return;
                                    }

                                    // 🔹 3️⃣ Buat GoldPillModel dari hasil scan
                                    // Lebih simpel dan bersih
                                    final goldPill = materialProv.goldPillData;

                                    // 🔹 4️⃣ Assign ke TestingProvider
                                    testingProv.setGoldPill(goldPill);

                                    // 🔹 5️⃣ Update TextField langsung
                                    goldPillController.text =
                                        testingProv.goldPillLot;
                                  } catch (e) {
                                    CustomSnackbar.show(context,
                                        "Error scan Gold Pill: ${e.toString()}",
                                        isSuccess: false);
                                  }
                                },
                              ),
                              buildTextField(
                                controller: carbonPillController,
                                label: "Carbon Pill",
                                hint: "Carbon Pill",
                                icon: Icons.qr_code_scanner,
                                readOnly: true,
                                onIconTap: () async {
                                  final materialProv =
                                      context.read<MaterialProvider>();
                                  final testingProv =
                                      context.read<TestingProvider>();

                                  // 🔐 VALIDASI JOB NUMBER
                                  if (!testingProv.isJobNumberScanned) {
                                    CustomSnackbar.show(
                                      context,
                                      "Mohon Scan Job Number terlebih dahulu.",
                                      isSuccess: false,
                                    );
                                    return;
                                  }

                                  try {
                                    // 🔹 1️⃣ Ambil QR Code dari scanner
                                    final qrCode =
                                        await Navigator.push<String?>(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const MobileScannerPage()),
                                    );

                                    if (qrCode == null ||
                                        qrCode.isEmpty ||
                                        qrCode == "-1") {
                                      return;
                                    }

                                    // 🔹 2️⃣ Scan Carbon Pill via MaterialProvider (clean)
                                    await materialProv
                                        .scanCarbonPillFromCode(qrCode);

                                    if (!materialProv.isPillScanned ||
                                        !materialProv.carbonPillData.isValid) {
                                      CustomSnackbar.show(
                                        context,
                                        "QR code tidak valid atau bukan Carbon Pill",
                                        isSuccess: false,
                                      );
                                      return;
                                    }

                                    // 🔹 3️⃣ Buat CarbonPillModel dari hasil scan
                                    // Lebih simpel, bersih, dan sudah pasti sinkron dengan API
                                    final carbonPill =
                                        materialProv.carbonPillData;

                                    // 🔹 4️⃣ Assign ke TestingProvider
                                    testingProv.setCarbonPill(carbonPill);

                                    // 🔹 5️⃣ Update TextField langsung dari TestingProvider
                                    carbonPillController.text = testingProv
                                        .carbonPillLot; // getter di provider
                                  } catch (e) {
                                    CustomSnackbar.show(
                                      context,
                                      "Error scan Carbon Pill: ${e.toString()}",
                                      isSuccess: false,
                                    );
                                  }
                                },
                              ),
                              DropdownButtonFormField<String>(
                                key: ValueKey(prov
                                    .selectedMold.toolNumber), // 🔥 KUNCI UTAMA
                                isExpanded: true,

                                /// VALUE DIAMBIL DARI PROVIDER
                                initialValue: prov.selectedMold.isValid
                                    ? prov.selectedMold.toolNumber
                                    : null,

                                decoration: InputDecoration(
                                  labelText: "Mold Number",
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  hintText: "Select",
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13.0,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: Container(
                                    width: 36,
                                    height: 36,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 4),
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
                                      onPressed: () {
                                        // opsional: aksi tambahan jika ikon diklik
                                        // misalnya: tampilkan info mold
                                      },
                                      icon: const Icon(
                                        Icons.layers,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ),

                                style: GoogleFonts.poppins(
                                  fontSize: 14.0,
                                  color: Colors.black87,
                                ),

                                dropdownColor: Colors.white,

                                /// ITEMS DARI List<MoldModel>
                                items: prov.molds.isEmpty
                                    ? null
                                    : prov.molds.map((mold) {
                                        return DropdownMenuItem<String>(
                                          value: mold.toolNumber,
                                          child: Text(
                                            "Mold No. ${mold.toolNumber}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.0,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        );
                                      }).toList(),

                                /// EVENT → LANGSUNG KE PROVIDER
                                onChanged: prov.molds.isEmpty
                                    ? null
                                    : (value) {
                                        if (value != null) {
                                          prov.selectMold(value);
                                        }
                                      },
                              ),
                              buildTextField(
                                controller: qtyActualController,
                                label: "Qty",
                                hint: "Qty Test",
                                readOnly: true,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
            // SizedBox(height: 2.0),
            //####################BATAS CONTAINER KE 3 DISINI ######################***************

            Container(
                width: widthApp,
                height: heightBody * 0.1,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Consumer<TestingProvider>(
                          builder: (context, pro, _) {
                            // Tentukan gradient berdasarkan state button
                            final Gradient buttonGradient =
                                (!pro.canSubmit || pro.isSubmitting)
                                    ? LinearGradient(
                                        colors: [
                                          Colors.blueGrey.shade50,
                                          Colors.blueGrey.shade600
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.blueAccent.shade400,
                                          Colors.blue.shade800
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      );

                            return Ink(
                              decoration: BoxDecoration(
                                gradient: buttonGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: OutlinedButton(
                                onPressed: (!pro.canSubmit || pro.isSubmitting)
                                    ? null
                                    : () async {
                                        try {
                                          final success =
                                              await pro.submitRecordWithLoading(
                                            idRecordUpdate:
                                                pro.currentJob?.idRecordTest,
                                            batchNumber: pro.batchNumber,
                                            totalLotNumber: pro.totalLotNumber,
                                            notes: pro.notes,
                                            bcode: pro.bcode,
                                            jobNumber: pro.jobNumber,
                                            lotNumber: pro.lotNumber,
                                            selectedMoldNumber:
                                                pro.selectedMold.toolNumber,
                                            idEmployee: pro.employee.idEmployee,
                                            idMachine: pro.machine.idMc,
                                            startQty:
                                                int.tryParse(pro.qty) ?? 0,
                                            moldCavity:
                                                pro.selectedMold.cavityValue ??
                                                    1,
                                            mixLotNumber: pro.mixLotNo,
                                          );

                                          if (success) {
                                            CustomSnackbar.show(
                                              context,
                                              "Data berhasil dikirim",
                                              isSuccess: true,
                                            );
                                            pro.resetAll();
                                          }
                                        } catch (e) {
                                          CustomSnackbar.show(
                                            context,
                                            "Error: $e",
                                            isSuccess: false,
                                          );
                                        }
                                      },
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(
                                      const Size.fromHeight(90)),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  backgroundColor: WidgetStateProperty.all(Colors
                                      .transparent), // biar gradient terlihat
                                  foregroundColor:
                                      WidgetStateProperty.resolveWith<Color>(
                                          (states) {
                                    if (!pro.canSubmit || pro.isSubmitting) {
                                      return Colors
                                          .grey.shade200; // teks saat disabled
                                    }
                                    return Colors.white; // teks saat aktif
                                  }),
                                ),
                                child: pro.isSubmitting
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        "SUBMIT",
                                        style: GoogleFonts.poppins(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600,
                                          color: (!pro.canSubmit ||
                                                  pro.isSubmitting)
                                              ? Colors.grey
                                                  .shade600 // teks nonaktif
                                              : Colors.white, // teks aktif
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // ===== CLEAR =====
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2.0, vertical: 2.0),
                        child: Consumer<TestingProvider>(
                          builder: (context, provTest, _) {
                            return OutlinedButton(
                              onPressed: () {
                                provTest.resetAll();
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(90),
                                side:
                                    const BorderSide(color: Colors.blueAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "CLEAR",
                                style: GoogleFonts.poppins(
                                  color: Colors.blueAccent,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )),
            // SizedBox(height: 5.0),
            Container(
              width: widthApp,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigoAccent,
                    Colors.indigo.shade900,
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  "MOLD SETUP",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: widthApp * 0.025,
                  ),
                ),
              ),
            ),
            //DARI SINI
            Container(
              width: widthApp,
              padding: const EdgeInsets.only(
                top: 2,
                bottom: 20,
              ),
              child: SingleChildScrollView(
                  child: Consumer<TestingProvider>(builder: (context, prov, _) {
                return Table(
                  border: TableBorder.all(color: Colors.grey, width: 0.6),
                  columnWidths: const {
                    0: FixedColumnWidth(40),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(5),
                    3: FlexColumnWidth(1),
                  },
                  children: [
                    // ===== HEADER =====
                    TableRow(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.indigoAccent,
                            Colors.indigo.shade900,
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text("NO",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text("ITEM",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text("REMARK",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text("JUDGMENT",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white)),
                        ),
                      ],
                    ),

                    // ===== ROW 1 =====
                    TableRow(
                        decoration: BoxDecoration(
                            color: 1 % 2 == 1
                                ? Colors.blueGrey.shade50.withValues(alpha: 0.5)
                                : Colors.white),
                        children: [
                          // ===== NO =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Center(
                                  child: Text("1", textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ),

                          // ===== ITEM =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Align(
                                  alignment:
                                      Alignment.centerLeft, // kiri horizontal
                                  child: Text("PIN BUSH"),
                                ),
                              ),
                            ),
                          ),

                          // ===== REMARK =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center, // <<< INI KUNCI
                                  children: const [
                                    Text(
                                        "OK JIKA PIN BUSH LENGKAP SEBANYAK 4 PCS"),
                                    Text(
                                        "OK JIKA PIN BUSH TIDAK DAMAGE/SCRATCH/SHIFTING"),
                                    Text(
                                        "OK JIKA PIN BUSH SUDAH TERLUMASI GREASE"),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ===== JUDGMENT =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center, // aman
                                  children: [
                                    Transform.scale(
                                      scale: 1.5,
                                      child: Checkbox(
                                        value: prov.isCheckedMold(0),
                                        activeColor:
                                            Colors.orangeAccent.shade700,
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        onChanged: (value) {
                                          prov.updateCheckMold(0, value!);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "OK",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: prov.isCheckedMold(0)
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: prov.isCheckedMold(0)
                                            ? Colors.orangeAccent.shade700
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),

                    // ===== ROW 2 =====
                    TableRow(
                      children: [
                        // ===== NO =====
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: SizedBox(
                            height: 90,
                            child: Center(
                              child: Text(
                                "2",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),

                        // ===== ITEM =====
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: SizedBox(
                            height: 90,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("GUIDE BUSH"),
                              ),
                            ),
                          ),
                        ),

                        // ===== REMARK =====
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: SizedBox(
                            height: 90,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // KUNCI CENTER VERTICAL
                                children: const [
                                  Text(
                                      "OK JIKA GUIDE BUSH LENGKAP SEBANYAK 4 PCS"),
                                  Text(
                                      "OK JIKA PERMUKAAN GUIDE BUSH SAMA DAN TIDAK MIRING"),
                                  Text(
                                      "OK JIKA GUIDE BUSH SUDAH TERLUMASI GREASE"),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ===== JUDGMENT =====
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: SizedBox(
                            height: 90,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 1.5,
                                      child: Checkbox(
                                        value: prov.isCheckedMold(1),
                                        activeColor:
                                            Colors.orangeAccent.shade700,
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        onChanged: (value) {
                                          prov.updateCheckMold(1, value!);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "OK",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: prov.isCheckedMold(1)
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: prov.isCheckedMold(1)
                                            ? Colors.orangeAccent.shade700
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ===== ROW 3 =====
                    TableRow(
                        decoration: BoxDecoration(
                            color: 1 % 2 == 1
                                ? Colors.blueGrey.shade50.withValues(alpha: 0.5)
                                : Colors.white),
                        children: [
                          // ===== NO =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Center(
                                  child: Text("3", textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ),

                          // ===== ITEM =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Align(
                                  alignment:
                                      Alignment.centerLeft, // kiri horizontal
                                  child: Text("SPRING SAFETY"),
                                ),
                              ),
                            ),
                          ),

                          // ===== REMARK =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // center vertical
                                  children: const [
                                    Text(
                                      "OK JIKA SPRING SAFETY BERSIH DARI BURRY DAN KENCANG",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ===== JUDGMENT =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 1.5,
                                      child: Checkbox(
                                        value: prov.isCheckedMold(2),
                                        activeColor:
                                            Colors.orangeAccent.shade700,
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        onChanged: (value) {
                                          prov.updateCheckMold(2, value!);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "OK",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: prov.isCheckedMold(2)
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: prov.isCheckedMold(2)
                                            ? Colors.orangeAccent.shade700
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),

                    // ===== ROW 4 =====
                    TableRow(children: [
                      // ===== NO =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Center(
                              child: Text("4", textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ),

                      // ===== ITEM =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Align(
                              alignment:
                                  Alignment.centerLeft, // kiri horizontal
                              child: Text("SPRING HEIGHT"),
                            ),
                          ),
                        ),
                      ),

                      // ===== REMARK =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // center vertical
                              children: const [
                                Text(
                                  "PASTIKAN TINGGI SPRING MESIN SAMA ATAU SEJAJAR (UNTUK PANSTONE SINGLE LAYER)",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ===== JUDGMENT =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 1.5,
                                  child: Checkbox(
                                    value: prov.isCheckedMold(3),
                                    activeColor: Colors.orangeAccent.shade700,
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ),
                                    onChanged: (value) {
                                      prov.updateCheckMold(3, value!);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "OK",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: prov.isCheckedMold(3)
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: prov.isCheckedMold(3)
                                        ? Colors.orangeAccent.shade700
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),

                    // ===== ROW 5 =====
                    TableRow(
                        decoration: BoxDecoration(
                            color: 1 % 2 == 1
                                ? Colors.blueGrey.shade50.withValues(alpha: 0.5)
                                : Colors.white),
                        children: [
                          // ===== NO =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Center(
                                  child: Text("5", textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ),

                          // ===== ITEM =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Align(
                                  alignment:
                                      Alignment.centerLeft, // kiri horizontal
                                  child: Text("POSITIONING"),
                                ),
                              ),
                            ),
                          ),

                          // ===== REMARK =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // center vertical
                                  children: const [
                                    Text(
                                      "PENGENCANGAN SETIAP BAUT DILAKUKAN SETELAH PEMANASAN MOLD",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ===== JUDGMENT =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 1.5,
                                      child: Checkbox(
                                        value: prov.isCheckedMold(4),
                                        activeColor:
                                            Colors.orangeAccent.shade700,
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        onChanged: (value) {
                                          prov.updateCheckMold(4, value!);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "OK",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: prov.isCheckedMold(4)
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: prov.isCheckedMold(4)
                                            ? Colors.orangeAccent.shade700
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),

                    // ===== ROW 6 =====
                    TableRow(children: [
                      // ===== NO =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Center(
                              child: Text("6", textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ),

                      // ===== ITEM =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Align(
                              alignment:
                                  Alignment.centerLeft, // kiri horizontal
                              child: Text("MOLD CONDITION"),
                            ),
                          ),
                        ),
                      ),

                      // ===== REMARK =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // center vertical
                              children: const [
                                Text(
                                  "PERIKSA KEMBALI KONDISI MOLD, APAKAH TERDAPAT SCRATCH DAN PASTIKAN "
                                  "TIDAK ADA SOFT BURRY DI DALAM CONTACT POINT.",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ===== JUDGMENT =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 1.5,
                                  child: Checkbox(
                                    value: prov.isCheckedMold(5),
                                    activeColor: Colors.orangeAccent.shade700,
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ),
                                    onChanged: (value) {
                                      prov.updateCheckMold(5, value!);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "OK",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: prov.isCheckedMold(5)
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: prov.isCheckedMold(5)
                                        ? Colors.orangeAccent.shade700
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),

                    // ===== ROW 7 =====
                    TableRow(
                        decoration: BoxDecoration(
                            color: 1 % 2 == 1
                                ? Colors.blueGrey.shade50.withValues(alpha: 0.5)
                                : Colors.white),
                        children: [
                          // ===== NO =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Center(
                                  child: Text("7", textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ),

                          // ===== ITEM =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Align(
                                  alignment:
                                      Alignment.centerLeft, // kiri horizontal
                                  child: Text("PLATING MOLD & JIG"),
                                ),
                              ),
                            ),
                          ),

                          // ===== REMARK =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // center vertical
                                  children: const [
                                    Text(
                                      "PERIKSA KONDISI PLATING APAKAH ADA YANG TERKELUPAS ATAU "
                                      "BERTAMBAH TIPIS ATAU TIDAK.",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ===== JUDGMENT =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 1.5,
                                      child: Checkbox(
                                        value: prov.isCheckedMold(6),
                                        activeColor:
                                            Colors.orangeAccent.shade700,
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        onChanged: (value) {
                                          prov.updateCheckMold(6, value!);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "OK",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: prov.isCheckedMold(6)
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: prov.isCheckedMold(6)
                                            ? Colors.orangeAccent.shade700
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),

                    // ===== ROW 8 =====
                    TableRow(children: [
                      // ===== NO =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Center(
                              child: Text("8", textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ),

                      // ===== ITEM =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Align(
                              alignment:
                                  Alignment.centerLeft, // kiri horizontal
                              child: Text("BOLT CONDITION"),
                            ),
                          ),
                        ),
                      ),

                      // ===== REMARK =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // center vertical
                              children: const [
                                Text(
                                  "OK JIKA BAUT MOLD DIPASANG LENGKAP DAN TIDAK AUS",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ===== JUDGMENT =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 1.5,
                                  child: Checkbox(
                                    value: prov.isCheckedMold(7),
                                    activeColor: Colors.orangeAccent.shade700,
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ),
                                    onChanged: (value) {
                                      prov.updateCheckMold(7, value!);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "OK",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: prov.isCheckedMold(7)
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: prov.isCheckedMold(7)
                                        ? Colors.orangeAccent.shade700
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),

                    // ===== ROW 9 =====
                    TableRow(
                        decoration: BoxDecoration(
                            color: 1 % 2 == 1
                                ? Colors.blueGrey.shade50.withValues(alpha: 0.5)
                                : Colors.white),
                        children: [
                          // ===== NO =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Center(
                                  child: Text("9", textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ),

                          // ===== ITEM =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("PACKING RUBBER"),
                                ),
                              ),
                            ),
                          ),

                          // ===== REMARK =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "PERIKSA KONDISI PACKING RUBBER,APAKAH ADA YANG ROBEK & WARNA PACKING RUBBER SESUAI ATURAN.",
                                    ),
                                    Text(
                                      "OK JIKA PACKING RUBBER SUDAH TERLUMASI GREASE",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ===== JUDGMENT =====
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: SizedBox(
                              height: 90,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 1.5,
                                      child: Checkbox(
                                        value: prov.isCheckedMold(8),
                                        activeColor:
                                            Colors.orangeAccent.shade700,
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        onChanged: (value) {
                                          prov.updateCheckMold(8, value!);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "OK",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: prov.isCheckedMold(8)
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: prov.isCheckedMold(8)
                                            ? Colors.orangeAccent.shade700
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),

                    // ===== ROW 10 =====
                    TableRow(children: [
                      // ===== NO =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Center(
                              child: Text("10", textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ),

                      // ===== ITEM =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("MOLD OPENING ANGLE"),
                            ),
                          ),
                        ),
                      ),

                      // ===== REMARK =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "OK JIKA SUDUT BUKAAN MOLD HARUS TERBUKA DI RANGE 80-90 DERAJAT DAN DIUKUR MENGGUNAKAN ALAT UKUR DIGITAL BUSUR DERAJAT.",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ===== JUDGMENT =====
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 1.5,
                                  child: Checkbox(
                                    value: prov.isCheckedMold(9),
                                    activeColor: Colors.orangeAccent.shade700,
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ),
                                    onChanged: (value) {
                                      prov.updateCheckMold(9, value!);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "OK",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: prov.isCheckedMold(9)
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: prov.isCheckedMold(9)
                                        ? Colors.orangeAccent.shade700
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),

                    // ===== ROW 6–12 =====
                    // (pola sama, aman Anda copy–paste)
                  ],
                );
              })),
            ),

            SizedBox(height: 5.0),

            Container(
              width: widthApp,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigoAccent,
                    Colors.indigo.shade900,
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  "VACUM JIG SETUP",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: widthApp * 0.025,
                  ),
                ),
              ),
            ),

            Container(
              width: widthApp,
              padding: const EdgeInsets.only(
                top: 2,
                bottom: 20,
              ),
              child: SingleChildScrollView(
                child:
                    Consumer<TestingProvider>(builder: (context, provVac, _) {
                  return Table(
                    border: TableBorder.all(color: Colors.grey, width: 0.6),
                    columnWidths: const {
                      0: FixedColumnWidth(40),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(5),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      // ===== HEADER =====
                      TableRow(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.indigoAccent,
                              Colors.indigo.shade900,
                            ],
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text("NO",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text("ITEM",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text("REMARK",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text("JUDGMENT",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white)),
                          ),
                        ],
                      ),

                      // ===== ROW 1 =====
                      // ===== ROW 1 =====
                      TableRow(
                          decoration: BoxDecoration(
                              color: 1 % 2 == 1
                                  ? Colors.blueGrey.shade50
                                      .withValues(alpha: 0.5)
                                  : Colors.white), // row ganjil biru muda

                          children: [
                            // ===== NO =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Center(
                                    child:
                                        Text("1", textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                            ),

                            // ===== ITEM =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("STOPPER"),
                                  ),
                                ),
                              ),
                            ),

                            // ===== REMARK =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "OK JIKA STOPPER LENGKAP SEBANYAK 4 PCS DAN TIDAK GOYANG SERTA TINGGINYA SAMA.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ===== JUDGMENT =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Checkbox(
                                          value: provVac.isCheckedVacum(0),
                                          activeColor:
                                              Colors.orangeAccent.shade700,
                                          visualDensity: const VisualDensity(
                                            horizontal: -4,
                                            vertical: -4,
                                          ),
                                          onChanged: (value) {
                                            provVac.updateCheckVacum(0, value!);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: provVac.isCheckedVacum(0)
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: provVac.isCheckedVacum(0)
                                              ? Colors.orangeAccent.shade700
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),

                      // ===== ROW 2 =====
                      TableRow(
                          // row

                          children: [
                            // ===== NO =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Center(
                                    child:
                                        Text("2", textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                            ),

                            // ===== ITEM =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("GUIDE BUSH DI TOP"),
                                  ),
                                ),
                              ),
                            ),

                            // ===== REMARK =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "OK JIKA GUIDE BUSH LENGKAP SEBANYAK 4 PCS, TIDAK KENDOR DAN BENTUK TAMPILANNYA BAGUS.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ===== JUDGMENT =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Checkbox(
                                          value: provVac.isCheckedVacum(1),
                                          activeColor:
                                              Colors.orangeAccent.shade700,
                                          visualDensity: const VisualDensity(
                                            horizontal: -4,
                                            vertical: -4,
                                          ),
                                          onChanged: (value) {
                                            provVac.updateCheckVacum(1, value!);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: provVac.isCheckedVacum(1)
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: provVac.isCheckedVacum(1)
                                              ? Colors.orangeAccent.shade700
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),

                      // ===== ROW 3 =====
                      TableRow(
                          decoration: BoxDecoration(
                              color: 1 % 2 == 1
                                  ? Colors.blueGrey.shade50
                                      .withValues(alpha: 0.5)
                                  : Colors.white), // row

                          children: [
                            // ===== NO =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Center(
                                    child:
                                        Text("3", textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                            ),

                            // ===== ITEM =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("SUCTION PIN"),
                                  ),
                                ),
                              ),
                            ),

                            // ===== REMARK =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "OK JIKA SEMUA PIN LENGKAP, BISA MENGANGKAT PILL, TAMPILAN PIN BAGUS DAN TIDAK GOMPAL.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ===== JUDGMENT =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Checkbox(
                                          value: provVac.isCheckedVacum(2),
                                          activeColor:
                                              Colors.orangeAccent.shade700,
                                          visualDensity: const VisualDensity(
                                            horizontal: -4,
                                            vertical: -4,
                                          ),
                                          onChanged: (value) {
                                            provVac.updateCheckVacum(2, value!);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: provVac.isCheckedVacum(2)
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: provVac.isCheckedVacum(2)
                                              ? Colors.orangeAccent.shade700
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),

                      // ===== ROW 4 =====
                      TableRow(
                          // row

                          children: [
                            // ===== NO =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Center(
                                    child:
                                        Text("4", textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                            ),

                            // ===== ITEM =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("GUIDE PIN ON BOTTOM VACUUM"),
                                  ),
                                ),
                              ),
                            ),

                            // ===== REMARK =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "OK JIKA STOPPER LENGKAP SEBANYAK 4 PCS, TIDAK KENDOR DAN TAMPILAN BAGUS (TIDAK GOMPAL).",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ===== JUDGMENT =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Checkbox(
                                          value: provVac.isCheckedVacum(3),
                                          activeColor:
                                              Colors.orangeAccent.shade700,
                                          visualDensity: const VisualDensity(
                                            horizontal: -4,
                                            vertical: -4,
                                          ),
                                          onChanged: (value) {
                                            provVac.updateCheckVacum(3, value!);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: provVac.isCheckedVacum(3)
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: provVac.isCheckedVacum(3)
                                              ? Colors.orangeAccent.shade700
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),

                      // ===== ROW 5 =====
                      TableRow(
                          decoration: BoxDecoration(
                              color: 1 % 2 == 1
                                  ? Colors.blueGrey.shade50
                                      .withValues(alpha: 0.5)
                                  : Colors.white), // row

                          children: [
                            // ===== NO =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Center(
                                    child:
                                        Text("5", textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                            ),

                            // ===== ITEM =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("TOP VACUUM NO BENDING"),
                                  ),
                                ),
                              ),
                            ),

                            // ===== REMARK =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "OK JIKA VACUUM JIG RATA PADA SAAT DIMASUKAN KE BOTTOM VACUUM DAN KE MOLD",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ===== JUDGMENT =====
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: SizedBox(
                                height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Checkbox(
                                          value: provVac.isCheckedVacum(4),
                                          activeColor:
                                              Colors.orangeAccent.shade700,
                                          visualDensity: const VisualDensity(
                                            horizontal: -4,
                                            vertical: -4,
                                          ),
                                          onChanged: (value) {
                                            provVac.updateCheckVacum(4, value!);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: provVac.isCheckedVacum(4)
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: provVac.isCheckedVacum(4)
                                              ? Colors.orangeAccent.shade700
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ],
                  );
                }),
              ),
            ),

            Container(
              width: widthApp,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigoAccent,
                    Colors.indigo.shade900,
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  "MACHINE PARAMETER",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: widthApp * 0.025,
                  ),
                ),
              ),
            ),

            Container(
              width: widthApp,
              padding: const EdgeInsets.only(
                top: 2,
                bottom: 20,
              ),
              child: SingleChildScrollView(
                child: Consumer<TestingProvider>(builder: (context, provid, _) {
                  return Table(
                    border: TableBorder.all(color: Colors.grey, width: 0.6),
                    columnWidths: const {
                      0: FixedColumnWidth(40),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(3),
                      3: FlexColumnWidth(3),
                    },
                    children: [
                      // ===== HEADER =====
                      TableRow(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.indigoAccent,
                              Colors.indigo.shade900,
                            ],
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "NO",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "ITEM",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "ITEM DETAIL",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "ACTUAL",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ===== ROW 1 =====
                      TableRow(
                        decoration: BoxDecoration(
                            color: 1 % 2 == 1
                                ? Colors.blueGrey.shade50.withValues(alpha: 0.5)
                                : Colors.white),
                        children: [
                          // ================= NO =================
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                "1",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),

                          // ================= ITEM =================
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                "MC TEMPERATURE",
                                // textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),

                          // ================= REMARK =================
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "TEMPERATURE UPPER (°C)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 30),
                                    Text(
                                      "TEMPERATURE LOWER (°C)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ================= JUDGEMENT =================
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ===== BARIS ATAS =====
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: mcTempUpperCtrl,
                                            onChanged: (_) => _saveTemp(provid),
                                            keyboardType: TextInputType.number,
                                            style:
                                                const TextStyle(fontSize: 14),
                                            decoration: const InputDecoration(
                                              hintText: "0",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "-",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller: mcTempLowerCtrl,
                                            onChanged: (_) => _saveTemp(provid),
                                            keyboardType: TextInputType.number,
                                            style:
                                                const TextStyle(fontSize: 14),
                                            decoration: const InputDecoration(
                                              hintText: "0",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // ===== BARIS BAWAH =====
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: mcTempLowUpperCtrl,
                                            onChanged: (_) =>
                                                _saveTempLower(provid),
                                            keyboardType: TextInputType.number,
                                            style:
                                                const TextStyle(fontSize: 14),
                                            decoration: const InputDecoration(
                                              hintText: "0",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "-",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller: mcTempLowLowerCtrl,
                                            onChanged: (_) =>
                                                _saveTempLower(provid),
                                            keyboardType: TextInputType.number,
                                            style:
                                                const TextStyle(fontSize: 14),
                                            decoration: const InputDecoration(
                                              hintText: "0",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ===== ROW 2 =====
                      TableRow(children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text("2", textAlign: TextAlign.center),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text("MC CURING"),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text("CURING TIME (seconds)"),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: TextField(
                              controller: mcCuringCtrl,
                              onChanged: (value) {
                                context.read<TestingProvider>().mcCuring =
                                    value;
                              },
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: "0",
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ]),

                      // ===== ROW 3 =====
                      TableRow(
                          decoration: BoxDecoration(
                              color: 1 % 2 == 1
                                  ? Colors.blueGrey.shade50
                                      .withValues(alpha: 0.5)
                                  : Colors.white),
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text("3", textAlign: TextAlign.center),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text("MC PRESSURE"),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text("PRESSURE (kfg/cm²)"),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: TextField(
                                  controller: mcPressureCtrl,
                                  onChanged: (value) {
                                    context.read<TestingProvider>().mcPressure =
                                        value;
                                  },
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    hintText: "0",
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                          ]),

                      // ===== ROW 2 =====
                      TableRow(children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text("4", textAlign: TextAlign.center),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text("MC SETTING"),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text("SETTING"),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: TextField(
                              controller: mcSettingsCtrl,
                              onChanged: (value) {
                                context.read<TestingProvider>().mcSettings =
                                    value;
                              },
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9\- ]'),
                                ),
                              ],
                              decoration: const InputDecoration(
                                hintText: "0 0 0-0 0 0 0 0",
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ]),

                      // ===== ROW 6 =====

                      // ===== ROW 6–12 =====
                      // (pola sama, aman Anda copy–paste)
                    ],
                  );
                }),
              ),
            ),

            Container(
              width: widthApp,
              padding: const EdgeInsets.only(
                top: 2,
                bottom: 60,
              ),
              child: SingleChildScrollView(
                child: Consumer<TestingProvider>(
                  builder: (context, provid, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ===== TABLE UTAMA =====
                        Table(
                          border:
                              TableBorder.all(color: Colors.grey, width: 0.6),
                          columnWidths: const {
                            0: FixedColumnWidth(40),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(3),
                            3: FlexColumnWidth(3),
                          },
                          children: [
                            // ... semua TableRow kamu
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ===== NOTE HEADER =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent,
                                    Colors.blue.shade800,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _showNoteDialog(context),
                                icon: const Icon(Icons.sticky_note_2_outlined,
                                    color: Colors.white),
                                label: const Text(
                                  "ADD NOTE",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 2),

                        // ===== NOTE CONTENT =====
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: 80, // ± 4 baris teks ukuran 13
                          ),
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 40,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blueGrey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              provid.notes.isNotEmpty
                                  ? provid.notes
                                  : "No note added",
                              style: TextStyle(
                                fontSize: 12,
                                color: provid.notes.isNotEmpty
                                    ? Colors.black87
                                    : Colors.grey.shade200,
                                fontStyle: provid.notes.isNotEmpty
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),

            //SAMPAI SINI

            // ===== TABLE =====
          ]),
        );
      }),
      //SINGLECHILDSCROLLVIEW SAMPAI SINI
    );
  }

  void _saveTemp(TestingProvider prov) {
    final upper = mcTempUpperCtrl.text;
    final lower = mcTempLowerCtrl.text;

    prov.mcTempUpper = "$upper-$lower";
  }

  void _saveTempLower(TestingProvider prov) {
    final upper = mcTempLowUpperCtrl.text;
    final lower = mcTempLowLowerCtrl.text;

    prov.mcTempLower = "$upper-$lower";
  }

  Widget _container({
    required Widget child,
    Color? color,
    Gradient? gradient,
    double? height,
  }) {
    return Container(
      height: height ?? 80,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (color ?? Colors.blueAccent.shade700) : null,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  void showMixLotDialog(BuildContext context) {
    TextEditingController tempController =
        TextEditingController(text: mixLotNumberController.text);
    bool isOkMixLotEnabled = tempController.text.length == 13;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: StatefulBuilder(
            builder: (context, localSetState) {
              return Dialog(
                backgroundColor: Colors.blue.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "ADD MIXING LOT NO",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // TextField
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            controller: tempController,
                            inputFormatters: [MixLotFormatter()],
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: "MIX LOT NO",
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onChanged: (value) {
                              localSetState(() {
                                isOkMixLotEnabled = value.length == 13;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Spacer(),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // CANCEL
                            Expanded(
                              child: SizedBox(
                                height: 70,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.blue,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: Text(
                                    "CANCEL",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // OK
                            Expanded(
                              child: Container(
                                height: 70.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: isOkMixLotEnabled
                                      ? LinearGradient(
                                          colors: [
                                            Colors.blueAccent,
                                            Colors.blue.shade800
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.blueGrey.shade50,
                                            Colors.blueGrey.shade600
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                ),
                                child: TextButton(
                                  onPressed: isOkMixLotEnabled
                                      ? () {
                                          final inputValue =
                                              tempController.text;

                                          final testingProv =
                                              context.read<TestingProvider>();

                                          testingProv.setMixLotNo(inputValue);

                                          Navigator.of(dialogContext).pop();
                                        }
                                      : null,
                                  child: Text(
                                    "OK",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

//================================= MACHINE DIALOG =============================

  Future<void> _showMachinePickerDialog(BuildContext context) async {
    final provider = Provider.of<MachineProvider>(context, listen: false);

    // Load machine list
    final error = await provider.loadMachines();
    if (error != null) {
      if (!context.mounted) return;
      CustomSnackbar.show(context, error, isSuccess: false);
      return;
    }

    if (provider.machineList.isEmpty) {
      CustomSnackbar.show(context, "Data Machine kosong!", isSuccess: false);
      return;
    }

    MachineModelDropdown? selectedItem;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, localSetState) {
            return Dialog(
              backgroundColor: Colors.blue.shade500,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "PILIH MACHINE",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownSearch<MachineModelDropdown>(
                        items: (f, cs) => provider.machineList,
                        itemAsString: (item) => item.nmMc,
                        compareFn: (a, b) =>
                            a.idMc == b.idMc, // 🔥 WAJIB UNTUK CUSTOM MODEL
                        onChanged: (item) {
                          localSetState(() {
                            selectedItem = item;
                          });
                        },
                        decoratorProps: const DropDownDecoratorProps(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Machine",
                            hintText: "Nama Machine",
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 12),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            inputFormatters: [
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) => TextEditingValue(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection,
                                ),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: "Cari Machine",
                              hintText: "Ketik Nama Machine...",
                              prefixIcon: const Icon(Icons.search),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 18),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          itemBuilder: (context, MachineModelDropdown item,
                              isDisabled, isSelected) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? [
                                          Colors.blue.shade200,
                                          Colors.lightBlue.shade100
                                        ]
                                      : [
                                          Colors.grey.shade50,
                                          Colors.grey.shade100
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: Offset(2, 3),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    offset: Offset(-2, -2),
                                  ),
                                ],
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.lightBlue.shade400
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  localSetState(() {
                                    selectedItem = item;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade100,
                                            Colors.blue.shade300
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.25),
                                            blurRadius: 6,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons
                                              .gear, // ganti icon mesin di sini
                                          color: Colors.blueGrey.shade600,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      item.nmMc,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isSelected
                                            ? Colors.blue.shade900
                                            : Colors.black87,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "AREA: ${item.areaMc}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? Icon(Icons.check_circle,
                                            color: Colors.amber.shade400,
                                            size: 28)
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.8,
                            maxWidth: MediaQuery.of(context).size.width * 0.95,
                            minWidth: MediaQuery.of(context).size.width * 0.95,
                          ),
                          scrollbarProps: const ScrollbarProps(
                              trackVisibility: true, thumbVisibility: true),
                          menuProps: const MenuProps(
                            margin: EdgeInsets.only(top: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 70,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.blue, width: 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogContext); // Tutup dialog
                                },
                                child: Text(
                                  "CANCEL",
                                  style: GoogleFonts.poppins(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: selectedItem == null
                                    ? LinearGradient(
                                        colors: [
                                          Colors.blueGrey.shade50,
                                          Colors.blueGrey.shade600
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.blueAccent,
                                          Colors.blue.shade800
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                              ),
                              child: TextButton(
                                onPressed: (selectedItem == null ||
                                        provider.isValidating)
                                    ? null
                                    : () async {
                                        final machineProvider =
                                            context.read<MachineProvider>();
                                        final testingProvider =
                                            context.read<TestingProvider>();

                                        final error = await machineProvider
                                            .setMachineByIdTesting(
                                          selectedItem!.idMc,
                                        );

                                        if (!context.mounted) return;

                                        if (error != null) {
                                          CustomSnackbar.show(context, error,
                                              isSuccess: false);
                                          return;
                                        }

                                        testingProvider.setMachine(
                                            machineProvider.machine);
                                        Navigator.pop(dialogContext);
                                      },
                                child: provider.isValidating
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        "OK",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

//========================= DIALOG SHOW EMPLOYEEE DROPDOWN =====================

  Future<void> showEmployeeDropdownDialog(BuildContext context) async {
    final employeeProv = context.read<EmployeeProvider>();
    final testingProv = context.read<TestingProvider>();

    // 🔒 Validasi urutan
    if (!testingProv.isJobNumberScanned) {
      CustomSnackbar.show(
        context,
        "Mohon Scan Job Number terlebih dahulu.",
        isSuccess: false,
      );
      return;
    }

    // 🔄 Load employee
    if (employeeProv.employeeList.isEmpty && !employeeProv.isLoading) {
      await employeeProv.loadEmployees();
    }

    if (employeeProv.employeeList.isEmpty) {
      CustomSnackbar.show(
        context,
        "Data Employee belum tersedia.",
        isSuccess: false,
      );
      return;
    }

    EmployeeModel? selectedItem;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, localSetState) {
            return Dialog(
              backgroundColor: Colors.blue.shade500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 🔷 TITLE
                      Text(
                        "PILIH OPERATOR",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 🔽 DROPDOWN EMPLOYEE
                      DropdownSearch<EmployeeModel>(
                        items: (f, cs) => employeeProv.employeeList,
                        itemAsString: (item) => item.fullName,
                        compareFn: (a, b) => a.idEmployee == b.idEmployee,
                        onChanged: (item) {
                          localSetState(() {
                            selectedItem = item;
                          });
                        },
                        decoratorProps: const DropDownDecoratorProps(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Operator",
                            hintText: "Nama Operator",
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 12,
                            ),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            inputFormatters: [
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) => TextEditingValue(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection,
                                ),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: "Cari Operator",
                              hintText: "Ketik Nama Operator...",
                              prefixIcon: const Icon(Icons.search),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 18),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          itemBuilder: (context, item, isDisabled, isSelected) {
                            final photoUrl =
                                '${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png';

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          Colors.blue.shade200,
                                          Colors.lightBlue.shade100,
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.grey.shade50,
                                          Colors.grey.shade100,
                                        ],
                                      ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(2, 3),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    offset: const Offset(-2, -2),
                                  ),
                                ],
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.lightBlue.shade400
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(5),
                                onTap: () {
                                  localSetState(() {
                                    selectedItem = item;
                                  });
                                },
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(12, 6, 12, 6),
                                  leading: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade100,
                                          Colors.blue.shade300,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.person),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    item.fullName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.blue.shade900
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "NRP: ${item.nrp}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.amber.shade400,
                                          size: 28,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.8,
                            maxWidth: MediaQuery.of(context).size.width * 0.95,
                            minWidth: MediaQuery.of(context).size.width * 0.95,
                          ),
                          scrollbarProps: const ScrollbarProps(
                            trackVisibility: true,
                            thumbVisibility: true,
                          ),
                          menuProps: const MenuProps(
                            margin: EdgeInsets.only(top: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Spacer(),

                      /// 🔘 BUTTON AREA
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 70,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.blue, width: 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                                onPressed: () => Navigator.pop(dialogContext),
                                child: Text(
                                  "CANCEL",
                                  style: GoogleFonts.poppins(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: selectedItem == null
                                    ? LinearGradient(
                                        colors: [
                                          Colors.blueGrey.shade50,
                                          Colors.blueGrey.shade600
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.blueAccent,
                                          Colors.blue.shade800
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                              ),
                              child: TextButton(
                                onPressed: selectedItem == null
                                    ? null
                                    : () {
                                        testingProv.setEmployee(selectedItem!);
                                        Navigator.pop(dialogContext);
                                      },
                                child: Text(
                                  "OK",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNoteDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.read<TestingProvider>();

    final TextEditingController noteController =
        TextEditingController(text: provider.notes);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Note",
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 8,
                child: SizedBox(
                  width: size.width * 0.9,
                  height: size.height * 0.3,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        // ===== HEADER (TANPA CLOSE ICON) =====
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "NOTE",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ===== TEXT FIELD =====
                        Expanded(
                          child: TextField(
                            controller: noteController, // 🔥 WAJIB
                            maxLines: null,
                            expands: true,
                            decoration: const InputDecoration(
                              hintText: "Masukkan catatan...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== ACTION BUTTON =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // ===== CLOSE (Outlined Button) =====
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              child: const Text("CLOSE"),
                            ),

                            const SizedBox(width: 8),

                            // ===== SIMPAN (Gradient Button, NO radius 5) =====
                            Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent,
                                    Colors.blue.shade800,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(
                                    5), // tegas, tanpa radius 5
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  // simpan note
                                  context
                                      .read<TestingProvider>()
                                      .setNotes(noteController.text.trim());
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                child: const Text(
                                  "SUBMIT",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MixLotFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Ubah ke huruf besar dan hapus spasi
    String text = newValue.text.toUpperCase().replaceAll(' ', '');

    // Batasi maksimal 12 karakter
    if (text.length > 12) {
      text = text.substring(0, 12);
    }

    // Sisipkan spasi setelah 6 karakter
    if (text.length > 6) {
      text = '${text.substring(0, 6)} ${text.substring(6)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
