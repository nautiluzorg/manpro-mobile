import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/machine_model_dropdown.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/widgets/record_action_buttons.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';

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
  late int sisaShoot;
  late num totalShot;

  int? goldPill;
  int? carbonPill;
  bool isFinish = false;
  bool isAvailable = false;
  String? idRecUpdate; // taruh ini di dalam State class
  bool isJobNumberScanned = false;
  bool isMixLotScanned = false;
  bool isMachineScanned = false;
  bool isEmployeeScanned = false;
  bool isPillEnabled = false;
  bool isSubmitting = false;
  String jobDate = "";
  String strtotalShot = "";
  String? selectedMoldNumber;
  List<dynamic> molds = [];
  List<Map<String, dynamic>> dataNG = [];
  List<Map<String, dynamic>> ngTableData = [];
  int selectedShift = 1;
  List<bool> isSelected = [true, false, false];
  EmployeeModel? selectedEmployeeItem;

  final TextEditingController mixLotNumberController = TextEditingController();
  final TextEditingController idEmployeeController = TextEditingController();
  final TextEditingController goldPillController = TextEditingController();
  final TextEditingController carbonPillController = TextEditingController();
  final TextEditingController idMachineController = TextEditingController();
  final TextEditingController jobNumberController = TextEditingController();
  final TextEditingController drawNumberController = TextEditingController();
  final TextEditingController qtyLotController = TextEditingController();
  final TextEditingController moldNumberController = TextEditingController();
  final TextEditingController moldCavityController = TextEditingController();
  final TextEditingController totalShotController = TextEditingController();
  final TextEditingController qtyActualController = TextEditingController();

//FUNGCTION UNTUK MEMERIKSA STATUS DATA NG.

  void printNgTableData() {
    if (ngTableData.isEmpty) {
      logPrint('ngTableData is empty.');
    } else {
      for (var i = 0; i < ngTableData.length; i++) {
        logPrint('${i + 1}. Code: ${ngTableData[i]['code']}, '
            'Name: ${ngTableData[i]['name']}, '
            'Quantity: ${ngTableData[i]['quantity']}');
      }
    }
  }

  int getTotalNG() {
    if (ngTableData.isEmpty) return 0;

    return ngTableData.fold<int>(0, (sum, item) {
      final qty = item['quantity'];
      final qtyInt = qty is int ? qty : int.tryParse(qty.toString()) ?? 0;
      return sum + qtyInt;
    });
  }

  void addOrUpdateNG(
      String code,
      String name,
      int quantity,
      String idRecordUpdate,
      String idEmployee,
      String jobNumber,
      int qtyShoot) {
    if (code.isEmpty || quantity <= 0) {
      return;
    }

    final existingIndex = dataNG.indexWhere((row) => row['id_ng'] == code);
    if (existingIndex != -1) {
      // Jika kode NG sudah ada, tambahkan kuantitas
      dataNG[existingIndex]['qty'] += quantity;
    } else {
      // Jika tidak ada, tambahkan data baru
      dataNG.add({
        'id_ng': code,
        'ng_name': name,
        'qty': quantity,
        'id_record': idRecordUpdate,
        'id_employee': idEmployee,
        'jobnumber': jobNumber,
        'qty_shoot': qtyShoot
      });
    }

    // Sinkronkan ngTableData dengan dataNG

    setState(() {
      ngTableData = List.from(dataNG);

      // 🔹 HITUNG TOTAL NG & UPDATE QTY ACTUAL DI SINI
      final totalNG = ngTableData.fold<int>(
          0, (sum, item) => sum + ((item['qty'] ?? 0) as int));

      Provider.of<JobNumberProvider>(context, listen: false)
          .updateQtyActualBasedOnNG(totalNG);
    });
  }

  void deleteNG(String code) {
    setState(() {
      dataNG.removeWhere((data) => data['id_ng'] == code);
      ngTableData = List.from(dataNG);

      // 🔹 Update Qty Actual setelah NG dihapus
      final totalNG = ngTableData.fold<int>(
          0, (sum, item) => sum + ((item['qty'] ?? 0) as int));

      Provider.of<JobNumberProvider>(context, listen: false)
          .updateQtyActualBasedOnNG(totalNG);
    });
  }

  @override
  void initState() {
    sisaShoot = 0;
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
    moldNumberController.dispose();
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

  void onEditMixLotNumber(BuildContext context) {
    _showMixLotDialog(context); // pisahkan dialog ke function
  }

  void _showMixLotDialog(BuildContext context) {
    final tempController = TextEditingController(
      text: context.read<MaterialProvider>().mixLotNumber,
    );

    // Pakai ValueNotifier untuk enable/disable tombol OK
    final isOkMixLotEnabled =
        ValueNotifier<bool>(tempController.text.length == 13);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor:
              Colors.transparent, // biar container kamu yang styling
          insetPadding: const EdgeInsets.all(10),
          child: _buildMixLotDialogContent(
            dialogContext,
            tempController,
            isOkMixLotEnabled,
            (fn) => fn(), // localSetState dummy karena kita pakai ValueNotifier
          ),
        );
      },
    );
  }

  Widget _buildMixLotDialogContent(
    BuildContext dialogContext,
    TextEditingController tempController,
    ValueNotifier<bool> isOkMixLotEnabled,
    void Function(void Function()) localSetState,
  ) {
    return Container(
      padding: const EdgeInsets.all(3),
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
        width: MediaQuery.of(dialogContext).size.width * 0.95,
        height: MediaQuery.of(dialogContext).size.width * 0.4,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "MASUKAN MIXING LOT NO",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: tempController,
                inputFormatters: [MixLotFormatter()],
                decoration: InputDecoration(
                  hintText: "MIX LOT NO",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onChanged: (value) {
                  localSetState(() {
                    isOkMixLotEnabled.value = value.length == 13;
                  });
                },
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ CANCEL - outline merah
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade800, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        "CANCEL",
                        style: GoogleFonts.poppins(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // ✅ OK - buildCustomButton dengan ValueListenableBuilder
                ValueListenableBuilder<bool>(
                  valueListenable: isOkMixLotEnabled,
                  builder: (context, enabled, _) {
                    return Expanded(
                      child: buildCustomButton(
                        text: "OK",
                        height: 70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent,
                            Colors.blue.shade900,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        onPressed: enabled
                            ? () {
                                final inputValue = tempController.text;

                                // ✅ Logic tetap sama persis
                                context
                                    .read<MaterialProvider>()
                                    .setManualMixLot(inputValue);

                                if (Navigator.canPop(context)) {
                                  Navigator.of(context).pop();
                                }
                              }
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showMachinePickerDialog(BuildContext context) async {
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
                          // ✅ CANCEL - outline merah
                          Expanded(
                            child: SizedBox(
                              height: 70,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.red.shade800, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(
                                      dialogContext); // ✅ Logic tetap sama
                                },
                                child: Text(
                                  "CANCEL",
                                  style: GoogleFonts.poppins(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ✅ OK - buildCustomButton
                          Expanded(
                            child: buildCustomButton(
                              text: "OK",
                              height: 70,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.blue.shade900,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              onPressed: selectedItem == null
                                  ? null
                                  : () {
                                      provider.selectMachine(
                                          selectedItem!); // ✅ Logic tetap sama
                                      Navigator.pop(
                                          dialogContext); // ✅ Logic tetap sama
                                    },
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

//MENAMPILKAN DIALOG LIST EMPLOYEE

  Future<void> showEmployeeDialog(
      BuildContext context, EmployeeProvider employeeProvider) async {
    EmployeeModel? selectedEmployeeItem;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                        "PILIH OPERATOR",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownSearch<EmployeeModel>(
                        items: (f, cs) => employeeProvider.employeeList,
                        itemAsString: (item) => item.fullName,
                        compareFn: (a, b) => a.idEmployee == b.idEmployee,
                        onChanged: (item) {
                          setState(() {
                            selectedEmployeeItem = item;
                          });
                        },

                        decoratorProps: const DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: "Pilih Operator",
                            hintText: "Nama Operator",
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 12),
                          ),
                        ),

                        // popupProps: PopupProps.menu(showSearchBox: true),

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
                          itemBuilder: (context, EmployeeModel item, isDisabled,
                              isSelected) {
                            final photoUrl =
                                '${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png';
                            final List<Color> gradientColors = isSelected
                                ? [
                                    const Color(0xFF1976D2),
                                    const Color(0xFF0D47A1)
                                  ]
                                : [Colors.white, Colors.blue.shade50];
                            final Color titleColor = isSelected
                                ? Colors.white
                                : Colors.blue.shade800;
                            final Color subtitleColor = isSelected
                                ? Colors.blue.shade200
                                : Colors.grey.shade600;
                            final double elevation = isSelected ? 8 : 2;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isSelected
                                    ? BorderSide(
                                        color: Colors.lightBlue.shade300,
                                        width: 2.5)
                                    : BorderSide(
                                        color: Colors.grey.shade300, width: 1),
                              ),
                              elevation: elevation,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedEmployeeItem = item;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color.fromRGBO(0, 0, 0, 0.3),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: isSelected
                                            ? Colors.white
                                            : Colors.blue.shade100,
                                        child: ClipOval(
                                          child: Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Icon(Icons.person,
                                                    size: 30,
                                                    color: isSelected
                                                        ? Colors.blue.shade800
                                                        : Colors.grey.shade700),
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      item.fullName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: titleColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "NRP: ${item.nrp}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: subtitleColor,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? Icon(Icons.check_circle,
                                            color: Colors.amber.shade300,
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
                          // ✅ CANCEL - outline merah
                          Expanded(
                            child: SizedBox(
                              height: 70,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.red.shade800, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(
                                    dialogContext), // ✅ Logic tetap sama
                                child: Text(
                                  "CANCEL",
                                  style: GoogleFonts.poppins(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ✅ OK - buildCustomButton
                          Expanded(
                            child: buildCustomButton(
                              text: "OK",
                              height: 70,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.blue.shade900,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              onPressed: selectedEmployeeItem == null
                                  ? null
                                  : () {
                                      employeeProvider.selectEmployee(
                                          selectedEmployeeItem!); // ✅ Logic tetap sama
                                      Navigator.pop(
                                          dialogContext); // ✅ Logic tetap sama
                                    },
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

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    double heightApp = MediaQuery.of(context).size.height;
    double paddingTop = MediaQuery.of(context).padding.top;
    bool isTablet = widthApp > 600;
    double screenWidth = MediaQuery.of(context).size.width;

    final myAppBar = customSubAppBar(
      context: context,
      title: 'RECORD PROSES MOLDING VERSI LAMA',
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

            Container(
              width: widthApp,
              height: heightBody * 0.26,
              decoration: BoxDecoration(
                color: Color(0xFFEFF3FF),
                border: Border.all(
                  color: Colors.grey.shade300, // Warna garis
                  width: 2.0, // Lebar garis
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                    8)), // Sudut container yang melengkung (opsional)
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Consumer<EmployeeProvider>(
                          builder: (context, employeeProvider, child) {
                            final employee = employeeProvider.employee;

                            return Container(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 2.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade600, width: 0.5),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Column(
                                children: [
                                  // FOTO EMPLOYEE
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.white, width: 2.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: employee.idEmployee.isEmpty
                                            ? Image.network(
                                                "${AppConfig.baseUrl}/media/img/employee/employee.png",
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                "${AppConfig.baseUrl}/media/img/employee/${employee.idEmployee}.png",
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Image.network(
                                                  "${AppConfig.baseUrl}/media/img/employee/employee.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),

                                  // NAMA & NRP
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            employee.fullName,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                              fontSize:
                                                  constraints.maxWidth * 0.08,
                                            ),
                                          ),
                                          const SizedBox(height: 1.0),
                                          Text(
                                            employee.nrp,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
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
                                      padding: const EdgeInsets.all(1.0),
                                      margin:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            employee.division,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey.shade700,
                                              fontSize:
                                                  constraints.maxWidth * 0.06,
                                            ),
                                          ),
                                          Text(
                                            employee.section,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey.shade700,
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
                  Expanded(
                    flex: 7,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Consumer2<JobNumberProvider, MaterialProvider>(
                          builder: (context, jobNumberProvider,
                              materialProvider, child) {
                            final jobNumber = jobNumberProvider.jobNumber;
                            final batchNumber = jobNumberProvider.batchNumber;
                            final lotNumber = jobNumberProvider.lotNumber;
                            final totalLotNumber =
                                jobNumberProvider.totalLotNumber;
                            final categoryProduct =
                                jobNumberProvider.productCategory;
                            final typeProduct = jobNumberProvider.productType;

                            final jobDate = jobNumberProvider.jobDate;
                            final jobProcess = jobNumberProvider.jobProcess;

                            // --- Ambil data MaterialProvider ---
                            final germanSilverLn = materialProvider
                                .goldPillData.germanSilverLotNumber;
                            final uedaUshinLn = materialProvider
                                .goldPillData.uedaUshinLotNumber;
                            final materialLn =
                                materialProvider.goldPillData.materialLotNumber;
                            // Ganti baris yang error tadi menjadi seperti ini:
                            final carbonLot =
                                materialProvider.carbonPillData.carbonLotNumber;

                            final data = [
                              ["JOB NUMBER", jobNumber],
                              ["DATE", formatDateTime(jobDate)],
                              ["PROCESS", jobProcess],
                              ["JOBCODE", batchNumber],
                              ["LOT NUMBER", lotNumber],
                              ["TOTAL LOT", totalLotNumber],
                              ["CATEGORY", categoryProduct],
                              ["TYPE", typeProduct],
                              [
                                "GOLD PILL LOT",
                                "$germanSilverLn  $uedaUshinLn  $materialLn"
                              ],
                              ["CARBON PILL LOT", carbonLot],
                            ];

                            return Container(
                              height: constraints.maxHeight,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 2),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 0.5),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Table(
                                  border: TableBorder(
                                    bottom: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                    horizontalInside: BorderSide(
                                        color: Colors.grey, width: 0.5),
                                  ),
                                  columnWidths: const {
                                    0: FlexColumnWidth(0.4),
                                    1: FlexColumnWidth(0.6),
                                  },
                                  children: List.generate(data.length, (index) {
                                    final rowColor = index % 2 == 0
                                        ? Colors.grey.shade100
                                        : Colors.white;

                                    return TableRow(
                                      children: [
                                        Container(
                                          color: rowColor,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal: 6.0,
                                          ),
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
                                            maxLines: 1,
                                          ),
                                        ),
                                        Container(
                                          color: rowColor,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal: 6.0,
                                          ),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              ": ${data[index][1]}",
                                              style: GoogleFonts.poppins(
                                                fontWeight: data[index][0] ==
                                                        "JOB NUMBER"
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                fontSize: constraints.maxWidth *
                                                    0.025,
                                                color: Colors.grey.shade800,
                                              ),
                                              softWrap: false,
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
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FF),
                border: Border.all(color: Colors.grey.shade300, width: 2.0),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                int columnCount = constraints.maxWidth > 600 ? 4 : 2;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade600, width: 0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columnCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3.5,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero, // hapus padding default GridView
                    children: [
                      Consumer<JobNumberProvider>(
                        builder: (context, provider, child) {
                          jobNumberController.text = provider.jobNumber;

                          return _buildTextField(
                            controller: jobNumberController,
                            label: "Job Number",
                            hint: "Scan Job Number",
                            icon: Icons.qr_code_scanner,
                            readOnly: true,
                            // onIconTap: () {context.read<JobNumberProvider>().scanJobNumber(context, widget.idProses);
                            onIconTap: () {},
                          );
                        },
                      ),

                      Consumer<MaterialProvider>(
                        builder: (context, provider, child) {
                          mixLotNumberController.text = provider.mixLotNumber;

                          return _buildTextField(
                            controller: mixLotNumberController,
                            label: "Mix Lot No",
                            hint: "Scan Mix Lot",
                            readOnly: true,
                            icon: Icons.qr_code_scanner,
                            onIconTap: () async {
                              // Validasi: JobNumber harus ada
                              final jobProvider =
                                  context.read<JobNumberProvider>();
                              if (jobProvider.jobNumber.isEmpty) {
                                CustomSnackbar.show(
                                    context, "Harap scan Jobnumber dulu",
                                    isSuccess: false);
                                return; // hentikan proses scan
                              }

                              // Proses scan Mix Lot
                              final result = await provider.scanMixLotNumber();
                              if (result == null) {
                                CustomSnackbar.show(
                                    context, "Mix Lot Number tidak ditemukan",
                                    isSuccess: false);
                              }
                            },
                            suffixIcon: IconButton(
                              icon: Icon(Icons.edit_note,
                                  color: Colors.grey.shade700, size: 24),
                              onPressed: () {
                                final jobProvider =
                                    context.read<JobNumberProvider>();
                                if (jobProvider.jobNumber.isEmpty) {
                                  CustomSnackbar.show(
                                      context, "Harap scan Jobnumber dulu",
                                      isSuccess: false);
                                  return; // hentikan edit
                                }
                                onEditMixLotNumber(context);
                              },
                            ),
                          );
                        },
                      ),

                      Consumer<MachineProvider>(
                        builder: (context, provider, child) {
                          idMachineController.text = provider.machine.idMc;

                          return _buildTextField(
                            controller: idMachineController,
                            label: "Machine",
                            hint: "Scan Machine ID",
                            icon: Icons.qr_code_scanner,
                            readOnly: true,
                            onIconTap: () async {
                              // Validasi: Mix Lot No harus sudah diisi

                              final materialProvider =
                                  context.read<MaterialProvider>();

                              if (materialProvider.mixLotNumber.isEmpty) {
                                if (!context.mounted) return;
                                CustomSnackbar.show(
                                  context,
                                  "Harap scan atau isi Mix Lot No dulu",
                                  isSuccess: false,
                                );
                                return;
                              }

                              final code = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MobileScannerPage()),
                              );

                              // print("DEBUG: Hasil scan mesinNYAAAAA: $code"); // Tambahkan ini

                              if (!context.mounted) return;

                              if (code == null ||
                                  code.isEmpty ||
                                  code == "-1") {
                                return;
                              }

                              final error = await provider.scanMachine(code);

                              if (!context.mounted) return;

                              if (error != null) {
                                CustomSnackbar.show(context, error,
                                    isSuccess: false);
                              }
                            },
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search,
                                  color: Colors.grey.shade700),
                              onPressed: () async {
                                // Ambil provider Material untuk validasi Mix Lot No
                                final materialProvider =
                                    context.read<MaterialProvider>();
                                if (materialProvider.mixLotNumber.isEmpty) {
                                  if (!context.mounted) return;
                                  CustomSnackbar.show(
                                    context,
                                    "Harap scan atau isi Mix Lot No dulu",
                                    isSuccess: false,
                                  );
                                  return; // hentikan pilih machine
                                }

                                // Lanjutkan tampilkan machine picker
                                await showMachinePickerDialog(context);
                              },
                            ),
                          );
                        },
                      ),

                      Consumer2<MachineProvider, EmployeeProvider>(
                        builder: (context, machineProvider, employeeProvider,
                            child) {
                          // Update controller dari provider supaya selalu sinkron
                          final employee = employeeProvider.employee;
                          idEmployeeController.text = employee.idEmployee;

                          return _buildTextField(
                            controller: idEmployeeController,
                            label: "Employee",
                            hint: "Scan Employee ID",
                            icon: Icons.qr_code_scanner,
                            readOnly: true,
                            onIconTap: () async {
                              if (employeeProvider.isLoading) return;

                              if (machineProvider.machine.idMc.isEmpty) {
                                CustomSnackbar.show(
                                  context,
                                  "Harap scan QRcode data machine lebih dulu",
                                  isSuccess: false,
                                );
                                return;
                              }

                              // =====================
                              // 1. SCAN DI UI
                              // =====================
                              final code = await Navigator.push<String>(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const MobileScannerPage(),
                                  transitionsBuilder:
                                      (_, animation, __, child) =>
                                          FadeTransition(
                                              opacity: animation, child: child),
                                ),
                              );

                              if (!context.mounted ||
                                  code == null ||
                                  code.isEmpty ||
                                  code == "-1") {
                                return;
                              }

                              // =====================
                              // 2. PROCESS KE PROVIDER
                              // =====================
                              final success =
                                  await employeeProvider.scanEmployee(code);

                              if (!context.mounted) return;

                              // =====================
                              // 3. HANDLE UI FEEDBACK
                              // =====================
                              if (!success) {
                                CustomSnackbar.show(
                                  context,
                                  employeeProvider.errorMessage ??
                                      "Unknown error",
                                  isSuccess: false,
                                );
                              }
                            },
                            suffixIcon: IconButton(
                              icon: Icon(Icons.person_search,
                                  color: Colors.grey.shade700),
                              onPressed: () async {
                                if (employeeProvider.isLoading) return;

                                // VALIDASI Machine dulu
                                if (machineProvider.machine.idMc.isEmpty) {
                                  CustomSnackbar.show(
                                    context,
                                    "Harap scan QRcode data machine lebih dulu",
                                    isSuccess: false,
                                  );
                                  return;
                                }

                                if (employeeProvider.employeeList.isEmpty) {
                                  await employeeProvider.loadEmployees();
                                }
                                if (!context.mounted) return;
                                await showEmployeeDialog(
                                    context, employeeProvider);
                              },
                            ),
                          );
                        },
                      ),

                      // Lanjutkan semua TextField lain, tetap gunakan _buildTextField

                      Consumer<MaterialProvider>(
                        builder: (context, provider, child) {
                          if (!provider.isPillScanned ||
                              provider
                                  .goldPillData.germanSilverLotNumber.isEmpty) {
                            goldPillController.text = "";
                          } else {
                            goldPillController.text =
                                provider.goldPillData.germanSilverLotNumber;
                          }
                          return _buildTextField(
                            controller: goldPillController,
                            label: "Gold Pill",
                            hint: "Gold Pill",
                            icon: Icons.qr_code_scanner,
                            readOnly: true,
                            onIconTap: () async {
                              try {
                                // Navigate to scanner
                                final code = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MobileScannerPage(),
                                  ),
                                );

                                if (code == null ||
                                    code.isEmpty ||
                                    code == "-1") {
                                  return;
                                }

                                // Process QR code
                                await provider.scanGoldPillFromCode(code);

                                if (!context.mounted) return;

                                // Check success: valid ID and no fetch error
                                if (provider.goldPillData.isValid &&
                                    provider.fetchError == null) {
                                  CustomSnackbar.show(
                                    context,
                                    "Gold Pill berhasil discan",
                                    isSuccess: true,
                                  );
                                } else if (provider.fetchError != null) {
                                  CustomSnackbar.show(
                                    context,
                                    "Gagal mengambil detail Gold Pill: ${provider.fetchError}",
                                    isSuccess: false,
                                  );
                                  provider.clearFetchError();
                                } else {
                                  CustomSnackbar.show(
                                    context,
                                    "QR Code tidak valid",
                                    isSuccess: false,
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                CustomSnackbar.show(
                                  context,
                                  "QR Code tidak valid: $e",
                                  isSuccess: false,
                                );
                              }
                            },
                          );
                        },
                      ),

/*DARI SINI YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA */

                      Consumer<MaterialProvider>(
                        builder: (context, provider, child) {
                          if (!provider.isPillScanned ||
                              provider.carbonPillData.carbonLotNumber.isEmpty) {
                            carbonPillController.text = "";
                          } else {
                            carbonPillController.text =
                                provider.carbonPillData.carbonLotNumber;
                          }
                          return _buildTextField(
                            controller: carbonPillController,
                            label: "Carbon Pill",
                            hint: "Carbon Pill",
                            icon: Icons.qr_code_scanner,
                            readOnly: true,
                            onIconTap: () async {
                              try {
                                final code = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MobileScannerPage(),
                                  ),
                                );

                                if (code == null ||
                                    code.isEmpty ||
                                    code == "-1") {
                                  return;
                                }

                                await provider.scanCarbonPillFromCode(code);

                                if (!context.mounted) return;

                                if (provider.carbonPillData.isValid &&
                                    provider.fetchError == null) {
                                  CustomSnackbar.show(
                                    context,
                                    "Carbon Pill berhasil discan",
                                    isSuccess: true,
                                  );
                                } else if (provider.fetchError != null) {
                                  CustomSnackbar.show(
                                    context,
                                    "Gagal mengambil detail Carbon Pill: ${provider.fetchError}",
                                    isSuccess: false,
                                  );
                                  provider.clearFetchError();
                                } else {
                                  CustomSnackbar.show(
                                    context,
                                    "QR Code tidak valid",
                                    isSuccess: false,
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                CustomSnackbar.show(
                                  context,
                                  "QR Code tidak valid: $e",
                                  isSuccess: false,
                                );
                              }
                            },
                          );
                        },
                      ),

                      Consumer<JobNumberProvider>(
                        builder: (context, provider, child) {
                          drawNumberController.text = provider.drawNumber;
                          return _buildTextField(
                            controller: drawNumberController,
                            label: "Draw Number",
                            hint: "Enter Draw No",
                            readOnly: true,
                          );
                        },
                      ),

                      // Qty Lot (read-only)
                      Consumer<JobNumberProvider>(
                        builder: (context, provider, child) {
                          qtyLotController.text = provider.qtyLot;
                          return _buildTextField(
                            controller: qtyLotController,
                            label: "Qty Lot",
                            hint: "Enter Qty Lot",
                            readOnly: true,
                          );
                        },
                      ),

                      Consumer<JobNumberProvider>(
                        builder: (context, provider, child) {
                          return DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: provider.selectedMold,
                              decoration: InputDecoration(
                                labelText: "Mold Number",
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                hintText: "Select",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black54,
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
                                  child: const Icon(Icons.layers,
                                      size: 20, color: Colors.white),
                                ),
                              ),

                              dropdownColor: Colors.white,

                              // FONT DROPDOWN
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),

                              items: provider.molds.isEmpty
                                  ? [
                                      DropdownMenuItem(
                                        value: null,
                                        child: Text(
                                          "Mold",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ]
                                  : provider.molds.map((mold) {
                                      return DropdownMenuItem<String>(
                                        value: mold['tool_number'].toString(),
                                        child: Text(
                                          "Mold No. ${mold['tool_number']}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      );
                                    }).toList(),

                              onChanged: provider.molds.isEmpty
                                  ? null
                                  : (value) {
                                      final mold = provider.molds.firstWhere(
                                        (m) =>
                                            m['tool_number'].toString() ==
                                            value,
                                      );
                                      provider.setSelectedMold(
                                        value,
                                        mold['cavity'].toString(),
                                      );
                                    },
                            ),
                          );
                        },
                      ),

                      Consumer<JobNumberProvider>(
                        builder: (context, provider, child) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (moldCavityController.text != provider.cavity) {
                              moldCavityController.text = provider.cavity;
                            }
                          });

                          return _buildTextField(
                            controller: moldCavityController,
                            label: "Mold Cavity",
                            hint: "Mold Cavity",
                            readOnly: true,
                          );
                        },
                      ),

                      Consumer<JobNumberProvider>(
                        builder: (context, provider, child) {
                          totalShotController.text =
                              provider.totalShoot.toString();
                          return _buildTextField(
                            controller: totalShotController,
                            label: "Total Shoot",
                            hint: "Total Shoot",
                            readOnly: true,
                          );
                        },
                      ),

                      Consumer<JobNumberProvider>(
                        builder: (context, provider, child) {
                          // update controller setiap provider berubah

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            qtyActualController.text = provider.qtyActual;
                          });

                          return TextField(
                            controller: qtyActualController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.green),
                            decoration: InputDecoration(
                              labelText: "Qty Actual",
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            onChanged: (value) {
                              provider.setQtyActual(
                                  value); // optional, kalau user bisa edit
                            },
                          );
                        },
                      )
                    ],
                  ),
                );
              }),
            ),

            // SizedBox(height: 5.0),
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
                    final goldId = materialProvider.goldPillData.id == 0
                        ? ""
                        : materialProvider.goldPillData.id.toString();

                    final carbonId = materialProvider.carbonPillData.isValid
                        ? materialProvider.carbonPillData.id.toString()
                        : "";

                    if (goldId.isEmpty && carbonId.isEmpty) {
                      CustomSnackbar.show(
                          ctx, "Gold Pill or Carbon Pill must be scanned!",
                          isSuccess: false);
                      return;
                    }

                    jobProvider.goldPill = goldId;
                    jobProvider.carbonPill = carbonId;
                  }

                  // Assign data
                  jobProvider.idEmployee = idEmployeeController.text.trim();
                  jobProvider.idMachine = idMachineController.text.trim();
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

/*
    Container(

                width: widthApp,
                height: heightBody * 0.1,
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        flex: 6,
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0, vertical: 2.0),
                                width: constraints.maxWidth * 0.5,
                                height: constraints.maxHeight * 0.9,
                                color: Colors.white,
                                child: SizedBox.expand(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blueAccent,
                                          Colors.blue.shade900
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: OutlinedButton.icon(
                                        label: Consumer<JobNumberProvider>(
                                          builder: (context, jobProvider, _) =>
                                              Text(
                                            jobProvider.isSubmitting
                                                ? "SUBMIT..."
                                                : "SUBMIT",
                                            style: GoogleFonts.poppins(
                                              color: jobProvider.isSubmitting? Colors.grey[400]: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),


                                        onPressed: () async {

                                          final jobProvider =context.read<JobNumberProvider>();
                                          final ngProvider = context.read<NGProvider>();
                                          final materialProvider = context.read<MaterialProvider>();

                                          if (jobProvider.isSubmitting) {
                                            return;
                                          } // tombol disable

                                          // Validasi QRCode / field penting
                                          if (idEmployeeController.text.isEmpty ||idMachineController.text.isEmpty ||mixLotNumberController.text.isEmpty) {
                                            CustomSnackbar.show(
                                              context,
                                              "Please complete QRCode Scanning.",
                                              isSuccess: false,
                                            );
                                            return;
                                          }

                                          // Validasi METAL PILL
                                          if (jobProvider.productCategory == "METAL PILL") {
                                            // Jika ID 0 dianggap kosong/tidak ada
                                            final goldId = materialProvider.goldPillData.id == 0 ? "": materialProvider.goldPillData.id.toString();

                                            // Menggunakan getter .id dari model terbaru
                                            final carbonId = materialProvider
                                                    .carbonPillData.isValid
                                                ? materialProvider
                                                    .carbonPillData.id
                                                    .toString()
                                                : "";

                                            if (goldId.isEmpty &&
                                                carbonId.isEmpty) {
                                              CustomSnackbar.show(
                                                context,
                                                "Gold Pill or Carbon Pill must be scanned!",
                                                isSuccess: false,
                                              );
                                              return;
                                            }

                                            // ⚡ Assign ke JobNumberProvider ID untuk submit backend
                                            jobProvider.goldPill = goldId;
                                            jobProvider.carbonPill = carbonId;
                                          }

                                          // Assign employee & machine
                                          jobProvider.idEmployee =idEmployeeController.text.trim();
                                          jobProvider.idMachine =idMachineController.text.trim();

                                          jobProvider.setSubmitting(true); // tombol disable

                                          try {

                                            bool isSuccess =await jobProvider.submitRecord(ngProvider, context);

                                            if (!context.mounted) return;

                                            if (isSuccess) {
                                              CustomSnackbar.show(
                                                context,
                                                "Data submitted successfully!",
                                                isSuccess: true,
                                              );
                                            } else {
                                              CustomSnackbar.show(
                                                context,
                                                "Failed to submit data.",
                                                isSuccess: false,
                                              );
                                            }
                                          } finally {
                                            if (context.mounted) {
                                              jobProvider.setSubmitting(false);
                                            } // tombol enable lagi
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: BorderSide(
                                              color: Colors.transparent),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0, vertical: 2.0),
                                width: constraints.maxWidth * 0.5,
                                height: constraints.maxHeight * 0.9,
                                color: Colors.white,
                                child: SizedBox.expand(
                                  child: OutlinedButton.icon(
                                    label: Text(
                                      "CLEAR",
                                      style: GoogleFonts.poppins(
                                        color: Colors.blue
                                            .shade800, // tetap bisa pakai .shade
                                        fontSize: 30,
                                        fontWeight:
                                            FontWeight.w600, // biar lebih tegas
                                        letterSpacing:
                                            1.2, // sedikit spasi antar huruf biar elegan
                                      ),
                                    ),
                                    onPressed: () {
                                      final ngProvider =
                                          context.read<NGProvider>();
                                      final jobProvider =
                                          context.read<JobNumberProvider>();
                                      final qtyActualController =
                                          TextEditingController(
                                              text: jobProvider.qtyActual);

                                      // 1. Clear NG Data
                                      ngProvider
                                          .clearAll(); // dataNG, ngTableData, ngItemInputs, qty controller, selected item

                                      // 2. Reset Job & related provider
                                      jobProvider.clearAll(
                                          context, qtyActualController);

                                      // 3. Reset qtyActual di UI (jika pakai controller)
                                      qtyActualController.clear();

                                      // 4. Update QtyActual di JobNumberProvider jadi 0
                                      jobProvider.setQtyActual('');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors
                                            .blue.shade600, // Warna border
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        })),
                    Expanded(
                        flex: 4,
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2.0, vertical: 2.0),
                            width: constraints.maxWidth,
                            height: constraints.maxHeight * 0.9,
                            color: Colors.white,
                            child: SizedBox.expand(
                                // Mengisi seluruh container
                                child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.redAccent,
                                    Colors.red.shade900
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(
                                    15), // Radius untuk sudut tombol
                                border: Border.all(
                                  color: Colors
                                      .transparent, // Tidak ada border solid langsung di Container
                                  width: 1, // Ketebalan border
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      15), // Sudut melengkung pada border
                                ),
                                child: OutlinedButton.icon(
                                  label: Text(
                                    "ADD NG",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 40.0,
                                      fontWeight: FontWeight
                                          .w700, // biar lebih kuat tampilannya
                                      letterSpacing:
                                          1.5, // sedikit jarak antar huruf biar modern
                                    ),
                                  ),
                                  onPressed: () {
                                    final provider =
                                        context.read<JobNumberProvider>();

                                    if (provider.bcode.isEmpty) {
                                      // Menampilkan snackbar jika _bcodeControllers.text kosong

                                      CustomSnackbar.show(
                                        context,
                                        "HARAP SCAN JOBNUMBER TERLEBIH DAHULU!.",
                                        isSuccess: false,
                                      );
                                    } else {
                                      if (provider.isAvailable) {
                                        // Jika _isFinish true, buka dialog full screen
                                        _showFullScreenDialog(
                                            context,
                                            provider.idProcess,
                                            provider.idEmployee,
                                            provider.jobNumber,
                                            provider.productType,
                                            provider.idRecord);
                                      } else {
                                        // Jika _isFinish false, tampilkan snackbar

                                        CustomSnackbar.show(
                                          context,
                                          "START  RECORD PROSES TIDAK BISA MENAMBAHKAN DATA NG.",
                                          isSuccess: false,
                                        );
                                      }
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    // Menghilangkan background yang solid karena sudah menggunakan gradasi dari Container
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors
                                          .transparent, // Border tidak terlihat di OutlinedButton
                                      width:
                                          0, // Border normal tidak diperlukan
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Sudut melengkung pada border
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          );
                        }))
                  ],
                )
        ),
*/

            SizedBox(height: 5.0),

            Container(
              padding: EdgeInsets.all(5),
              width: widthApp,
              height: heightBody * 0.15,
              decoration: BoxDecoration(
                color: Color(0xFFEFF3FF),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Hanya untuk tablet (layar lebar)
                  if (constraints.maxWidth > 600) {
                    return Container(
                      width: double.infinity,
                      height: constraints.maxHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.grey, blurRadius: 4)
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context)
                                .size
                                .width, // full width layar
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Stack(
                              children: [
                                // Background gradient untuk header
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 50, // Sama dengan headingRowHeight
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blueAccent, // biru gelap
                                          Colors.blue.shade900, // biru terang
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),

                                // DataTable dengan header transparan
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0), // posisi DataTable
                                  child: Consumer<NGProvider>(
                                    builder: (context, ngProvider, _) {
                                      final jobProvider =
                                          Provider.of<JobNumberProvider>(
                                              context,
                                              listen: false);
                                      final ngTableData =
                                          ngProvider.ngTableData;

                                      return DataTable(
                                        columnSpacing: 0.2,
                                        horizontalMargin: 0,
                                        headingRowHeight: 50,
                                        dataRowMinHeight: 45,
                                        headingRowColor:
                                            WidgetStateProperty.all(
                                                Colors.transparent),
                                        columns: [
                                          DataColumn(
                                            label: Container(
                                              width: screenWidth * 0.05,
                                              alignment: Alignment.center,
                                              child: Text(
                                                'NO',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Container(
                                              padding:
                                                  EdgeInsets.only(left: 20),
                                              width: screenWidth * 0.4,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'NG NAME',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Container(
                                              width: screenWidth * 0.3,
                                              alignment: Alignment.center,
                                              child: Text(
                                                'DRAW NO',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Container(
                                              width: screenWidth * 0.1,
                                              alignment: Alignment.center,
                                              child: Text(
                                                'QTY',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Container(
                                              width: screenWidth * 0.1,
                                              alignment: Alignment.center,
                                              child: Text(
                                                'DELETE',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: ngTableData
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int index = entry.key;
                                          var data = entry.value;

                                          Color rowColor = (index % 2 == 0)
                                              ? Colors.white
                                              : const Color(0xFFEFF3FF);

                                          return DataRow(
                                            key: ValueKey(data['id_ng']),
                                            color: WidgetStateProperty.all(
                                                rowColor),
                                            cells: [
                                              DataCell(Center(
                                                  child: Text("${index + 1}"))),
                                              DataCell(
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: Text(
                                                        data['ng_name'] ??
                                                            'Unknown'),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: Consumer<
                                                      JobNumberProvider>(
                                                    builder: (context,
                                                        jobProvider, _) {
                                                      return Text(jobProvider
                                                          .drawNumber);
                                                    },
                                                  ),
                                                ),
                                              ),
                                              DataCell(Center(
                                                  child: Text(
                                                      "${data['qty'] ?? 0}"))),
                                              DataCell(
                                                Center(
                                                  child: IconButton(
                                                    icon: Icon(Icons.delete,
                                                        color:
                                                            Colors.red.shade700,
                                                        size: 20),
                                                    onPressed: () {
                                                      ngProvider.deleteNG(
                                                          data['id_ng'],
                                                          jobProvider);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // Jika tidak tablet, kembalikan Container kosong
                  return SizedBox.shrink();
                },
              ),
            ),

            SizedBox(height: 5.0),

            Container(
              // padding: EdgeInsets.all(5),
              width: widthApp,
              height: heightBody * 0.2,
              // color: Colors.grey.shade500,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)],
              ),

              child: LayoutBuilder(builder: (context, constraints) {
                return Consumer2<MachineProvider, JobNumberProvider>(
                  builder: (context, machineProvider, jobProvider, child) {
                    final machineData = machineProvider.machine;
                    final customer =
                        jobProvider.customer; // ambil dari provider
                    final totalShootView = jobProvider.totalShoot
                        .toString(); // misal totalShoot dari provider
                    final lotQuantity =
                        jobProvider.qtyLot; // contoh dari provider
                    final cavity = jobProvider.cavity;

                    final List<List<String>> dataRows = [
                      ["MACHINE", machineData.nmMc],
                      ["MACHINE AREA", machineData.areaMc],
                      [
                        "CUSTOMER",
                        customer
                      ], // otomatis update kalau provider berubah
                      ["MOLD CAVITY", cavity],
                      ["TOTAL SHOT", totalShootView],
                      ["QTY LOT", lotQuantity],
                    ];

                    return Container(
                      width: constraints.maxWidth,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Table(
                          border: TableBorder(
                            bottom: BorderSide(color: Colors.grey, width: 1.0),
                            horizontalInside:
                                BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          columnWidths: {
                            0: FlexColumnWidth(constraints.maxWidth * 0.4),
                            1: FlexColumnWidth(constraints.maxWidth * 0.6),
                          },
                          children: List.generate(dataRows.length, (index) {
                            final rowColor = index % 2 == 0
                                ? Colors.grey[200]!
                                : Colors.white;
                            return _buildTableRow(
                              dataRows[index][0],
                              dataRows[index][1],
                              constraints,
                              isTablet,
                              rowColor,
                            );
                          }),
                        ),
                      ),
                    );
                  },
                );
              }),
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

  TableRow _buildTableRow(String label, String value,
      BoxConstraints constraints, bool isTablet, Color rowColor) {
    return TableRow(
      children: [
        Container(
          color: rowColor,
          padding: EdgeInsets.symmetric(
              vertical: isTablet ? 4.0 : 2.0, horizontal: isTablet ? 6.0 : 3.0),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: isTablet
                  ? constraints.maxWidth * 0.025
                  : constraints.maxWidth * 0.04,
              color: Colors.grey.shade800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          color: rowColor,
          padding: EdgeInsets.symmetric(
              vertical: isTablet ? 4.0 : 2.0, horizontal: isTablet ? 6.0 : 3.0),
          child: Text(
            ": $value",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: isTablet
                  ? constraints.maxWidth * 0.025
                  : constraints.maxWidth * 0.04,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
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
                addOrUpdateNG: addOrUpdateNG,
                printNgTableData: printNgTableData,
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

class NumBlockKeyboardDialog extends StatefulWidget {
  final String idProses;
  final Function(String, String, int, String, String, String, int)
      addOrUpdateNG;
  final Function printNgTableData; //Ini tambahan baru.
  final String idEmployee;
  final String jobNumber;
  final String idRecordUpdate;
  final int qtyShoot;
  final String typeProduct;

  const NumBlockKeyboardDialog({
    super.key,
    required this.idProses,
    required this.addOrUpdateNG,
    required this.printNgTableData,
    required this.idEmployee,
    required this.jobNumber,
    required this.idRecordUpdate,
    required this.qtyShoot,
    required this.typeProduct,
  });

  @override
  _NumBlockKeyboardDialogState createState() => _NumBlockKeyboardDialogState();
}

class _NumBlockKeyboardDialogState extends State<NumBlockKeyboardDialog> {
  final TextEditingController _quantityNgController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isNumBlockVisible = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return; // cek widget masih ada
      final ngProvider = context.read<NGProvider>();

      if (!ngProvider.hasLoadedForThisRecord) {
        ngProvider
            .loadNGList(
          productType: widget.typeProduct,
          idProses: widget.idProses,
        )
            .then((_) {
          ngProvider.hasLoadedForThisRecord = true;

          _initNgItemInputs(ngProvider);
          setState(() {}); // rebuild UI supaya ListView muncul
        });
      }
    });

    // Listener untuk memantau fokus pada TextField
    _focusNode.addListener(() {
      setState(() {
        _isNumBlockVisible = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _quantityNgController.dispose();
    super.dispose();
  }

  void _onNumPressed(String num) {
    final ngProvider = context.read<NGProvider>();
    final controller = ngProvider.quantityNgController;

    if (controller.text.length < 3) {
      controller.text += num;
      ngProvider.notifySubmitStateChanged(); // <-- update tombol submit
    }
  }

  void _backspace() {
    final ngProvider = context.read<NGProvider>();
    final controller = ngProvider.quantityNgController;

    setState(() {
      if (controller.text.isNotEmpty) {
        controller.text =
            controller.text.substring(0, controller.text.length - 1);
      }

      ngProvider.notifySubmitStateChanged();
    });
  }

  void _closeNumBlock() {
    setState(() {
      _isNumBlockVisible = false;
      _focusNode.unfocus();
    });
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _initNgItemInputs(NGProvider ngProvider) {
    ngProvider.ngItemInputs =
        ngProvider.listNG.map((ng) => NgItemInput(ngItem: ng)).toList();
  }

  @override
  Widget build(BuildContext context) {
    //MENENTUKAN LEBAR APLIKASI****************
    double widthApp = MediaQuery.of(context).size.width;
    //MENENTUKAN TINGGI APLIKASI**********************
    double heightApp = MediaQuery.of(context).size.height;
    //MENENTUKAN TINGGI TOP APLIKASI PALING ATAS**********
    double paddingTop = MediaQuery.of(context).padding.top;

    final appBar2 = PreferredSize(
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
            automaticallyImplyLeading: false,
            title: Text(
              'ADD NG PRODUCT',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight
                    .normal, // bisa diganti bold/semibold sesuai kebutuhan
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
          )),
    );
    double heightBody = heightApp - paddingTop - appBar2.preferredSize.height;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            'ADD NG',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.w600, // bisa bold atau semi-bold
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                _closeDialog(); // menutup halaman/dialog
              },
            ),
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50), // total height bottom
              child: Column(
                children: [
                  // Garis pemisah tipis
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TabBar(
                      // --- VISUAL KEREN DAN CERAH ---
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50), // Sudut kapsul
                        gradient: LinearGradient(
                          colors: [
                            Colors.white, // Putih cerah
                            Colors.grey.shade200, // Abu lembut
                            Colors.grey.shade400, // Abu sedang
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,

                      // Warna teks
                      labelColor: Colors.blueGrey
                          .shade900, // teks aktif kontras dengan background terang
                      unselectedLabelColor:
                          Colors.grey.shade200, // teks tidak aktif lebih soft

                      // Styling font
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),

                      // Isi Tabs
                      tabs: const [
                        Tab(
                          height: 45,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("ADD PER ITEM NG"),
                          ),
                        ),
                        Tab(
                          height: 45,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("ADD MASS ITEM NG"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              )),
        ),
        body: TabBarView(
          children: [
            // ============================
            // Tab 1: Single Input (DropdownSearch + QTY)
            // ============================
            Container(
              padding: const EdgeInsets.all(5.0),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  width: widthApp * 1,
                  height: heightBody * 0.75,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade700,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Stack(
                    children: [
                      // Bagian utama: Row yang berisi DropdownSearch dan TextField

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Bagian kiri: Konten teks

                          Expanded(
                            flex: 7,
                            child: Container(
                              alignment: Alignment.topCenter,
                              color: Colors.white,
                              padding: EdgeInsets.all(5.0),
                              child: Consumer<NGProvider>(
                                builder: (context, ngProvider, child) {
                                  // === LOADING ===
                                  if (ngProvider.isLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  // === ERROR ===
                                  if (ngProvider.errorMessage != null) {
                                    return Center(
                                      child: Text(
                                        ngProvider.errorMessage!,
                                        style: GoogleFonts.poppins(
                                          color: Colors.red,
                                          fontSize: 14, // bisa disesuaikan
                                          fontWeight: FontWeight
                                              .w500, // optional, bisa bold atau normal
                                        ),
                                      ),
                                    );
                                  }

                                  // === DATA KOSONG ===
                                  if (ngProvider.listNG.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "Tidak ada data NG tersedia.",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16, // sesuaikan ukuran
                                          fontWeight: FontWeight
                                              .w400, // normal, bisa diubah ke bold jika mau
                                          color: Colors
                                              .black, // ganti sesuai kebutuhan
                                        ),
                                      ),
                                    );
                                  }

                                  // === TAMPILKAN DROPDOWN ===
                                  return DropdownSearch<NgDropdownModel>(
                                    items: (f, cs) => ngProvider.listNG,
                                    itemAsString: (NgDropdownModel? item) =>
                                        item?.ngName ?? '',
                                    compareFn: (a, b) => a.idNg == b.idNg,
                                    onChanged: (NgDropdownModel? selected) {
                                      if (selected != null) {
                                        ngProvider.selectedNgCode =
                                            selected.idNg;
                                        ngProvider.selectedNgItem =
                                            selected.ngName;

                                        // _updateSubmitButtonState();

                                        logPrint(
                                            'Selected: ${selected.idNg} - ${selected.ngName}');
                                      }
                                    },
                                    decoratorProps: DropDownDecoratorProps(
                                      decoration: InputDecoration(
                                        labelText: "NG ITEM",
                                        hintText: "PILIH NG",
                                        labelStyle: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade900,
                                        ),
                                        hintStyle: GoogleFonts.poppins(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade600,
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                      searchFieldProps: TextFieldProps(
                                        decoration: InputDecoration(
                                          labelText: "Search NG",
                                          hintText: "Search...",
                                          labelStyle: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade900,
                                          ),
                                          hintStyle: GoogleFonts.poppins(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey.shade600,
                                          ),
                                          prefixIcon: const Icon(Icons.search),
                                          border: const OutlineInputBorder(),
                                        ),
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        keyboardType: TextInputType.text,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      itemBuilder: (context, item, isDisabled,
                                          isSelected) {
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 10.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          elevation: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue.shade400,
                                                  Colors.blue.shade800,
                                                ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: ListTile(
                                                title: Text(
                                                  item.ngName,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 26.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pop(item);
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      scrollbarProps: const ScrollbarProps(
                                        trackVisibility: true,
                                        thumbVisibility: true,
                                      ),
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.64,
                                        minWidth:
                                            MediaQuery.of(context).size.width *
                                                0.98,
                                      ),
                                      menuProps: const MenuProps(
                                        margin: EdgeInsets.only(top: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Bagian kanan: Kolom dengan TextField
                          Expanded(
                            flex: 3,
                            child: Container(
                              alignment: Alignment.topCenter,
                              color: Colors.white,
                              padding: const EdgeInsets.all(5.0),
                              child: Consumer<NGProvider>(
                                builder: (context, ngProvider, child) {
                                  return Column(
                                    children: [
                                      TextField(
                                        controller:
                                            ngProvider.quantityNgController,
                                        readOnly: true, // karena pakai NumBlock
                                        focusNode: _focusNode,
                                        style: GoogleFonts.poppins(),
                                        decoration: InputDecoration(
                                            labelText: 'QTY',
                                            border: OutlineInputBorder()),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // NumBlock - ditempatkan di atas seluruh layout
                      if (_isNumBlockVisible) ...[
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: NumBlock(
                              onNumPressed: _onNumPressed,
                              onBackspace: _backspace,
                              onClose: _closeNumBlock,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                //Sampai sini ya *****************
                const SizedBox(height: 5.0),

                Container(
                    width: widthApp * 1,
                    height: heightBody * 0.12,
                    margin: const EdgeInsets.only(
                        top: 10.0), // Margin hanya di atas
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0, vertical: 2.0),
                              width: constraints.maxWidth * 0.5,
                              height: constraints.maxHeight * 1,
                              color: Colors.white,
                              child: SizedBox.expand(
                                child: OutlinedButton(
                                  onPressed: () {
                                    _closeDialog();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white, // latar belakang putih
                                    side: BorderSide(
                                      color:
                                          Colors.blue.shade800, // border biru
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ).copyWith(
                                    // efek saat ditekan (hover/press)
                                    overlayColor: WidgetStateProperty.all(
                                      Colors.blue.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Text(
                                    "CANCEL",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue.shade800, // teks biru
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0, vertical: 2.0),
                              width: constraints.maxWidth * 0.5,
                              height: constraints.maxHeight * 1,
                              child: Consumer<NGProvider>(
                                builder: (context, ngProvider, child) {
                                  final jobProvider =
                                      context.read<JobNumberProvider>();

                                  return SizedBox.expand(
                                    child: ElevatedButton(
                                      onPressed: ngProvider.isSubmitEnabled
                                          ? () {
                                              final quantity = int.tryParse(
                                                      ngProvider
                                                          .quantityNgController
                                                          .text) ??
                                                  0;

                                              if (ngProvider.selectedNgCode != null &&
                                                  ngProvider.selectedNgItem !=
                                                      null &&
                                                  quantity > 0) {
                                                // Tambah atau update NG di provider
                                                ngProvider.addOrUpdateNG(
                                                  code: ngProvider
                                                      .selectedNgCode!,
                                                  name: ngProvider
                                                      .selectedNgItem!,
                                                  quantity: quantity,
                                                  idRecord:
                                                      widget.idRecordUpdate,
                                                  idEmployee: widget.idEmployee,
                                                  jobNumber: widget.jobNumber,
                                                  qtyShoot: widget.qtyShoot,
                                                );

                                                // Reset input modal
                                                ngProvider.selectedNgCode =
                                                    null;
                                                ngProvider.selectedNgItem =
                                                    null;
                                                ngProvider.quantityNgController
                                                    .clear();

                                                // Update Qty Actual = Qty Lot - total NG
                                                jobProvider
                                                    .updateQtyActualBasedOnNG(
                                                        ngProvider
                                                            .getTotalNG());

                                                // Tutup modal
                                                Navigator.of(context).pop();
                                              }
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        padding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ).copyWith(
                                        overlayColor:
                                            WidgetStateProperty.resolveWith(
                                                (states) {
                                          if (states
                                              .contains(WidgetState.disabled)) {
                                            return Colors.transparent;
                                          }
                                          return Colors.white.withAlpha(25);
                                        }),
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: ngProvider.isSubmitEnabled
                                              ? LinearGradient(
                                                  colors: [
                                                    Colors.blueAccent,
                                                    Colors.blue.shade900
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    Colors.grey.shade400,
                                                    Colors.grey.shade500
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "SUBMIT",
                                            style: GoogleFonts.poppins(
                                              color: ngProvider.isSubmitEnabled
                                                  ? Colors.white
                                                  : Colors.grey.shade200,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    })),
              ]),
            ),

            // ============================
            // Tab 2: Batch Input (pakai wrapper class NgItemInput)

            // ============================

            Container(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<NGProvider>(
                builder: (context, ngProvider, child) {
                  // Initialize ngItemInputs hanya sekali
                  if (ngProvider.ngItemInputs.isEmpty &&
                      ngProvider.listNG.isNotEmpty) {
                    ngProvider.ngItemInputs = ngProvider.listNG
                        .map((ng) => NgItemInput(ngItem: ng))
                        .toList();
                  }

                  return ngProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            SizedBox(
                              height: heightApp * 0.73,
                              child: ListView.builder(
                                itemCount: ngProvider.ngItemInputs.length,
                                itemBuilder: (context, index) {
                                  final ngInput =
                                      ngProvider.ngItemInputs[index];
                                  return Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 5),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade400,
                                            Colors.blue.shade800
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 8,
                                            child: Text(
                                              ngInput.ngItem.ngName,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                // Decrease
                                                SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor:
                                                          Colors.red.shade500,
                                                      shape:
                                                          const CircleBorder(),
                                                    ),
                                                    onPressed: () {
                                                      ngProvider
                                                          .decreaseQty(index);
                                                    },
                                                    child: const Icon(
                                                        Icons.remove,
                                                        size: 18,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                // TextField
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        ngInput.controller,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      hintText: "QTY",
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                              color: Colors.grey
                                                                  .shade500,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  width: 1.5)),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .blue,
                                                                      width:
                                                                          2)),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 8,
                                                              horizontal: 8),
                                                    ),
                                                    onChanged: (value) {
                                                      ngProvider
                                                          .updateQtyFromTextField(
                                                              index, value);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                // Increase
                                                SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor:
                                                          Colors.green,
                                                      shape:
                                                          const CircleBorder(),
                                                    ),
                                                    onPressed: () {
                                                      ngProvider
                                                          .increaseQty(index);
                                                    },
                                                    child: const Icon(Icons.add,
                                                        size: 18,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            // CANCEL & SUBMIT
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // CANCEL
                                Expanded(
                                  child: SizedBox(
                                    height: 100,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                            color: Colors.blue.shade800,
                                            width: 2),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                      ),
                                      child: Text(
                                        "CANCEL",
                                        style: GoogleFonts.poppins(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade800),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                // SUBMIT

                                Expanded(
                                  child: SizedBox(
                                    height: 100,
                                    child: ElevatedButton(
                                      onPressed: ngProvider.isAnyQtyMoreThanZero
                                          ? () {
                                              // Submit NG ke NGProvider
                                              ngProvider.submitNgItems(
                                                idRecord: widget.idRecordUpdate,
                                                idEmployee: widget.idEmployee,
                                                jobNumber: widget.jobNumber,
                                                qtyShoot: widget.qtyShoot,
                                              );

                                              // Hitung total NG
                                              int totalNG =
                                                  ngProvider.getTotalNG();

                                              // Update qtyActual di JobNumberProvider
                                              final jobProvider = Provider.of<
                                                      JobNumberProvider>(
                                                  context,
                                                  listen: false);
                                              jobProvider
                                                  .updateQtyActualBasedOnNG(
                                                      totalNG);

                                              Navigator.of(context).pop();
                                            }
                                          : null,
                                      style: ButtonStyle(
                                        shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15))),
                                        padding: WidgetStateProperty.all(
                                            EdgeInsets.zero),
                                        backgroundColor:
                                            WidgetStateProperty.resolveWith(
                                                (states) {
                                          if (states
                                              .contains(WidgetState.disabled)) {
                                            return Colors.grey.shade400;
                                          }
                                          return null;
                                        }),
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          gradient: ngProvider
                                                  .isAnyQtyMoreThanZero
                                              ? LinearGradient(
                                                  colors: [
                                                    Colors.blueAccent,
                                                    Colors.blue.shade900
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    Colors.grey.shade400,
                                                    Colors.grey.shade500
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "SUBMIT",
                                            style: GoogleFonts.poppins(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600,
                                              color: ngProvider
                                                      .isAnyQtyMoreThanZero
                                                  ? Colors.white
                                                  : Colors.grey.shade200,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NumBlock extends StatelessWidget {
  final Function(String) onNumPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClose;

  const NumBlock({
    super.key, // <-- pakai super parameter
    required this.onNumPressed,
    required this.onBackspace,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    double screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(builder: (context, constraints) {
      return GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: screenWidth / 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          String buttonText;
          VoidCallback onPress;

          if (index == 9) {
            buttonText = '0';
            onPress = () => onNumPressed(buttonText);
          } else if (index == 10) {
            buttonText = 'CLEAR';
            onPress = onBackspace;
          } else if (index == 11) {
            buttonText = 'OK';
            onPress = onClose;
          } else {
            buttonText = (index + 1).toString();
            onPress = () => onNumPressed(buttonText);
          }

          return GestureDetector(
            onTap: onPress,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade800
                  ], // Gradasi biru
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight
                      .w600, // optional, biar teksnya sedikit lebih tegas
                ),
              ),
            ),
          );
        },
      );
    });
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
