import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
// import '../dialogs/machine_picker_dialog.dart';
// import '../dialogs/employee_dialog.dart';

class RecordFormGrid extends StatelessWidget {
  const RecordFormGrid({
    super.key,
    required this.idProses,
    required this.mixLotNumberController,
    required this.idEmployeeController,
    required this.goldPillController,
    required this.carbonPillController,
    required this.idMachineController,
    required this.jobNumberController,
    required this.onBuildTextField,
    required this.onEditMixLotNumber,
  });

  final String idProses;
  final TextEditingController mixLotNumberController;
  final TextEditingController idEmployeeController;
  final TextEditingController goldPillController;
  final TextEditingController carbonPillController;
  final TextEditingController idMachineController;
  final TextEditingController jobNumberController;

  final Widget Function({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    bool readOnly,
    VoidCallback? onIconTap,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) onBuildTextField;

  final void Function(BuildContext context) onEditMixLotNumber;

  Widget _fieldGap() => const SizedBox(width: 12);

  Future<String?> _scan(BuildContext context) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withAlpha(18),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _jobNumberField(context)),
              _fieldGap(),
              Expanded(child: _mixLotField(context)),
              _fieldGap(),
              Expanded(child: _machineField(context)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _employeeField(context)),
              _fieldGap(),
              Expanded(child: _goldPillField(context)),
              _fieldGap(),
              Expanded(child: _carbonPillField(context)),
            ],
          ),
          const SizedBox(height: 8),
          _moldField(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _jobNumberField(BuildContext context) {
    return Consumer<JobNumberProvider>(
      builder: (context, provider, child) {
        jobNumberController.text = provider.jobNumber;
        return onBuildTextField(
          controller: jobNumberController,
          label: 'JOB NUMBER',
          hint: 'JOB NUMBER',
          icon: Icons.qr_code_scanner,
          readOnly: true,
          onIconTap: () async {
            final scanned = await _scan(context);
            if (!context.mounted ||
                scanned == null ||
                scanned.isEmpty ||
                scanned == '-1') {
              return;
            }

            final jobProvider = context.read<JobNumberProvider>();
            final success = await jobProvider.scanJobNumber(
              scanned,
              idProses,
              onEmployeeFound: (data) {
                context
                    .read<EmployeeProvider>()
                    .selectEmployee(EmployeeModel.fromJson(data));
              },
              onMachineFound: (data) {
                context.read<MachineProvider>().setMachineDataFromMap(data);
              },
              onMaterialFound: ({
                required mixLot,
                required goldId,
                required goldGerman,
                required goldUeda,
                required goldMaterial,
                required carbonId,
                required carbon,
              }) {
                context.read<MaterialProvider>().setMaterialFromJobNumber(
                      mixLot: mixLot,
                      goldId: goldId,
                      goldGerman: goldGerman,
                      goldUeda: goldUeda,
                      goldMaterial: goldMaterial,
                      carbonId: carbonId,
                      carbon: carbon,
                    );
              },
            );

            if (!context.mounted || success) return;
            CustomSnackbar.show(
              context,
              jobProvider.errorMessage ?? 'Scan gagal.',
              isSuccess: false,
            );
          },
        );
      },
    );
  }

  Widget _mixLotField(BuildContext context) {
    return Consumer<MaterialProvider>(
      builder: (context, provider, child) {
        mixLotNumberController.text = provider.mixLotNumber;
        return onBuildTextField(
          controller: mixLotNumberController,
          label: 'MPCS',
          hint: 'MPCS',
          readOnly: true,
          icon: Icons.qr_code_scanner,
          onIconTap: () async {
            final jobProvider = context.read<JobNumberProvider>();
            if (jobProvider.jobNumber.isEmpty) {
              CustomSnackbar.show(
                context,
                'Harap scan Jobnumber dulu ye',
                isSuccess: false,
              );
              return;
            }

            final code = await _scan(context);
            if (!context.mounted ||
                code == null ||
                code.isEmpty ||
                code == '-1') {
              return;
            }

            if (!provider.setMixLotFromScan(code)) {
              CustomSnackbar.show(
                context,
                'Format Mix Lot Number tidak valid',
                isSuccess: false,
              );
            }
          },
          suffixIcon: IconButton(
            icon: Icon(Icons.edit, color: Colors.grey.shade700, size: 19),
            onPressed: () {
              final jobProvider = context.read<JobNumberProvider>();
              if (jobProvider.jobNumber.isEmpty) {
                CustomSnackbar.show(
                  context,
                  'Harap scan Jobnumber dulu',
                  isSuccess: false,
                );
                return;
              }
              onEditMixLotNumber(context);
            },
          ),
        );
      },
    );
  }

  Widget _machineField(BuildContext context) {
    return Consumer<MachineProvider>(
      builder: (context, provider, child) {
        idMachineController.text = provider.machine.idMc;
        return onBuildTextField(
          controller: idMachineController,
          label: 'MACHINE',
          hint: 'MACHINE',
          readOnly: true,
          icon: Icons.qr_code_scanner,
          onIconTap: () async {
            final materialProvider = context.read<MaterialProvider>();
            if (materialProvider.mixLotNumber.isEmpty) {
              CustomSnackbar.show(
                context,
                'Harap scan atau isi Mix Lot No dulu',
                isSuccess: false,
              );
              return;
            }

            final code = await _scan(context);
            if (!context.mounted ||
                code == null ||
                code.isEmpty ||
                code == '-1') {
              return;
            }

            final error = await provider.scanMachine(code);
            if (!context.mounted || error == null) return;
            CustomSnackbar.show(context, error, isSuccess: false);
          },
          /*
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: Colors.grey.shade700, size: 19),
            onPressed: () async {
              final materialProvider = context.read<MaterialProvider>();
              if (materialProvider.mixLotNumber.isEmpty) {
                CustomSnackbar.show(
                  context,
                  'Harap scan atau isi Mix Lot No dulu',
                  isSuccess: false,
                );
                return;
              }
              await showMachinePickerDialog(context);
            },
          ),
          */
        );
      },
    );
  }

  Widget _employeeField(BuildContext context) {
    return Consumer2<MachineProvider, EmployeeProvider>(
      builder: (context, machineProvider, employeeProvider, child) {
        idEmployeeController.text = employeeProvider.employee.idEmployee;
        return onBuildTextField(
          controller: idEmployeeController,
          label: 'OPERATOR',
          hint: 'OPERATOR',
          readOnly: true,
          icon: Icons.qr_code_scanner,
          onIconTap: () async {
            if (employeeProvider.isLoading) return;
            if (machineProvider.machine.idMc.isEmpty) {
              CustomSnackbar.show(
                context,
                'Harap scan QRcode data machine lebih dulu',
                isSuccess: false,
              );
              return;
            }

            final code = await _scan(context);
            if (!context.mounted ||
                code == null ||
                code.isEmpty ||
                code == '-1') {
              return;
            }

            final success = await employeeProvider.scanEmployee(code);
            if (!context.mounted || success) return;
            CustomSnackbar.show(
              context,
              employeeProvider.errorMessage ?? 'Unknown error',
              isSuccess: false,
            );
          },
          /*
          suffixIcon: IconButton(
            icon: Icon(
              Icons.manage_accounts,
              color: Colors.grey.shade700,
              size: 19,
            ),
            onPressed: () async {
              if (employeeProvider.isLoading) return;
              if (machineProvider.machine.idMc.isEmpty) {
                CustomSnackbar.show(
                  context,
                  'Harap scan QRcode data machine lebih dulu',
                  isSuccess: false,
                );
                return;
              }

              if (employeeProvider.employeeList.isEmpty) {
                await employeeProvider.loadEmployees();
              }
              if (!context.mounted) return;
              await showEmployeeDialog(context, employeeProvider);
            },
          ),
          */
        );
      },
    );
  }

  Widget _goldPillField(BuildContext context) {
    return Consumer<MaterialProvider>(
      builder: (context, provider, child) {
        goldPillController.text = provider.isPillScanned &&
                provider.goldPillData.germanSilverLotNumber.isNotEmpty
            ? provider.goldPillData.germanSilverLotNumber
            : '';

        return onBuildTextField(
          controller: goldPillController,
          label: 'GOLD PILL',
          hint: 'GOLD PILL',
          readOnly: true,
          icon: Icons.qr_code_scanner,
          onIconTap: () => _scanGoldPill(context, provider),
        );
      },
    );
  }

  Widget _carbonPillField(BuildContext context) {
    return Consumer<MaterialProvider>(
      builder: (context, provider, child) {
        carbonPillController.text = provider.isPillScanned &&
                provider.carbonPillData.carbonLotNumber.isNotEmpty
            ? provider.carbonPillData.carbonLotNumber
            : '';

        return onBuildTextField(
          controller: carbonPillController,
          label: 'CARBON PILL',
          hint: 'CARBON PILL',
          readOnly: true,
          icon: Icons.qr_code_scanner,
          onIconTap: () => _scanCarbonPill(context, provider),
        );
      },
    );
  }

  Future<void> _scanGoldPill(
    BuildContext context,
    MaterialProvider provider,
  ) async {
    try {
      final code = await _scan(context);
      if (!context.mounted || code == null || code.isEmpty || code == '-1') {
        return;
      }

      await provider.scanGoldPillFromCode(code);
      if (!context.mounted) return;
      if (provider.fetchError != null) {
        CustomSnackbar.show(
          context,
          'Gagal mengambil detail Gold Pill: ${provider.fetchError}',
          isSuccess: false,
        );
        provider.clearFetchError();
      } else if (!provider.goldPillData.isValid) {
        CustomSnackbar.show(context, 'QR Code tidak valid', isSuccess: false);
      }
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackbar.show(context, 'QR Code tidak valid: $e', isSuccess: false);
    }
  }

  Future<void> _scanCarbonPill(
    BuildContext context,
    MaterialProvider provider,
  ) async {
    try {
      final code = await _scan(context);
      if (!context.mounted || code == null || code.isEmpty || code == '-1') {
        return;
      }

      await provider.scanCarbonPillFromCode(code);
      if (!context.mounted) return;
      if (provider.fetchError != null) {
        CustomSnackbar.show(
          context,
          'Gagal mengambil detail Carbon Pill: ${provider.fetchError}',
          isSuccess: false,
        );
        provider.clearFetchError();
      } else if (!provider.carbonPillData.isValid) {
        CustomSnackbar.show(context, 'QR Code tidak valid', isSuccess: false);
      }
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackbar.show(context, 'QR Code tidak valid: $e', isSuccess: false);
    }
  }

  Widget _moldField() {
    const double fieldHeight = 65;
    const double fieldRadius = 4;
    const double innerRadius = fieldRadius - 1;
    const double iconBoxWidth = 58;
    const double iconSize = 30;

    return Consumer<JobNumberProvider>(
      builder: (context, provider, child) {
        final selected = provider.selectedMold;
        final hasValue = selected != null && selected.isNotEmpty;
        final enabled = provider.molds.isNotEmpty;

        return InkWell(
          borderRadius: BorderRadius.circular(fieldRadius),
          onTap: enabled ? () => _showMoldGridDialog(context, provider) : null,
          child: InputDecorator(
            isEmpty: !hasValue,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(fieldRadius),
                borderSide: BorderSide(color: Colors.blueGrey.shade100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(fieldRadius),
                borderSide: BorderSide(color: Colors.blueGrey.shade200),
              ),
              prefixIcon: Container(
                width: iconBoxWidth,
                height: fieldHeight,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(innerRadius),
                  ),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: iconBoxWidth,
                maxWidth: iconBoxWidth,
                minHeight: fieldHeight,
                maxHeight: fieldHeight,
              ),
              suffixIcon: Container(
                width: iconBoxWidth,
                height: fieldHeight,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(innerRadius),
                  ),
                ),
                child: Icon(
                  Icons.grid_view_rounded, // ikon grid, bukan panah lagi
                  size: iconSize,
                  color: Colors.grey.shade700,
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: iconBoxWidth,
                maxWidth: iconBoxWidth,
                minHeight: fieldHeight,
                maxHeight: fieldHeight,
              ),
            ),
            child: Text(
              hasValue ? 'MOLD  $selected' : 'MOLD',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: hasValue
                    ? Colors.blueGrey.shade800
                    : Colors.blueGrey.shade400,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMoldGridDialog(
    BuildContext context,
    JobNumberProvider provider,
  ) {
    final selected = provider.selectedMold;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.layers_rounded,
                          color: Colors.blue.shade600, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'PILIH MOLD',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: Icon(Icons.close_rounded,
                            color: Colors.blueGrey.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: provider.molds.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 120, // lebar max tiap kotak
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.4,
                      ),
                      itemBuilder: (context, index) {
                        final mold = provider.molds[index];
                        final value = mold['tool_number'].toString();
                        final isSelected = value == selected;

                        return Material(
                          color: isSelected
                              ? Colors.blue.shade600
                              : const Color(0xFFF8FAFC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue.shade600
                                  : Colors.blueGrey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              provider.setSelectedMold(
                                value,
                                mold['cavity'].toString(),
                              );
                              Navigator.pop(dialogContext);
                            },
                            child: Center(
                              child: Text(
                                'MOLD $value',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.blueGrey.shade800,
                                ),
                              ),
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

/*
  Widget _moldField() {
    // Samakan dengan nilai di _buildTextField
    const double fieldHeight = 65;
    const double fieldRadius = 4;
    const double innerRadius = fieldRadius - 1;
    const double iconBoxWidth = 58;
    const double iconSize = 26;

    return Consumer<JobNumberProvider>(
      builder: (context, provider, child) {
        return DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: provider.selectedMold,
            // Icon panah dikosongkan, diganti suffixIcon custom di decoration
            icon: const SizedBox.shrink(),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              hintText: 'MOLD',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
              prefixIcon: Container(
                width: iconBoxWidth,
                height: fieldHeight,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(innerRadius),
                  ),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: iconBoxWidth,
                maxWidth: iconBoxWidth,
                minHeight: fieldHeight,
                maxHeight: fieldHeight,
              ),
              suffixIcon: Container(
                width: iconBoxWidth,
                height: fieldHeight,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(innerRadius),
                  ),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: iconSize,
                  color: Colors.grey.shade700,
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: iconBoxWidth,
                maxWidth: iconBoxWidth,
                minHeight: fieldHeight,
                maxHeight: fieldHeight,
              ),
            ),
            dropdownColor: Colors.white,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
            items: provider.molds.map<DropdownMenuItem<String>>((mold) {
              return DropdownMenuItem<String>(
                value: mold['tool_number'].toString(),
                child: Text(
                  'MOLD  ${mold['tool_number']}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              );
            }).toList(),
            onChanged: provider.molds.isEmpty
                ? null
                : (value) {
                    final mold = provider.molds.firstWhere(
                      (m) => m['tool_number'].toString() == value,
                    );
                    provider.setSelectedMold(value, mold['cavity'].toString());
                  },
          ),
        );
      },
    );
  }

  */
}
