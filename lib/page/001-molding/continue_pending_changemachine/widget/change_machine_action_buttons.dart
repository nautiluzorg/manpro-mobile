import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';

class ChangeMachineActionButtons extends StatelessWidget {
  final PendingProvider prov;
  final String idPending;
  final void Function(bool)? onSuccess;

  const ChangeMachineActionButtons({
    super.key,
    required this.prov,
    required this.idPending,
    required this.onSuccess,
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
              onPressed: () {
                prov.resetEmployeeState();
                prov.clearNextMachine();
                context.read<MachineProvider>().clearMachine();
                Navigator.pop(context);
              },
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
              onPressed: () async {
                // 1️⃣ Scan QR code
                final scannedCode = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const MobileScannerPage()),
                );

                if (!context.mounted ||
                    scannedCode == null ||
                    scannedCode.isEmpty ||
                    scannedCode == "-1") {
                  return;
                }

                // ✅ Ambil provider setelah memastikan widget masih mounted
                final machineProv = context.read<MachineProvider>();
                final pendingProv = context.read<PendingProvider>();

                // 2️⃣ Validasi dan ambil detail mesin dari MachineProvider
                final errorMessage = await machineProv.scanMachine(scannedCode);

                if (!context.mounted) {
                  return;
                } // cek mounted lagi sebelum update UI/provider

                if (errorMessage != null) {
                  CustomSnackbar.show(context, errorMessage, isSuccess: false);
                  return;
                }

                // 3️⃣ Ambil data mesin dari MachineProvider
                final machineData = machineProv.machine;

                // 4️⃣ Validasi apakah mesin sedang digunakan (in_use / running)
                final validationError =
                    await machineProv.validateMachineDropdown(machineData.idMc);

                if (!context.mounted) return;

                if (validationError != null) {
                  CustomSnackbar.show(context, validationError,
                      isSuccess: false);
                  return;
                }

                // 5️⃣ Update PendingProvider dengan data mesin yang benar
                pendingProv.setNextMachine(
                  id: machineData.idMc,
                  name: machineData.nmMc,
                );
              },
            ),
          ),
        ),

/*
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
              onPressed: () async {
                // 1️⃣ Scan QR code
                final scannedCode = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const MobileScannerPage()),
                );

                if (!context.mounted ||
                    scannedCode == null ||
                    scannedCode.isEmpty ||
                    scannedCode == "-1") {
                  return;
                }

                // ✅ Ambil provider setelah memastikan widget masih mounted
                final machineProv = context.read<MachineProvider>();
                final pendingProv = context.read<PendingProvider>();

                // 2️⃣ Validasi dan ambil detail mesin dari MachineProvider
                final errorMessage = await machineProv.scanMachine(scannedCode);

                if (!context.mounted) {
                  return;
                } // cek mounted lagi sebelum update UI/provider

                if (errorMessage != null) {
                  CustomSnackbar.show(context, errorMessage, isSuccess: false);
                  return;
                }

                // 3️⃣ Ambil data mesin dari MachineProvider
                final machineData = machineProv.machine;

                // 4️⃣ Update PendingProvider dengan data mesin yang benar
                pendingProv.setNextMachine(
                  id: machineData.idMc,
                  name: machineData.nmMc,
                );
              },
            ),
          ),
        ),

        */

        const SizedBox(width: 8),

        // ---------------- SUBMIT ----------------
        Expanded(
          child: SizedBox(
            height: 80,
            child: Builder(
              builder: (context) {
                final bool isEnabled = prov.hasNextMachine &&
                    // prov.isEmployeeValid() &&
                    !prov.isSubmitting;

                return buildCustomButton(
                  text: 'SUBMIT',
                  height: 80,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  gradient: LinearGradient(
                    colors: isEnabled
                        ? [Colors.blueAccent, Colors.blue.shade900]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  onPressed: isEnabled
                      ? () async {
                          final navigator = Navigator.of(context);

                          // SESUDAH
                          final idRecord = prov.pendingDetail.first
                              .idRecord; // ← ambil dari detail

                          final success = await prov.updatePendingRecordMc(
                            idPending: int.parse(idPending),
                            idRecord: idRecord,
                          );

                          if (!context.mounted) return;

                          if (onSuccess != null) {
                            onSuccess!(success);
                          }

                          navigator.pop(success);
                        }
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
