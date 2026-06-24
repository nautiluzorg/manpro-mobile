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
import '../dialogs/machine_picker_dialog.dart';
import '../dialogs/employee_dialog.dart';

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
    required this.drawNumberController,
    required this.qtyLotController,
    required this.moldCavityController,
    required this.totalShotController,
    required this.qtyActualController,
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
  final TextEditingController drawNumberController;
  final TextEditingController qtyLotController;
  final TextEditingController moldCavityController;
  final TextEditingController totalShotController;
  final TextEditingController qtyActualController;

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final int columnCount = constraints.maxWidth > 600 ? 4 : 2;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FF),
          border: Border.all(color: Colors.grey.shade300, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: LayoutBuilder(builder: (context, gridConstraints) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            width: gridConstraints.maxWidth,
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
              padding: EdgeInsets.zero,
              children: [
                // JOB NUMBER

                Consumer<JobNumberProvider>(
                  builder: (context, provider, child) {
                    jobNumberController.text = provider.jobNumber;
                    return onBuildTextField(
                      controller: jobNumberController,
                      label: 'Job Number',
                      hint: 'Scan Job Number',
                      icon: Icons.qr_code_scanner,
                      readOnly: true,
                      onIconTap: () async {
                        final scanned = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MobileScannerPage()),
                        );

                        if (scanned == null ||
                            scanned.isEmpty ||
                            scanned == '-1') {
                          return;
                        }
                        if (!context.mounted) return;

                        final jobProvider = context.read<JobNumberProvider>();

                        final success = await jobProvider.scanJobNumber(
                          scanned,
                          idProses,
                          onEmployeeFound: (data) {
                            final employee = EmployeeModel.fromJson(data);
                            context
                                .read<EmployeeProvider>()
                                .selectEmployee(employee);
                          },
                          onMachineFound: (data) {
                            context
                                .read<MachineProvider>()
                                .setMachineDataFromMap(data);
                          },
                          onMaterialFound: ({
                            required mixLot,
                            required goldId, // ← tambah
                            required goldGerman,
                            required goldUeda,
                            required goldMaterial,
                            required carbonId, // ← tambah
                            required carbon,
                          }) {
                            context
                                .read<MaterialProvider>()
                                .setMaterialFromJobNumber(
                                  mixLot: mixLot,
                                  goldId: goldId, // ← tambah
                                  goldGerman: goldGerman,
                                  goldUeda: goldUeda,
                                  goldMaterial: goldMaterial,
                                  carbonId: carbonId, // ← tambah
                                  carbon: carbon,
                                );
                          },
                        );

                        if (!context.mounted) return;

                        // ✅ Ambil errorMessage dari provider jika gagal
                        if (!success) {
                          CustomSnackbar.show(
                            context,
                            jobProvider.errorMessage ?? "Scan gagal.",
                            isSuccess: false,
                          );
                        }
                      },
                    );
                  },
                ),

                // MIX LOT
                Consumer<MaterialProvider>(
                  builder: (context, provider, child) {
                    mixLotNumberController.text = provider.mixLotNumber;
                    return onBuildTextField(
                      controller: mixLotNumberController,
                      label: 'Mix Lot No',
                      hint: 'Scan Mix Lot',
                      readOnly: true,
                      icon: Icons.qr_code_scanner,
                      onIconTap: () async {
                        final jobProvider = context.read<JobNumberProvider>();
                        if (jobProvider.jobNumber.isEmpty) {
                          CustomSnackbar.show(
                            context,
                            'Harap scan Jobnumber dulu',
                            isSuccess: false,
                          );
                          return;
                        }

                        final result = await provider.scanMixLotNumber();
                        if (!context.mounted) return;
                        if (result == null) {
                          CustomSnackbar.show(
                            context,
                            'Mix Lot Number tidak ditemukan',
                            isSuccess: false,
                          );
                        }
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.edit_note,
                          color: Colors.grey.shade700,
                          size: 24,
                        ),
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
                ),

                // MACHINE

                Consumer<MachineProvider>(
                  builder: (context, provider, child) {
                    idMachineController.text = provider.machine.idMc;
                    return onBuildTextField(
                      controller: idMachineController,
                      label: 'Machine',
                      hint: 'Scan Machine ID',
                      icon: Icons.qr_code_scanner,
                      readOnly: true,
                      onIconTap: () async {
                        final materialProvider =
                            context.read<MaterialProvider>();
                        if (materialProvider.mixLotNumber.isEmpty) {
                          if (!context.mounted) return;
                          CustomSnackbar.show(
                            context,
                            'Harap scan atau isi Mix Lot No dulu',
                            isSuccess: false,
                          );
                          return;
                        }

                        final code = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MobileScannerPage(),
                          ),
                        );

                        if (!context.mounted) return;

                        if (code == null || code.isEmpty || code == '-1') {
                          return;
                        }

                        final error = await provider.scanMachine(code);
                        if (!context.mounted) return;

                        if (error != null) {
                          CustomSnackbar.show(
                            context,
                            error,
                            isSuccess: false,
                          );
                        }
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.grey.shade700,
                        ),
                        onPressed: () async {
                          final materialProvider =
                              context.read<MaterialProvider>();
                          if (materialProvider.mixLotNumber.isEmpty) {
                            if (!context.mounted) return;
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
                    );
                  },
                ),

                // EMPLOYEE
                Consumer2<MachineProvider, EmployeeProvider>(
                  builder: (context, machineProvider, employeeProvider, child) {
                    final employee = employeeProvider.employee;
                    idEmployeeController.text = employee.idEmployee;

                    return onBuildTextField(
                      controller: idEmployeeController,
                      label: 'Employee',
                      hint: 'Scan Employee ID',
                      icon: Icons.qr_code_scanner,
                      readOnly: true,
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

                        final code = await Navigator.push<String>(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                const MobileScannerPage(),
                            transitionsBuilder: (_, animation, __, page) =>
                                FadeTransition(opacity: animation, child: page),
                          ),
                        );

                        if (!context.mounted ||
                            code == null ||
                            code.isEmpty ||
                            code == '-1') {
                          return;
                        }

                        final success =
                            await employeeProvider.scanEmployee(code);
                        if (!context.mounted) return;

                        if (!success) {
                          CustomSnackbar.show(
                            context,
                            employeeProvider.errorMessage ?? 'Unknown error',
                            isSuccess: false,
                          );
                        }
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.person_search,
                          color: Colors.grey.shade700,
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
                    );
                  },
                ),

                // GOLD PILL
                Consumer<MaterialProvider>(
                  builder: (context, provider, child) {
                    if (!provider.isPillScanned ||
                        provider.goldPillData.germanSilverLotNumber.isEmpty) {
                      goldPillController.text = '';
                    } else {
                      goldPillController.text =
                          provider.goldPillData.germanSilverLotNumber;
                    }

                    return onBuildTextField(
                      controller: goldPillController,
                      label: 'Gold Pill',
                      hint: 'Gold Pill',
                      icon: Icons.qr_code_scanner,
                      readOnly: true,
                      onIconTap: () async {
                        try {
                          final code = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MobileScannerPage(),
                            ),
                          );

                          // User cancel scan
                          if (code == null || code.isEmpty || code == '-1') {
                            return;
                          }

                          await provider.scanGoldPillFromCode(code);

                          if (!context.mounted) return;

                          // Error dari API / provider
                          if (provider.fetchError != null) {
                            CustomSnackbar.show(
                              context,
                              'Gagal mengambil detail Gold Pill: ${provider.fetchError}',
                              isSuccess: false,
                            );

                            provider.clearFetchError();
                            return;
                          }

                          // QR tidak valid / data kosong
                          if (!provider.goldPillData.isValid) {
                            CustomSnackbar.show(
                              context,
                              'QR Code tidak valid',
                              isSuccess: false,
                            );

                            return;
                          }
                        } catch (e) {
                          if (!context.mounted) return;

                          CustomSnackbar.show(
                            context,
                            'QR Code tidak valid: $e',
                            isSuccess: false,
                          );
                        }
                      },
                    );
                  },
                ),

                // CARBON PILL
                Consumer<MaterialProvider>(
                  builder: (context, provider, child) {
                    if (!provider.isPillScanned ||
                        provider.carbonPillData.carbonLotNumber.isEmpty) {
                      carbonPillController.text = '';
                    } else {
                      carbonPillController.text =
                          provider.carbonPillData.carbonLotNumber;
                    }

                    return onBuildTextField(
                      controller: carbonPillController,
                      label: 'Carbon Pill',
                      hint: 'Carbon Pill',
                      icon: Icons.qr_code_scanner,
                      readOnly: true,
                      onIconTap: () async {
                        try {
                          final code = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MobileScannerPage(),
                            ),
                          );

                          // User cancel scan
                          if (code == null || code.isEmpty || code == '-1') {
                            return;
                          }

                          await provider.scanCarbonPillFromCode(code);

                          if (!context.mounted) return;

                          // Error dari API / provider
                          if (provider.fetchError != null) {
                            CustomSnackbar.show(
                              context,
                              'Gagal mengambil detail Carbon Pill: ${provider.fetchError}',
                              isSuccess: false,
                            );

                            provider.clearFetchError();
                            return;
                          }

                          // QR tidak valid / data kosong
                          if (!provider.carbonPillData.isValid) {
                            CustomSnackbar.show(
                              context,
                              'QR Code tidak valid',
                              isSuccess: false,
                            );

                            return;
                          }

                          // SUCCESS
                          // Tidak perlu snackbar sukses
                          // UI otomatis update dari provider
                        } catch (e) {
                          if (!context.mounted) return;

                          CustomSnackbar.show(
                            context,
                            'QR Code tidak valid: $e',
                            isSuccess: false,
                          );
                        }
                      },
                    );
                  },
                ),

                // DRAW NUMBER
                Consumer<JobNumberProvider>(
                  builder: (context, provider, child) {
                    drawNumberController.text = provider.drawNumber;
                    return onBuildTextField(
                      controller: drawNumberController,
                      label: 'Draw Number',
                      hint: 'Enter Draw No',
                      readOnly: true,
                    );
                  },
                ),

                // QTY LOT
                Consumer<JobNumberProvider>(
                  builder: (context, provider, child) {
                    qtyLotController.text = provider.qtyLot;
                    return onBuildTextField(
                      controller: qtyLotController,
                      label: 'Qty Lot',
                      hint: 'Enter Qty Lot',
                      readOnly: true,
                    );
                  },
                ),

                // MOLD NUMBER (Dropdown)
                Consumer<JobNumberProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: provider.selectedMold,
                        decoration: InputDecoration(
                          labelText: 'Mold Number',
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          hintText: 'Select',
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
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        items: provider.molds.isEmpty
                            ? [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'Mold',
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
                                    'Mold No. ${mold['tool_number']}',
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
                                  (m) => m['tool_number'].toString() == value,
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

                // MOLD CAVITY
                Consumer<JobNumberProvider>(
                  builder: (context, provider, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (moldCavityController.text != provider.cavity) {
                        moldCavityController.text = provider.cavity;
                      }
                    });

                    return onBuildTextField(
                      controller: moldCavityController,
                      label: 'Mold Cavity',
                      hint: 'Mold Cavity',
                      readOnly: true,
                    );
                  },
                ),

                // TOTAL SHOT
                Consumer<JobNumberProvider>(
                  builder: (context, provider, child) {
                    totalShotController.text = provider.totalShoot.toString();
                    return onBuildTextField(
                      controller: totalShotController,
                      label: 'Total Shoot',
                      hint: 'Total Shoot',
                      readOnly: true,
                    );
                  },
                ),

                // QTY ACTUAL
                Consumer<JobNumberProvider>(
                  builder: (context, provider, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      qtyActualController.text = provider.qtyActual;
                    });

                    return TextField(
                      controller: qtyActualController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Qty Actual',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (value) {
                        provider.setQtyActual(value);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }),
      );
    });
  }
}
