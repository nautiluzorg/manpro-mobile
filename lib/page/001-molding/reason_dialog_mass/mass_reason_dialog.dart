import 'package:flutter/material.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'helpers/mass_reason_controller.dart';
import 'widgets/mass_reason_dropdown.dart';
import 'widgets/mass_employee_grid.dart';
import 'widgets/mass_confirm_section.dart';
import 'widgets/mass_action_buttons.dart';

class MassReasonDialog extends StatefulWidget {
  final String idProses;

  const MassReasonDialog({super.key, required this.idProses});

  @override
  State<MassReasonDialog> createState() => _MassReasonDialogState();
}

class _MassReasonDialogState extends State<MassReasonDialog> {
  // ===== Design tokens =====
  static const double _pagePadding = 16;
  static const double _sectionGap = 20; // jarak antar section
  static const double _labelGap = 10; // jarak label ke konten
  static const double _maxContentWidth = 900; // batas lebar di layar besar

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
    // Expose _controller ke widget tree supaya
    // MassConfirmSection bisa context.watch<MassReasonController>()
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: customDialogAppBar(title: "ALASAN STOP MOLDING"),
        body: SafeArea(
          child: Column(
            children: [
              // ---- Konten: scroll, mengisi sisa layar ----

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(_pagePadding),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: _maxContentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel("PILIH ALASAN STOP:"),
                          const SizedBox(height: _labelGap),
                          MassReasonDropdown(idProses: widget.idProses),
                          const SizedBox(height: _sectionGap),
                          const _SectionLabel("DAFTAR JOBNUMBER DI STOP:"),
                          const SizedBox(height: _labelGap),

                          const MassEmployeeGrid(),

                          const SizedBox(height: _sectionGap),
                          // MassConfirmSection ambil sendiri via context.watch
                          const MassConfirmSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ---- Tombol aksi: selalu terlihat di bawah ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                    _pagePadding, 12, _pagePadding, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: _maxContentWidth),
                    // controller tetap dipass karena butuh akses
                    // handleConfirmQr & validateSubmit
                    child: MassActionButtons(
                      controller: _controller,
                      idProses: widget.idProses,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // dispose ChangeNotifier dengan benar
    super.dispose();
  }
}

/// Label section seragam (aksen biru + teks kecil tebal)
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Colors.blueGrey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:provider/provider.dart';
import 'helpers/mass_reason_controller.dart';
import 'widgets/mass_reason_dropdown.dart';
import 'widgets/mass_employee_grid.dart';
import 'widgets/mass_confirm_section.dart';
import 'widgets/mass_action_buttons.dart';

class MassReasonDialog extends StatefulWidget {
  final String idProses;

  const MassReasonDialog({super.key, required this.idProses});

  @override
  State<MassReasonDialog> createState() =>
      _MassReasonDialogState();
}

class _MassReasonDialogState extends State<MassReasonDialog> {
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
*/
