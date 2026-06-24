import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:provider/provider.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  // ❌ Hapus dialogContext — tidak diperlukan lagi

  const ActionButtonsRow({
    super.key,
    required this.onCancel,
    required this.onSubmit,
    // ❌ Hapus required this.dialogContext
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: customOutlinedButton(
            text: 'CANCEL',
            onPressed: onCancel,
            borderColor: Colors.red.shade800,
            textColor: Colors.red.shade800,
            height: 80,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Consumer<RunningProvider>(
            builder: (context, prov, _) {
              return buildCustomButton(
                text: 'CONFIRM',
                gradient: LinearGradient(
                  colors: [
                    Colors.greenAccent,
                    Colors.green.shade700,
                    Colors.green.shade900,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                height: 80,
                fontSize: 25,
                fontWeight: FontWeight.bold,
                onPressed: prov.canConfirm
                    ? () async {
                        // ✅ Simpan reference sebelum await
                        final overlay = Overlay.of(context, rootOverlay: true);
                        final empProv = context.read<EmployeeProvider>();

                        final code = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MobileScannerPage(),
                          ),
                        );

                        if (code == null || code.isEmpty || code == "-1")
                          return;

                        final success = await empProv.scanEmployee(code);

                        if (!success) {
                          CustomSnackbar.showWithOverlay(
                            overlay, // ✅ pakai overlay
                            empProv.errorMessage ?? "Employee scan failed",
                            isSuccess: false,
                          );
                        }
                      }
                    : null,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Consumer<EmployeeProvider>(
            builder: (context, empProv, _) {
              return buildCustomButton(
                text: "SUBMIT",
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.blue.shade700,
                    Colors.blue.shade900,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                onPressed: empProv.canConfirm ? onSubmit : null,
                fontWeight: FontWeight.bold,
                fontSize: 25,
                height: 80,
              );
            },
          ),
        ),
      ],
    );
  }
}
