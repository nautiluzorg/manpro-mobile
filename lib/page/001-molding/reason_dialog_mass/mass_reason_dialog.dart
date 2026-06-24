import 'package:flutter/material.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:provider/provider.dart';
import 'helpers/mass_reason_controller.dart';
import 'widgets/mass_reason_dropdown.dart';
import 'widgets/mass_employee_grid.dart';
import 'widgets/mass_confirm_section.dart';
import 'widgets/mass_action_buttons.dart';

class ReasonSelectedMassdialog extends StatefulWidget {
  final String idProses;

  const ReasonSelectedMassdialog({super.key, required this.idProses});

  @override
  State<ReasonSelectedMassdialog> createState() =>
      _ReasonSelectedMassdialogState();
}

class _ReasonSelectedMassdialogState extends State<ReasonSelectedMassdialog> {
  late final MassReasonController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MassReasonController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_controller.loaded) {
      _controller.setLoaded(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Expose _controller ke widget tree supaya
    // MassConfirmSection bisa context.watch<MassReasonController>()
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: customDialogAppBar(title: "ALASAN STOP MOLDING"),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PILIH ALASAN STOP:",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                MassReasonDropdown(idProses: widget.idProses),
                const SizedBox(height: 20),

                const Text(
                  "DAFTAR JOBNUMBER DI STOP:",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),

                MassEmployeeGrid(),
                const SizedBox(height: 20),

                // ✅ Tidak perlu pass controller lagi
                // MassConfirmSection ambil sendiri via context.watch
                const MassConfirmSection(),
                const SizedBox(height: 30),

                // ✅ MassActionButtons tetap terima controller
                // karena butuh akses method handleConfirmQr & validateSubmit
                MassActionButtons(
                  controller: _controller,
                  idProses: widget.idProses,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // ← dispose ChangeNotifier dengan benar
    super.dispose();
  }
}







/*
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/reason_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'helpers/mass_reason_controller.dart';
// import 'helpers/mass_submit_helper.dart';
import 'widgets/mass_reason_dropdown.dart';
import 'widgets/mass_employee_grid.dart';
import 'widgets/mass_confirm_section.dart';
import 'widgets/mass_action_buttons.dart';

class ReasonSelectedMassdialog extends StatefulWidget {
  final String idProses;

  const ReasonSelectedMassdialog({super.key, required this.idProses});

  @override
  State<ReasonSelectedMassdialog> createState() =>
      _ReasonSelectedMassdialogState();
}

class _ReasonSelectedMassdialogState extends State<ReasonSelectedMassdialog> {
  late final MassReasonController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MassReasonController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controller.loaded) {
      _controller.setLoaded(true);
      context.read<ReasonProvider>().loadReasonData(idProses: widget.idProses);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customDialogAppBar(title: "ALASAN STOP MOLDING"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "PILIH ALASAN STOP:",
                style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // 🔥 ALL modular widgets
              MassReasonDropdown(idProses: widget.idProses),
              const SizedBox(height: 20),

              const Text(
                "DAFTAR JOBNUMBER DI STOP:",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.blueGrey),
              ),
              const SizedBox(height: 10),

              MassEmployeeGrid(),
              const SizedBox(height: 20),

              MassConfirmSection(),
              const SizedBox(height: 30),

              MassActionButtons(
                controller: _controller,
                idProses: widget.idProses,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.reset();
    super.dispose();
  }
}
*/