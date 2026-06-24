import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';
import 'package:flutter_provider_data/model/record_det_model.dart';
import 'package:flutter_provider_data/model/record_pending_min_model.dart';

class RecordPendingDetModel {
  final String idRecord;
  final List<RecordDetModel> detailsRecord;
  final List<RecordPendingMinModel> recordPendings;
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

  final String idProses;

  RecordPendingDetModel({
    required this.idRecord,
    required this.detailsRecord,
    required this.recordPendings,
    required this.employeeFinish,
    required this.machineFinish,
    required this.startTime,
    required this.batchNumber,
    required this.totalJobnumber,
    required this.finishTime,
    required this.totalPending,
    required this.totalNg,
    required this.cycleTime,
    required this.totalTime,
    required this.runStatus,
    required this.jobStatus,
    required this.isMultiOperator,
    required this.isMultiMachine,
    required this.isDeleted,
    required this.idProses,
  });

  factory RecordPendingDetModel.fromJson(Map<String, dynamic> json) {
    return RecordPendingDetModel(
      idRecord: json['id_record'],
      detailsRecord: (json['details_record'] as List)
          .map((e) => RecordDetModel.fromJson(e))
          .toList(),
      recordPendings: (json['record_pendings'] as List)
          .map((e) => RecordPendingMinModel.fromJson(e))
          .toList(),
      employeeFinish: EmployeeModel.fromJson(json['employee_finish']),
      machineFinish: MachineModel.fromJson(json['machine_finish']),
      startTime: DateTime.parse(json['start_time']),
      batchNumber: json['batch_number'],
      totalJobnumber: json['total_jobnumber'],
      finishTime: json['finish_time'] != null
          ? DateTime.parse(json['finish_time'])
          : null,
      totalPending: json['total_pending'],
      totalNg: json['total_ng'],
      cycleTime: json['cycle_time'],
      totalTime: json['total_time'],
      runStatus: json['run_status'],
      jobStatus: json['job_status'],
      isMultiOperator: json['is_multi_operator'],
      isMultiMachine: json['is_multi_machine'],
      isDeleted: json['is_deleted'],
      idProses: json['id_proses'],
    );
  }
}
