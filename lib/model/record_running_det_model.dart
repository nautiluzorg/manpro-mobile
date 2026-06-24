import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';
import 'package:flutter_provider_data/model/record_det_model.dart';

@immutable
class RecordRunningDetModel {
  final String idRecord;
  final List<RecordDetModel> detailsRecord;
  final EmployeeModel employeeFinish;
  final MachineModel machineFinish;
  final DateTime startTime;
  final String batchNumber;
  final String totalJobnumber;
  final DateTime? finishTime;
  final int totalPending;
  final int totalNg;
  final int cycleTime;
  final int totalTime;
  final String runStatus;
  final String jobStatus;
  final bool isMultiOperator;
  final bool isMultiMachine;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String idProses;
  final String? deletedBy;

  const RecordRunningDetModel({
    required this.idRecord,
    required this.detailsRecord,
    required this.employeeFinish,
    required this.machineFinish,
    required this.startTime,
    required this.batchNumber,
    required this.totalJobnumber,
    this.finishTime,
    required this.totalPending,
    required this.totalNg,
    required this.cycleTime,
    required this.totalTime,
    required this.runStatus,
    required this.jobStatus,
    required this.isMultiOperator,
    required this.isMultiMachine,
    required this.isDeleted,
    this.deletedAt,
    required this.idProses,
    this.deletedBy,
  });

  /// Factory dari JSON API
  factory RecordRunningDetModel.fromJson(Map<String, dynamic> json) {
    return RecordRunningDetModel(
      idRecord: json['id_record']?.toString() ?? '',
      detailsRecord: (json['details_record'] as List? ?? [])
          .map((e) => RecordDetModel.fromJson(e))
          .toList(),
      employeeFinish: EmployeeModel.fromJson(
          json['employee_finish'] ?? EmployeeModel.empty.toJson()),
      machineFinish: MachineModel.fromJson(
          json['machine_finish'] ?? MachineModel.empty.toJson()),
      startTime: DateTime.parse(
          json['start_time']?.toString() ?? DateTime.now().toIso8601String()),
      batchNumber: json['batch_number']?.toString() ?? '',
      totalJobnumber: json['total_jobnumber']?.toString() ?? '',
      finishTime: json['finish_time'] != null
          ? DateTime.tryParse(json['finish_time'].toString())
          : null,
      totalPending: json['total_pending'] ?? 0,
      totalNg: json['total_ng'] ?? 0,
      cycleTime: json['cycle_time'] ?? 0,
      totalTime: json['total_time'] ?? 0,
      runStatus: json['run_status']?.toString() ?? '',
      jobStatus: json['job_status']?.toString() ?? '',
      isMultiOperator: json['is_multi_operator'] ?? false,
      isMultiMachine: json['is_multi_machine'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null,
      idProses: json['id_proses']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString(),
    );
  }
}
