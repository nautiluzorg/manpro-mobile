import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/reason_dialog_mass/helpers/mass_submit_helper.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/provider/reason_provider.dart';
import '../helpers/mass_reason_controller.dart';
import 'package:provider/provider.dart';

class MassActionButtons extends StatefulWidget {
  final MassReasonController controller;
  final String idProses;

  const MassActionButtons(
      {super.key, required this.controller, required this.idProses});

  @override
  State<MassActionButtons> createState() => _MassActionButtonsState();
}

class _MassActionButtonsState extends State<MassActionButtons> {
  @override
  Widget build(BuildContext context) {
    final reasonSelected =
        context.select<ReasonProvider, bool>((p) => p.selectedReason != null);
    final isSubmitting =
        context.select<RunningProvider, bool>((p) => p.isSubmitting);

    return Row(
      children: [
        // 🔥 CANCEL (exact)
        Expanded(
          child: SizedBox(
            height: 70,
            child: OutlinedButton(
              onPressed: () => widget.controller
                  .onCancel(() => Navigator.pop(context), context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("CANCEL",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 🔥 CONFIRM (QR scanner)
        Expanded(
          child: SizedBox(
            height: 70,
            child: buildCustomButton(
              text: "CONFIRM",
              height: 70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              gradient: LinearGradient(
                colors: [
                  Colors.greenAccent,
                  Colors.green.shade500,
                  Colors.green.shade900,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              onPressed: reasonSelected ? () => _handleConfirm(context) : null,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 🔥 SUBMIT (final validation)

        // 🔥 SUBMIT (final validation) - lebih simpel
        Expanded(
          child: SizedBox(
            height: 70,
            child: buildCustomButton(
              text: "SUBMIT",
              height: 70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueAccent,
                  Colors.blue.shade600,
                  Colors.blue.shade900,
                ],
              ),
              onPressed: (!reasonSelected ||
                      !widget.controller.isEmployeeConfirmed ||
                      isSubmitting)
                  ? null
                  : () => _handleSubmit(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleConfirm(BuildContext context) async {
    await widget.controller.handleConfirmQr(context);
    if (mounted) setState(() {}); // Refresh UI
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final runningProv = context.read<RunningProvider>();
    final selectedItems = runningProv.selectedItems;
    // final reasonProv = context.read<ReasonProvider>();

    // Use helper for validation + submit
    final helper = MassSubmitHelper(
      context: context,
      controller: widget.controller,
      selectedItems: selectedItems,
      idProses: widget.idProses,
    );

    final success = await helper.submit();
    if (success && mounted) Navigator.pop(context);
  }
}
