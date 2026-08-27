import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';

class EmployeeActionButtons extends StatelessWidget {
  final PendingProvider provider;
  final void Function(bool)? onSuccess;

  const EmployeeActionButtons({
    super.key,
    required this.provider,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: customOutlinedButton(
            text: 'CANCEL',
            borderColor: Colors.red,
            textColor: Colors.red,
            fontSize: 20,
            height: 75,
            onPressed: () {
              provider.resetNextOperatorState();
              context.read<EmployeeProvider>().clearEmployee();

              Navigator.of(context).pop();
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: buildCustomButton(
            text: 'SUBMIT',
            height: 75,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            gradient: (provider.hasConfirmedEmployee && !provider.isSubmitting)
                ? LinearGradient(
                    colors: [
                      Colors.blueAccent,
                      Colors.blue.shade600,
                      Colors.blue.shade900,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            onPressed: (provider.hasConfirmedEmployee && !provider.isSubmitting)
                ? () async {
                    final data = provider.ngDetail;

                    // ✅ Aman karena sebelum await
                    if (data.isEmpty) {
                      CustomSnackbar.show(
                        context,
                        "Data pending kosong",
                        isSuccess: false,
                      );
                      return;
                    }

                    // ✅ Simpan reference sebelum await
                    final navigator =
                        Navigator.of(context, rootNavigator: true);

                    final success = await provider.updateRecordOpChange(
                      idPending: data.idPending,
                    );

                    if (!context.mounted) return;
                    // 🔥 refresh list di sini
                    if (success) {
                      await provider.fetchPending('001');
                    }

                    if (!context.mounted) return;

                    if (onSuccess != null) {
                      onSuccess!(success);
                    }

                    navigator.pop(success);
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
