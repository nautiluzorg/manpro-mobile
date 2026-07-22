import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import '../dialogs/mix_lot_dialog.dart';
import '../dialogs/machine_picker_dialog.dart';
import '../dialogs/employee_picker_dialog.dart';
import '../utils/mix_lot_formatter.dart';
import 'package:flutter_provider_data/utils/logger.dart';

// NOTE: `buildTextField(...)` is used exactly as in the original
// record_testing.dart. It wasn't defined in that file either, so keep
// whichever import your project already uses for it (it's a shared widget
// helper elsewhere in the codebase).

/// The scan-driven input grid: Job Number, Mix Lot No, Machine, Employee,
/// Gold Pill, Carbon Pill (all QR-scan fields), Mold Number dropdown, and
/// the read-only Qty field.
///
/// Extracted verbatim from record_testing.dart's GridView.count block.
/// All scan/validation logic and provider calls are unchanged — only
/// moved out of the giant build() method.
class ScanFormGrid extends StatelessWidget {
  final String idProses;
  final TextEditingController jobNumberController;
  final TextEditingController mixLotNumberController;
  final TextEditingController idMachineController;
  final TextEditingController idEmployeeController;
  final TextEditingController goldPillController;
  final TextEditingController carbonPillController;
  final TextEditingController qtyActualController;

  const ScanFormGrid({
    super.key,
    required this.idProses,
    required this.jobNumberController,
    required this.mixLotNumberController,
    required this.idMachineController,
    required this.idEmployeeController,
    required this.goldPillController,
    required this.carbonPillController,
    required this.qtyActualController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TestingProvider>(
      builder: (context, prov, _) {
        final String qtyTest = prov.selectedMoldCavity?.toString() ?? '';

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
          if (idEmployeeController.text != prov.employee.idEmployee) {
            idEmployeeController.text = prov.employee.idEmployee;
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

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
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
              readOnly: true,
              onIconTap: () => _scanJobNumber(context, prov),
            ),
            buildTextField(
              controller: mixLotNumberController,
              label: "Mix Lot",
              hint: "MixLotNo",
              icon: Icons.qr_code_scanner,
              readOnly: true,
              inputFormatters: [MixLotFormatter()],
              onIconTap: () => _scanMixLot(context, prov),
              suffixIcon: IconButton(
                icon: Icon(Icons.edit_note,
                    color: Colors.grey.shade600, size: 24),
                onPressed: () => _editMixLot(context, prov),
              ),
            ),
            buildTextField(
              controller: idMachineController,
              label: "Mch",
              hint: "Scan Machine ID",
              icon: Icons.qr_code_scanner,
              readOnly: true,
              onIconTap: () => _scanMachine(context),
              suffixIcon: IconButton(
                icon: Icon(Icons.search, size: 24, color: Colors.grey.shade600),
                onPressed: () => _pickMachine(context),
              ),
            ),
            buildTextField(
              controller: idEmployeeController,
              label: "Emp",
              hint: "Scan Employee ID",
              icon: Icons.qr_code_scanner,
              readOnly: true,
              onIconTap: () => _scanEmployee(context),
              suffixIcon: IconButton(
                icon: Icon(Icons.person_search,
                    size: 24, color: Colors.grey.shade700),
                onPressed: () => _pickEmployee(context),
              ),
            ),
            buildTextField(
              controller: goldPillController,
              label: "Gold Pill",
              hint: "Gold Pill",
              icon: Icons.qr_code_scanner,
              readOnly: true,
              onIconTap: () => _scanGoldPill(context, prov),
            ),
            buildTextField(
              controller: carbonPillController,
              label: "Carbon Pill",
              hint: "Carbon Pill",
              icon: Icons.qr_code_scanner,
              readOnly: true,
              onIconTap: () => _scanCarbonPill(context, prov),
            ),
            _MoldDropdown(prov: prov),
            buildTextField(
              controller: qtyActualController,
              label: "Qty",
              hint: "Qty Test",
              readOnly: true,
            ),
          ],
        );
      },
    );
  }

  // ---------------- Scan handlers (unchanged logic) ----------------

  Future<void> _scanJobNumber(
      BuildContext context, TestingProvider prov) async {
    final qrCode = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );
    if (qrCode == null || qrCode.isEmpty) return;

    try {
      await prov.scanJobNumber(qrCode: qrCode, idProses: idProses);
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackbar.show(context, e.toString(), isSuccess: false);
    }
  }

  Future<void> _scanMixLot(BuildContext context, TestingProvider prov) async {
    if (!prov.isJobNumberScanned) {
      CustomSnackbar.show(
        context,
        "Mohon Scan Job Number terlebih dahulu.",
        isSuccess: false,
      );
      return;
    }

    try {
      await prov.scanMixLotNumberFromCamera(context: context);
      mixLotNumberController.text = prov.mixLotNo;
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackbar.show(context, e.toString(), isSuccess: false);
    }
  }

  void _editMixLot(BuildContext context, TestingProvider prov) {
    if (!prov.isJobNumberScanned) {
      CustomSnackbar.show(
        context,
        "Mohon Scan Job Number terlebih dahulu.",
        isSuccess: false,
      );
      return;
    }

    showMixLotEntryDialog(
      context,
      initialValue: mixLotNumberController.text,
      onConfirm: (value) => prov.setMixLotNo(value),
    );
  }

  Future<void> _scanMachine(BuildContext context) async {
    final machineProvider = context.read<MachineProvider>();
    final testingProvider = context.read<TestingProvider>();

    if (machineProvider.isLoading) return;

    try {
      testingProvider.validateBeforeScanMachine();
    } catch (e) {
      CustomSnackbar.show(context, e.toString(), isSuccess: false);
      return;
    }

    final qrCode = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );
    if (qrCode == null || qrCode.isEmpty || qrCode == "-1") return;
    if (!context.mounted) return;

    final error = await machineProvider.setMachineByIdTesting(qrCode);
    if (!context.mounted) return;

    if (error != null) {
      CustomSnackbar.show(context, error, isSuccess: false);
      return;
    }

    testingProvider.setMachine(machineProvider.machine);
  }

  Future<void> _pickMachine(BuildContext context) async {
    final testingProv = context.read<TestingProvider>();
    try {
      testingProv.validateBeforeScanMachine();
    } catch (e) {
      CustomSnackbar.show(context, e.toString(), isSuccess: false);
      return;
    }
    await showMachinePickerDialog(context);
  }

  Future<void> _scanEmployee(BuildContext context) async {
    final testingProv = context.read<TestingProvider>();

    try {
      testingProv.validateBeforeScanEmployee();
    } catch (e) {
      CustomSnackbar.show(context, e.toString(), isSuccess: false);
      return;
    }

    final qrCode = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );
    if (qrCode == null || qrCode.isEmpty || qrCode == "-1") return;
    if (!context.mounted) return;

    final employeeProvider = context.read<EmployeeProvider>();
    final success = await employeeProvider.scanEmployee(qrCode);
    if (!context.mounted) return;

    if (!success) {
      CustomSnackbar.show(
        context,
        employeeProvider.errorMessage ?? "Scan employee gagal",
        isSuccess: false,
      );
      return;
    }

    testingProv.setEmployee(employeeProvider.employee);
  }

  Future<void> _pickEmployee(BuildContext context) async {
    final testingProv = context.read<TestingProvider>();
    try {
      testingProv.validateBeforeScanEmployee();
    } catch (e) {
      CustomSnackbar.show(context, e.toString(), isSuccess: false);
      return;
    }
    await showEmployeePickerDialog(context);
  }

  Future<void> _scanGoldPill(
      BuildContext context, TestingProvider testingProv) async {
    final materialProv = context.read<MaterialProvider>();

    if (!testingProv.isJobNumberScanned) {
      CustomSnackbar.show(
        context,
        "Mohon Scan Job Number terlebih dahulu.",
        isSuccess: false,
      );
      return;
    }

    try {
      final qrCode = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const MobileScannerPage()),
      );
      if (qrCode == null || qrCode.isEmpty || qrCode == "-1") return;

      await materialProv.scanGoldPillFromCode(qrCode);

      if (!materialProv.isPillScanned || !materialProv.goldPillData.isValid) {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          "QR code tidak valid atau bukan Gold Pill",
          isSuccess: false,
        );
        return;
      }

      final goldPill = materialProv.goldPillData;
      testingProv.setGoldPill(goldPill);
      goldPillController.text = testingProv.goldPillLot;
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackbar.show(
        context,
        "Error scan Gold Pill: ${e.toString()}",
        isSuccess: false,
      );
    }
  }

  Future<void> _scanCarbonPill(
      BuildContext context, TestingProvider testingProv) async {
    final materialProv = context.read<MaterialProvider>();

    if (!testingProv.isJobNumberScanned) {
      CustomSnackbar.show(
        context,
        "Mohon Scan Job Number terlebih dahulu.",
        isSuccess: false,
      );
      return;
    }

    try {
      final qrCode = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const MobileScannerPage()),
      );
      if (qrCode == null || qrCode.isEmpty || qrCode == "-1") return;

      await materialProv.scanCarbonPillFromCode(qrCode);

      if (!materialProv.isPillScanned || !materialProv.carbonPillData.isValid) {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          "QR code tidak valid atau bukan Carbon Pill",
          isSuccess: false,
        );
        return;
      }

      final carbonPill = materialProv.carbonPillData;
      testingProv.setCarbonPill(carbonPill);
      carbonPillController.text = testingProv.carbonPillLot;
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackbar.show(
        context,
        "Error scan Carbon Pill: ${e.toString()}",
        isSuccess: false,
      );
    }
  }
}

class _MoldDropdown extends StatelessWidget {
  final TestingProvider prov;

  const _MoldDropdown({required this.prov});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(prov.selectedMold.toolNumber),
      isExpanded: true,
      initialValue:
          prov.selectedMold.isValid ? prov.selectedMold.toolNumber : null,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: const OutlineInputBorder(),
        prefixIcon: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.grey.shade500, width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.layers, size: 20, color: Colors.white),
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 14.0, color: Colors.black87),
      dropdownColor: Colors.white,
      items: prov.molds.isEmpty
          ? null
          : prov.molds.map((mold) {
              return DropdownMenuItem<String>(
                value: mold.toolNumber,
                child: Text(
                  "Mold No. ${mold.toolNumber}",
                  style: GoogleFonts.poppins(
                      fontSize: 13.0, color: Colors.black87),
                ),
              );
            }).toList(),
      onChanged: prov.molds.isEmpty
          ? null
          : (value) {
              if (value != null) prov.selectMold(value);
            },
    );
  }
}
