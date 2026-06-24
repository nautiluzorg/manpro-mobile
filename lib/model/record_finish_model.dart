import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';
import 'package:flutter_provider_data/model/master/proses_model.dart';
import 'package:flutter_provider_data/model/record_detail_finish_model.dart';

class RecordFinishModel {
  final String idRecord;
  final String batchNumber;
  final String startTime;
  final String finishTime;
  final int totalPending;
  final int totalNg;
  final int cycleTime;
  final int totalTime;
  final EmployeeModel employee;
  final EmployeeModel employeeFinish;
  final MachineModel machine;
  final MachineModel machineFinish;
  final ProsesModel process;
  final List<DetailRecordFinishModel> detailsRecord;

  RecordFinishModel({
    required this.idRecord,
    required this.batchNumber,
    required this.startTime,
    required this.finishTime,
    required this.totalPending,
    required this.totalNg,
    required this.cycleTime,
    required this.totalTime,
    required this.employee,
    required this.employeeFinish,
    required this.machine,
    required this.machineFinish,
    required this.process,
    required this.detailsRecord,
  });

  factory RecordFinishModel.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['details_record'] as List<dynamic>;
    return RecordFinishModel(
      idRecord: json['id_record'],
      batchNumber: json['batch_number'],
      startTime: json['start_time'],
      finishTime: json['finish_time'] ?? '',
      totalPending: json['total_pending'] ?? 0,
      totalNg: json['total_ng'] ?? 0,
      cycleTime: json['cycle_time'] ?? 0,
      totalTime: json['total_time'] ?? 0,
      employee: EmployeeModel.fromJson(json['employee']),
      employeeFinish: EmployeeModel.fromJson(json['employee_finish']),
      machine: MachineModel.fromJson(json['machine']),
      machineFinish: MachineModel.fromJson(json['machine_finish']),
      process: ProsesModel.fromJson(json['proses']),
      detailsRecord:
          detailsJson.map((d) => DetailRecordFinishModel.fromJson(d)).toList(),
    );
  }
}
