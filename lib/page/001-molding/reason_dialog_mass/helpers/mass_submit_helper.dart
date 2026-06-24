import 'package:flutter/material.dart'; // ✅ tambah ini
import 'package:flutter_provider_data/page/001-molding/reason_dialog_mass/helpers/mass_reason_controller.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/provider/reason_provider.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:provider/provider.dart'; // ✅ tambah ini juga

class MassSubmitHelper {
  final BuildContext context;
  final MassReasonController controller;
  final List<RecordRunningModel> selectedItems;
  final String idProses;

  MassSubmitHelper({
    required this.context,
    required this.controller,
    required this.selectedItems,
    required this.idProses,
  });

  Future<bool> submit() async {
    final runningProv = context.read<RunningProvider>();
    final reasonProv = context.read<ReasonProvider>();

    logPrint("=== DEBUG SUBMIT ===");
    logPrint("selectedItems count: ${selectedItems.length}");
    logPrint("idEmployeeConfirm: ${controller.idEmployeeConfirm}");
    logPrint("selectedReason: ${reasonProv.selectedReason}");
    selectedItems.forEach((item) {
      logPrint("item.idEmployee: ${item.activeEmployee?.idEmployee}");
      logPrint("item.idRecord: ${item.idRecord}");
    });
    logPrint("====================");

    try {
      // 🔥 Original exact validation logic
      final wrongConfirm = selectedItems.any(
        (item) =>
            item.activeEmployee?.idEmployee != controller.idEmployeeConfirm,
      );

      if (wrongConfirm) {
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            "CONFIRM salah: Operator tidak sesuai!",
            isSuccess: false,
          );
        }
        return false;
      }

      // 🔥 Original exact submit call
      final success = await runningProv.postPending(
        selectedItems,
        reasonProv.selectedReason,
        idProses,
      );

      if (context.mounted) {
        if (success) {
          CustomSnackbar.show(context, "Submit Successfully!", isSuccess: true);
        } else {
          CustomSnackbar.show(context, "Gagal mengirim data!",
              isSuccess: false);
        }
      }

      return success;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(context, "Terjadi kesalahan: $e", isSuccess: false);
      }
      return false;
    }
  }
}
