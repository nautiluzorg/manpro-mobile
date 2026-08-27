import 'package:flutter/material.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';

/// Tiga tombol aksi utama (CANCEL, CONFIRM scan, SUBMIT) + tombol
/// "CONTINUE NEW OPERATOR". Semua logic async/mounted-check tetap
/// dipegang oleh parent State lewat callback, widget ini murni tampilan.
class WorkdayOverActionButtons extends StatelessWidget {
  final PendingProvider prov;
  final VoidCallback onCancel;
  final VoidCallback onConfirmScan;
  final VoidCallback onSubmit;
  final VoidCallback onContinueNewOperator;

  const WorkdayOverActionButtons({
    super.key,
    required this.prov,
    required this.onCancel,
    required this.onConfirmScan,
    required this.onSubmit,
    required this.onContinueNewOperator,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = prov.isEmployeeValid() && !prov.isSubmitting;

    return Column(
      children: [
        // ── Row 1: CANCEL, CONFIRM, SUBMIT ────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // CANCEL
            Expanded(
              child: SizedBox(
                height: 80,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // CONFIRM
            Expanded(
              child: SizedBox(
                height: 80,
                child: buildCustomButton(
                  text: 'CONFIRM',
                  height: 80,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  gradient: LinearGradient(
                    colors: [
                      Colors.greenAccent,
                      Colors.green.shade600,
                      Colors.green.shade900,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  onPressed: onConfirmScan,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // SUBMIT
            Expanded(
              child: SizedBox(
                height: 80,
                child: buildCustomButton(
                  text: 'SUBMIT',
                  height: 80,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  gradient: LinearGradient(
                    colors: isEnabled
                        ? [
                            Colors.blueAccent,
                            Colors.blue.shade600,
                            Colors.blue.shade900,
                          ]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  onPressed: isEnabled ? onSubmit : null,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Row 2: CONTINUE NEW OPERATOR ────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 90,
          child: buildCustomButton(
            text: 'DILANJUTKAN OPERATOR BARU',
            height: 90,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            gradient: LinearGradient(
              colors: [
                Colors.orangeAccent,
                Colors.orange.shade700,
                Colors.deepOrange.shade900,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            onPressed: onContinueNewOperator,
          ),
        ),
      ],
    );
  }
}
