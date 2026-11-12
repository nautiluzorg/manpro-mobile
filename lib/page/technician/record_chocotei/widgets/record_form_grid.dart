import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/master/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:flutter_provider_data/page/technician/record_chocotei/dialogs/draw_no_picker_dialog.dart';

class RecordFormGrid extends StatelessWidget {
  const RecordFormGrid({
    super.key,
    required this.idProses,
    required this.idMachineController,
    required this.jobNumberController,
    required this.problemController,
    required this.actionController,
    required this.onBuildTextField,
  });

  final String idProses;
  final TextEditingController idMachineController;
  final TextEditingController jobNumberController;
  final TextEditingController problemController;
  final TextEditingController actionController;

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

  // ================= WARNA TEMA (BIRU) =================
  static const Color _blue = Color(0xFF1E88E5); // = Colors.blue.shade600

  // ================= GRADIENT TEMA (BIRU) =================
  // static final (bukan const) karena Colors.blue.shade900 bukan konstanta
  static final LinearGradient _blueGradient = LinearGradient(
    colors: [Colors.blueAccent, Colors.blue.shade900],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ================= PILIHAN DROPDOWN =================
  static const List<_DropOption> _problemOptions = [
    _DropOption('SCHEDULE', Icons.opacity_rounded),
    _DropOption('SHINNING', Icons.content_cut_rounded),
    _DropOption('DIRTY WINDOW', Icons.south_rounded),
    _DropOption('SHADOW', Icons.local_fire_department_rounded),
    _DropOption('LACK OF RUBBER', Icons.bubble_chart_rounded),
    _DropOption('VINYL', Icons.timeline_rounded),
    _DropOption('OTHERS', Icons.more_horiz_rounded),
  ];

  static const List<_DropOption> _actionOptions = [
    _DropOption('WASHING MOLD DUE TO SCHEDULE', Icons.tune_rounded),
    _DropOption(
        'CHANGE MOLD BASE ON WEEKLY SCHEDULE', Icons.thermostat_rounded),
    _DropOption('DRY ICE OR POLISHING', Icons.speed_rounded),
    _DropOption(
        'CHANGE MOLD CAUSE OTHER REASON', Icons.cleaning_services_rounded),
    _DropOption('WASHING MOLD DUE TO QUALITY PROBLEM', Icons.settings_rounded),
  ];

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

          // ===== BARIS 1: MACHINE | JOB NUMBER | MOLD =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _machineField(context)),
              _fieldGap(),
              Expanded(child: _drawNumberField(context)),
              _fieldGap(),
              Expanded(child: _moldField()),
            ],
          ),
          const SizedBox(height: 8),

          // ===== BARIS 2: PROBLEM (dropdown, full) =====
          _dropdownField(
            context: context,
            controller: problemController,
            label: 'CONDITION',
            icon: Icons.report_problem_rounded,
            options: _problemOptions,
          ),
          const SizedBox(height: 8),

          // ===== BARIS 3: ACTION (dropdown, full) =====
          _dropdownField(
            context: context,
            controller: actionController,
            label: 'ACTION TAKEN',
            icon: Icons.build_rounded,
            options: _actionOptions,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ================= DROPDOWN (PROBLEM & ACTION) =================
  // Nilai terpilih disimpan di controller.text (isinya label pilihan).
  Widget _dropdownField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<_DropOption> options,
  }) {
    const double fieldHeight = 65;
    const double fieldRadius = 4;
    const double innerRadius = fieldRadius - 1;
    const double iconBoxWidth = 58;
    const double iconSize = 30;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        _DropOption? selected;
        for (final o in options) {
          if (o.label == value.text) selected = o;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(fieldRadius),
          onTap: () => _showOptionSheet(
            context: context,
            controller: controller,
            title: label,
            headerIcon: icon,
            options: options,
          ),
          child: InputDecorator(
            isEmpty: selected == null,
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
                borderSide: BorderSide(
                  color: selected != null ? _blue : Colors.blueGrey.shade200,
                  width: selected != null ? 1.5 : 1,
                ),
              ),
              // ===== KOTAK IKON KIRI: GRADIENT =====
              prefixIcon: Container(
                width: iconBoxWidth,
                height: fieldHeight,
                decoration: BoxDecoration(
                  gradient: _blueGradient,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(innerRadius),
                  ),
                ),
                child: Icon(icon, size: iconSize, color: Colors.white),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: iconBoxWidth,
                maxWidth: iconBoxWidth,
                minHeight: fieldHeight,
                maxHeight: fieldHeight,
              ),
              suffixIcon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 32,
                color: Colors.grey.shade700,
              ),
            ),
            child: selected == null
                ? Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blueGrey.shade400,
                    ),
                  )
                : Row(
                    children: [
                      Icon(selected.icon, size: 20, color: _blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selected.label,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<void> _showOptionSheet({
    required BuildContext context,
    required TextEditingController controller,
    required String title,
    required IconData headerIcon,
    required List<_DropOption> options,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,

      constraints:
          const BoxConstraints(maxWidth: double.infinity), // UBAH: lebar full
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),

      builder: (sheetContext) {
        final current = controller.text;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // handle bar
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'PILIH $title',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: Colors.blueGrey.shade100),

                // daftar pilihan
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final o = options[index];
                      final isSelected = o.label == current;

                      return Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: _blueGradient,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade900
                                    .withAlpha(isSelected ? 110 : 50),
                                offset: const Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () {
                              controller.text = o.label;
                              Navigator.pop(sheetContext);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white24,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      o.icon,
                                      size: 24,
                                      color: isSelected ? _blue : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      o.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.chevron_right_rounded,
                                    color: Colors.white,
                                  ),
                                ],
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
        );
      },
    );
  }

  // ================= MACHINE =================
  Widget _machineField(BuildContext context) {
    return Consumer<MachineProvider>(
      builder: (context, provider, child) {
        idMachineController.text = provider.machine.nmMc;
        return onBuildTextField(
          controller: idMachineController,
          label: 'MACHINE',
          hint: 'MACHINE',
          readOnly: true,
          icon: Icons.qr_code_scanner,
          onIconTap: () async {
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
        );
      },
    );
  }

  // ================= DRAW NO =================
  Widget _drawNumberField(BuildContext context) {
    return Consumer<JobNumberProvider>(
      builder: (context, provider, child) {
        jobNumberController.text = provider.drawNumber;
        return onBuildTextField(
          controller: jobNumberController,
          label: 'DRAW NO',
          hint: 'SELECT DRAW NO',
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

            final success = await provider.scanJobNumber(
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
              provider.errorMessage ?? 'Scan Draw No gagal.',
              isSuccess: false,
            );
          },
          suffixIcon: IconButton(
            tooltip: 'Pilih Draw No',
            icon: Icon(
              Icons.search_rounded,
              size: 28,
              color: Colors.blue.shade800,
            ),
            onPressed: () => _showDrawNoPicker(context, provider),
          ),
        );
      },
    );
  }

  Future<void> _showDrawNoPicker(
    BuildContext context,
    JobNumberProvider provider,
  ) async {
    final selected = await showDialog<ProductModel>(
      context: context,
      builder: (_) => const DrawNoPickerDialog(),
    );

    if (!context.mounted || selected == null) return;

    await provider.setProductFromDrawing(selected);
    jobNumberController.text = selected.drawingNumber;
  }

  // ================= MOLD =================
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
              // ===== KOTAK IKON KIRI: GRADIENT =====
              prefixIcon: Container(
                width: iconBoxWidth,
                height: fieldHeight,
                decoration: BoxDecoration(
                  gradient: _blueGradient,
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
          insetPadding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 24), // UBAH: tadinya 24
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: double.infinity, // UBAH: tadinya 520
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
                      const Icon(Icons.layers_rounded, color: _blue, size: 22),
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
                        maxCrossAxisExtent: 120,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.4,
                      ),
                      itemBuilder: (context, index) {
                        final mold = provider.molds[index];
                        final value = mold['tool_number'].toString();
                        final isSelected = value == selected;

                        // ===== ITEM MOLD: GRADIENT KALAU TERPILIH =====
                        return Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: isSelected ? _blueGradient : null,
                              color:
                                  isSelected ? null : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? _blue
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
}

// ================= MODEL PILIHAN DROPDOWN =================
class _DropOption {
  final String label;
  final IconData icon;

  const _DropOption(this.label, this.icon);
}

// ================= TABLE ACTION TAKEN =================
class _ActionTrackingTable extends StatefulWidget {
  final String title;
  final String codePrefix;
  final List<String> rows;

  const _ActionTrackingTable({
    required this.title,
    required this.codePrefix,
    required this.rows,
  });

  @override
  State<_ActionTrackingTable> createState() => _ActionTrackingTableState();
}

class _ActionTrackingTableState extends State<_ActionTrackingTable> {
  static const Color _blue = Color(0xFF1E88E5);

  late final List<DateTime?> _startTimes =
      List<DateTime?>.filled(widget.rows.length, null);
  late final List<DateTime?> _finishTimes =
      List<DateTime?>.filled(widget.rows.length, null);

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _status(int i) {
    if (_finishTimes[i] != null) return 'SELESAI';
    if (_startTimes[i] != null) return 'PROSES';
    return 'MENUNGGU';
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _textCell(String text, {bool bold = false, TextAlign? align}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        textAlign: align ?? TextAlign.left,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: Colors.blueGrey.shade800,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required DateTime? time,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: enabled ? null : Colors.blueGrey.shade100,
            borderRadius: BorderRadius.circular(4),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.blue.shade900.withAlpha(50),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: enabled ? onTap : null,
            child: Center(
              child: Text(
                time != null ? '$label ${_fmt(time)}' : label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: enabled ? Colors.white : Colors.blueGrey.shade400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusCell(String status) {
    final isDone = status == 'SELESAI';
    final isProcess = status == 'PROSES';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isDone
              ? LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isDone
              ? null
              : isProcess
                  ? _blue.withAlpha(28)
                  : Colors.blueGrey.shade50,
          border: Border.all(
            color: isDone || isProcess ? _blue : Colors.blueGrey.shade200,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDone
                ? Colors.white
                : isProcess
                    ? _blue
                    : Colors.blueGrey.shade500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withAlpha(18),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== JUDUL TABLE =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.build_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== TABLE =====
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.blueGrey.shade100),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(3.2),
                2: FlexColumnWidth(1.8),
                3: FlexColumnWidth(1.8),
                4: FlexColumnWidth(1.6),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue.shade900],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  children: [
                    _headerCell('KODE'),
                    _headerCell('ACTION TAKEN'),
                    _headerCell('START'),
                    _headerCell('FINISH'),
                    _headerCell('STATUS'),
                  ],
                ),
                for (int i = 0; i < widget.rows.length; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: i.isEven ? Colors.white : const Color(0xFFF8FAFC),
                    ),
                    children: [
                      _textCell('${widget.codePrefix}-${i + 1}',
                          bold: true, align: TextAlign.center),
                      _textCell(widget.rows[i]),
                      _actionButton(
                        label: 'START',
                        time: _startTimes[i],
                        enabled: _startTimes[i] == null,
                        onTap: () =>
                            setState(() => _startTimes[i] = DateTime.now()),
                      ),
                      _actionButton(
                        label: 'FINISH',
                        time: _finishTimes[i],
                        enabled:
                            _startTimes[i] != null && _finishTimes[i] == null,
                        onTap: () =>
                            setState(() => _finishTimes[i] = DateTime.now()),
                      ),
                      _statusCell(_status(i)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
