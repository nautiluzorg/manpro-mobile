import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TechnicianFormData {
  final String lineMachine;
  final String activity;
  final String drawingNo;
  final String moldNo;
  final String problem;
  final String actionTaken;
  final String technician;

  const TechnicianFormData({
    required this.lineMachine,
    required this.activity,
    required this.drawingNo,
    required this.moldNo,
    required this.problem,
    required this.actionTaken,
    required this.technician,
  });

  Map<String, String> toJson() => {
        'line_machine': lineMachine,
        'activity': activity,
        'drawing_no': drawingNo,
        'mold_no': moldNo,
        'problem': problem,
        'action_taken': actionTaken,
        'technician': technician,
      };
}

class TechnicianFormPage extends StatefulWidget {
  final String title;
  final FutureOr<void> Function(TechnicianFormData data)? onSubmit;

  const TechnicianFormPage({
    super.key,
    this.title = 'TECHNICIAN FORM',
    this.onSubmit,
  });

  @override
  State<TechnicianFormPage> createState() => _TechnicianFormPageState();
}

class _TechnicianFormPageState extends State<TechnicianFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _lineMachineController = TextEditingController();
  final _activityController = TextEditingController();
  final _drawingNoController = TextEditingController();
  final _moldNoController = TextEditingController();
  final _problemController = TextEditingController();
  final _actionTakenController = TextEditingController();
  final _technicianController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _lineMachineController.dispose();
    _activityController.dispose();
    _drawingNoController.dispose();
    _moldNoController.dispose();
    _problemController.dispose();
    _actionTakenController.dispose();
    _technicianController.dispose();
    super.dispose();
  }

  TechnicianFormData _readFormData() {
    return TechnicianFormData(
      lineMachine: _lineMachineController.text.trim(),
      activity: _activityController.text.trim(),
      drawingNo: _drawingNoController.text.trim(),
      moldNo: _moldNoController.text.trim(),
      problem: _problemController.text.trim(),
      actionTaken: _actionTakenController.text.trim(),
      technician: _technicianController.text.trim(),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    final data = _readFormData();

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit?.call(data);

      if (!mounted) return;
      CustomSnackbar.show(
        context,
        widget.onSubmit == null
            ? 'Data form technician siap diproses.'
            : 'Data technician berhasil disimpan.',
        isSuccess: true,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        'Gagal menyimpan data technician: $e',
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _clear() {
    _formKey.currentState?.reset();
    for (final controller in [
      _lineMachineController,
      _activityController,
      _drawingNoController,
      _moldNoController,
      _problemController,
      _actionTakenController,
      _technicianController,
    ]) {
      controller.clear();
    }
    FocusScope.of(context).unfocus();
  }

  Future<void> _scanTechnician() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MobileScannerPage()),
    );

    if (!mounted || code == null || code.isEmpty || code == '-1') return;

    final employeeProvider = context.read<EmployeeProvider>();
    final success = await employeeProvider.scanEmployee(code);

    if (!mounted) return;

    if (!success) {
      CustomSnackbar.show(
        context,
        employeeProvider.errorMessage ?? 'Technician tidak ditemukan.',
        isSuccess: false,
      );
      return;
    }

    _technicianController.text = employeeProvider.employee.fullName;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customSubAppBar(
        context: context,
        title: widget.title,
        kode: 'TECHNICIAN',
        proses: 'TECHNICIAN',
        navigateToBuilder: (kode, proses) => Menu(kode: kode, proses: proses),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 8),
                      _buildTechnicianInfoPanel(
                        constraints.maxWidth > 1100
                            ? 1100
                            : constraints.maxWidth,
                      ),
                      const SizedBox(height: 8),
                      _buildFormCard(
                        constraints.maxWidth > 1100
                            ? 1100
                            : constraints.maxWidth,
                      ),
                      const SizedBox(height: 8),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTechnicianInfoPanel(double width) {
    final panelHeight = width >= 600 ? 260.0 : 220.0;

    return SizedBox(
      width: double.infinity,
      height: panelHeight,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FF),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Consumer<EmployeeProvider>(
          builder: (context, employeeProvider, _) {
            final employee = employeeProvider.employee;
            final hasEmployee = employee.isValid;
            final photoUrl = hasEmployee
                ? '${AppConfig.baseUrl}/media/img/employee/${employee.idEmployee}.png'
                : '${AppConfig.baseUrl}/media/img/employee/employee.png';

            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade600,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photoUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                cacheWidth: 320,
                                cacheHeight: 320,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.engineering,
                                    size: 58,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              hasEmployee
                                  ? employee.fullName
                                  : 'BELUM ADA TECHNICIAN',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            hasEmployee ? employee.nrp : 'SCAN QR TECHNICIAN',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 3,
                    ),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Table(
                      border: TableBorder(
                        bottom: const BorderSide(color: Colors.grey),
                        horizontalInside:
                            const BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(0.42),
                        1: FlexColumnWidth(0.58),
                      },
                      children: [
                        _infoRow(
                          'TECHNICIAN',
                          hasEmployee ? employee.fullName : '-',
                          shaded: true,
                        ),
                        _infoRow('NRP', hasEmployee ? employee.nrp : '-'),
                        _infoRow(
                          'DIVISION',
                          hasEmployee ? employee.division : '-',
                          shaded: true,
                        ),
                        _infoRow(
                            'SECTION', hasEmployee ? employee.section : '-'),
                        _infoRow(
                          'KETERANGAN',
                          hasEmployee
                              ? 'Technician siap mengisi activity report'
                              : 'Silakan scan QR technician terlebih dahulu',
                          shaded: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  TableRow _infoRow(String label, String value, {bool shaded = false}) {
    final rowColor = shaded ? Colors.grey.shade100 : Colors.white;

    return TableRow(
      children: [
        Container(
          color: rowColor,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        Container(
          color: rowColor,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          child: Text(
            ': $value',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent,
            Colors.blue.shade600,
            Colors.blue.shade900
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
      child: Row(
        children: [
          const Icon(Icons.engineering, color: Colors.white, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'TECHNICIAN ACTIVITY REPORT',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(double availableWidth) {
    final isWide = availableWidth >= 850;
    final fieldWidth = isWide ? (availableWidth - 44) / 2 : availableWidth;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: fieldWidth,
            child: _buildTextField(
              controller: _lineMachineController,
              label: 'LINE MACHINE',
              hint: 'Input line machine',
              icon: Icons.precision_manufacturing_outlined,
            ),
          ),
          SizedBox(
            width: fieldWidth,
            child: _buildTextField(
              controller: _activityController,
              label: 'ACTIVITY',
              hint: 'Input activity',
              icon: Icons.assignment_outlined,
            ),
          ),
          SizedBox(
            width: fieldWidth,
            child: _buildTextField(
              controller: _drawingNoController,
              label: 'DRAWING NO',
              hint: 'Input drawing number',
              icon: Icons.description_outlined,
            ),
          ),
          SizedBox(
            width: fieldWidth,
            child: _buildTextField(
              controller: _moldNoController,
              label: 'MOLD NO',
              hint: 'Input mold number',
              icon: Icons.view_in_ar_outlined,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: _buildTextField(
              controller: _problemController,
              label: 'PROBLEM',
              hint: 'Describe the problem',
              icon: Icons.warning_amber_rounded,
              minLines: 3,
              maxLines: 5,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: _buildTextField(
              controller: _actionTakenController,
              label: 'ACTION TAKEN',
              hint: 'Describe the action taken',
              icon: Icons.build_circle_outlined,
              minLines: 3,
              maxLines: 5,
            ),
          ),
          SizedBox(
            width: isWide ? fieldWidth : double.infinity,
            child: _buildTextField(
              controller: _technicianController,
              label: 'TECHNICIAN',
              hint: 'Input technician name',
              icon: Icons.engineering_outlined,
              onIconTap: _scanTechnician,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    VoidCallback? onIconTap,
    int minLines = 1,
    int maxLines = 1,
  }) {
    const fieldHeight = 65.0;
    const fieldRadius = 4.0;
    const iconBoxWidth = 58.0;
    final innerRadius = fieldRadius - 1;
    final isMultiline = maxLines > 1;

    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      textInputAction:
          isMultiline ? TextInputAction.newline : TextInputAction.next,
      inputFormatters: [LengthLimitingTextInputFormatter(500)],
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: isMultiline,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: isMultiline ? 14 : 10,
        ),
        prefixIcon: Container(
          width: iconBoxWidth,
          height: fieldHeight,
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(innerRadius),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onIconTap,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(innerRadius),
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: iconBoxWidth,
          maxWidth: iconBoxWidth,
          minHeight: fieldHeight,
        ),
        labelStyle: GoogleFonts.poppins(
          color: Colors.blueGrey.shade600,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.poppins(
          color: Colors.blueGrey.shade400,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _clear,
            icon: const Icon(Icons.clear_all),
            label: Text(
              'CLEAR',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(62),
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade400, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildCustomButton(
            text: 'SUBMIT',
            icon: Icons.save_outlined,
            height: 62,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blue.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            onPressed: _isSubmitting ? null : _submit,
          ),
        ),
      ],
    );
  }
}
