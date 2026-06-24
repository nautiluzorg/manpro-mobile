import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'reason_dialog_controller.dart';

class ReasonDialogSubmitHelper {
  final OverlayState overlay;
  final RunningProvider runningProvider;
  final EmployeeProvider employeeProvider;
  final ReasonDialogController controller;
  final String idRecord;
  final Future<void> Function()? onSuccess;

  ReasonDialogSubmitHelper({
    required this.overlay,
    required this.runningProvider,
    required this.employeeProvider,
    required this.controller,
    required this.idRecord,
    required this.onSuccess,
  });

  // ── Entry point ───────────────────────────────────────────
  Future<bool> submit() async {
    if (!employeeProvider.canConfirm) {
      CustomSnackbar.showWithOverlay(
        overlay,
        "MOHON SCAN QRCODE ID Card Anda!",
        isSuccess: false,
      );
      return false;
    }

    if (employeeProvider.employee.idEmployee !=
        runningProvider.expectedEmployeeId) {
      CustomSnackbar.showWithOverlay(
        overlay,
        "CONFIRMASI OPERATOR TIDAK SESUAI!",
        isSuccess: false,
      );
      return false;
    }

    final selectedReasonId = runningProvider.selectedReason?.idReason;

    if (selectedReasonId == '02') {
      return await _submitWorkdayOver();
    } else if (selectedReasonId == '03') {
      return await _submitChangeOperator();
    } else if (selectedReasonId == '06') {
      return await _submitChangeMachine();
    } else {
      return await _submitRecordStop();
    }
  }

  // ── Reason 02: Workday Over ───────────────────────────────
  Future<bool> _submitWorkdayOver() async {
    final data = runningProvider.recordDetails;
    if (data.isEmpty) return false;

    final activeEmployeeId = data[0].activeEmployee.idEmployee;
    final scanEmployeeId = employeeProvider.employee.idEmployee;

    if (activeEmployeeId != scanEmployeeId) {
      CustomSnackbar.showWithOverlay(
        overlay,
        "Employee sebelumnya bukan ini!",
        isSuccess: false,
      );
      return false;
    }

    final success = await runningProvider.submitWorkdayOverData(
      idRecord: idRecord,
      idEmployee: activeEmployeeId,
      idProses: data[0].proses.idProses,
      bcode: data[0].detailsRecord.isNotEmpty
          ? data[0].detailsRecord[0].bcode.bcode
          : '',
    );

    if (success) {
      await _handleSuccess();
      return true;
    }
    return false;
  }

  // ── Reason 03: Change Operator ────────────────────────────
  Future<bool> _submitChangeOperator() async {
    if (!controller.isShootQtyValid) {
      CustomSnackbar.showWithOverlay(
        overlay,
        'HARAP LENGKAPI DATA CURRENT SHOOT.',
        isSuccess: false,
      );
      return false; // ✅
    }

    final shootQty = controller.getShootQty();
    final ngListMapped = controller.mapNgDataForSubmit();
    final data = runningProvider.recordDetails;
    if (data.isEmpty) return false; // ✅

    final success = await runningProvider.submitChangeOperatorData(
      idRecord: idRecord,
      idReason: runningProvider.selectedReason?.idReason ?? '',
      idEmployee: data[0].activeEmployee.idEmployee,
      idProses: data[0].proses.idProses,
      bcode: data[0].detailsRecord[0].bcode.bcode,
      shootQty: shootQty,
      ngList: ngListMapped,
    );

    if (success) {
      await _handleSuccess();
      return true; // ✅
    }
    return false; // ✅
  }

  // ── Reason 06: Change Machine ─────────────────────────────
  Future<bool> _submitChangeMachine() async {
    if (!controller.isShootQtyValid) {
      CustomSnackbar.showWithOverlay(
        overlay,
        'HARAP LENGKAPI DATA CURRENT SHOOT.',
        isSuccess: false,
      );
      return false; // ✅
    }

    final shootQty = controller.getShootQty();
    final data = runningProvider.recordDetails;
    if (data.isEmpty) return false; // ✅

    final success = await runningProvider.submitChangeMachineData(
      idRecord: idRecord,
      idReason: runningProvider.selectedReason?.idReason ?? '',
      idEmployee: data[0].activeEmployee.idEmployee,
      idProses: data[0].proses.idProses,
      bcode: data[0].detailsRecord[0].bcode.bcode,
      shootQty: shootQty,
      idMachine: data[0].activeMachine.idMc,
    );

    if (success) {
      await _handleSuccess();
      return true; // ✅
    }
    return false; // ✅
  }

  // ── Standard Stop ─────────────────────────────────────────
  Future<bool> _submitRecordStop() async {
    final data = runningProvider.recordDetails;
    if (data.isEmpty) return false; // ✅

    final success = await runningProvider.submitRecordStopData(
      idRecord: idRecord,
      idReason: runningProvider.selectedReason?.idReason ?? '',
      idEmployee: data[0].activeEmployee.idEmployee,
      idProses: data[0].proses.idProses,
      bcode: data[0].detailsRecord.isNotEmpty
          ? data[0].detailsRecord[0].bcode.bcode
          : '',
    );

    if (success) {
      await _handleSuccess();
      return true; // ✅
    }
    return false; // ✅
  }

  // ── Handle Success ────────────────────────────────────────
  Future<void> _handleSuccess() async {
    runningProvider.resetSuccessSubmit();
    employeeProvider.clearEmployee();

    CustomSnackbar.showWithOverlay(
      overlay,
      "Successfully stop!",
      isSuccess: true,
    );

    await Future.delayed(const Duration(milliseconds: 300));
    await onSuccess?.call();
  }
}
