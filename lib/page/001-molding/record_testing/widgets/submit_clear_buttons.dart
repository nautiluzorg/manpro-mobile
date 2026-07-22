import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';

/// SUBMIT + CLEAR action row shown below the scan form.
/// Extracted verbatim — same submitRecordWithLoading() call and args,
/// same enable/disable + gradient rules.
class SubmitClearButtons extends StatelessWidget {
  final double width;
  final double height;

  const SubmitClearButtons({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Consumer<TestingProvider>(
                builder: (context, pro, _) => _SubmitButton(pro: pro),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
              child: Consumer<TestingProvider>(
                builder: (context, provTest, _) {
                  return OutlinedButton(
                    onPressed: () => provTest.resetAll(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(90),
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "CLEAR",
                      style: GoogleFonts.poppins(
                        color: Colors.blueAccent,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final TestingProvider pro;

  const _SubmitButton({required this.pro});

  @override
  Widget build(BuildContext context) {
    final disabled = !pro.canSubmit || pro.isSubmitting;

    final Gradient buttonGradient = disabled
        ? LinearGradient(
            colors: [Colors.blueGrey.shade50, Colors.blueGrey.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : LinearGradient(
            colors: [Colors.blueAccent.shade400, Colors.blue.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Ink(
      decoration: BoxDecoration(
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: OutlinedButton(
        onPressed: disabled ? null : () => _submit(context),
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(90)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            return disabled ? Colors.grey.shade200 : Colors.white;
          }),
        ),
        child: pro.isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                "SUBMIT",
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: disabled ? Colors.grey.shade600 : Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    try {
      final success = await pro.submitRecordWithLoading(
        idRecordUpdate: pro.currentJob?.idRecordTest,
        batchNumber: pro.batchNumber,
        totalLotNumber: pro.totalLotNumber,
        notes: pro.notes,
        bcode: pro.bcode,
        jobNumber: pro.jobNumber,
        lotNumber: pro.lotNumber,
        selectedMoldNumber: pro.selectedMold.toolNumber,
        idEmployee: pro.employee.idEmployee,
        idMachine: pro.machine.idMc,
        startQty: int.tryParse(pro.qty) ?? 0,
        moldCavity: pro.selectedMold.cavityValue ?? 1,
        mixLotNumber: pro.mixLotNo,
      );

      if (!context.mounted) return;

      if (success) {
        CustomSnackbar.show(context, "Data berhasil dikirim", isSuccess: true);
        pro.resetAll();
      }
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackbar.show(context, "Error: $e", isSuccess: false);
    }
  }
}
