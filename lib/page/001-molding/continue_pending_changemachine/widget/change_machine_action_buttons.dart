import 'package:flutter/material.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';

class ChangeMachineActionButtons extends StatelessWidget {
  final bool canSubmit;
  final VoidCallback onCancel;
  final Future<void> Function() onScanMachine;
  final Future<void> Function() onSubmit;

  const ChangeMachineActionButtons({
    super.key,
    required this.canSubmit,
    required this.onCancel,
    required this.onScanMachine,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ---------------- CANCEL ----------------
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

        // ---------------- ADD MACHINE ----------------
        Expanded(
          child: SizedBox(
            height: 80,
            child: buildCustomButton(
              text: 'NEW MC',
              height: 80,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.deepOrange.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              onPressed: () => onScanMachine(),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // ---------------- SUBMIT ----------------
        Expanded(
          child: SizedBox(
            height: 80,
            child: Builder(
              builder: (context) {
                return buildCustomButton(
                  text: 'SUBMIT',
                  height: 80,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  gradient: LinearGradient(
                    colors: canSubmit
                        ? [Colors.blueAccent, Colors.blue.shade900]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  onPressed: canSubmit ? () => onSubmit() : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
