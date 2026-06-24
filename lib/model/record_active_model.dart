import 'master/employee_model.dart';
import 'master/machine_model.dart';
import 'record_detail_model.dart'; // gunakan model yang udah lo punya

class RecordActiveModel {
  final String idRecord;
  final String idEmployee;
  final String idEmployeeFinish;
  final String idMc;
  final String idMcFinish;
  final String idProses;
  final DateTime? startTime;
  final DateTime? finishTime;
  final int totalPending;
  final int totalNg;
  final double cycleTime;
  final double totalTime;
  final String runStatus;
  final String jobStatus;
  final String batchNumber;
  final String totalJobNumber;

  final EmployeeModel? employee;
  final EmployeeModel? employeeFinish;
  final MachineModel? machine;
  final MachineModel? machineFinish;
  final List<RecordDetailModel> jobnumbers; // pakai RecordDetailModel

  RecordActiveModel({
    required this.idRecord,
    required this.idEmployee,
    required this.idEmployeeFinish,
    required this.idMc,
    required this.idMcFinish,
    required this.idProses,
    required this.startTime,
    required this.finishTime,
    required this.totalPending,
    required this.totalNg,
    required this.cycleTime,
    required this.totalTime,
    required this.runStatus,
    required this.jobStatus,
    required this.batchNumber,
    required this.totalJobNumber,
    required this.employee,
    required this.employeeFinish,
    required this.machine,
    required this.machineFinish,
    required this.jobnumbers,
  });

  factory RecordActiveModel.fromJson(Map<String, dynamic> json) {
    var jobnumbersJson = json['jobnumbers'] as List? ?? [];
    List<RecordDetailModel> jobList =
        jobnumbersJson.map((e) => RecordDetailModel.fromJson(e)).toList();

    return RecordActiveModel(
      idRecord: json['id_record'] ?? '',
      idEmployee: json['id_employee'] ?? '',
      idEmployeeFinish: json['id_employee_finish'] ?? '',
      idMc: json['id_mc'] ?? '',
      idMcFinish: json['id_mc_finish'] ?? '',
      idProses: json['id_proses'] ?? '',
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      finishTime: json['finish_time'] != null
          ? DateTime.parse(json['finish_time'])
          : null,
      totalPending: json['total_pending'] ?? 0,
      totalNg: json['total_ng'] ?? 0,
      cycleTime: (json['cycle_time'] ?? 0).toDouble(),
      totalTime: (json['total_time'] ?? 0).toDouble(),
      runStatus: json['run_status'] ?? '',
      jobStatus: json['job_status'] ?? '',
      batchNumber: json['batch_number'] ?? '',
      totalJobNumber: json['total_jobnumber'] ?? '',
      employee: json['employee'] != null
          ? EmployeeModel.fromJson(json['employee'])
          : null,
      employeeFinish: json['employee_finish'] != null
          ? EmployeeModel.fromJson(json['employee_finish'])
          : null,
      machine: json['machine'] != null
          ? MachineModel.fromJson(json['machine'])
          : null,
      machineFinish: json['machine_finish'] != null
          ? MachineModel.fromJson(json['machine_finish'])
          : null,
      jobnumbers: jobList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_record": idRecord,
      "id_employee": idEmployee,
      "id_employee_finish": idEmployeeFinish,
      "id_mc": idMc,
      "id_mc_finish": idMcFinish,
      "id_proses": idProses,
      "start_time": startTime?.toIso8601String(),
      "finish_time": finishTime?.toIso8601String(),
      "total_pending": totalPending,
      "total_ng": totalNg,
      "cycle_time": cycleTime,
      "total_time": totalTime,
      "run_status": runStatus,
      "job_status": jobStatus,
      "batch_number": batchNumber,
      "total_jobnumber": totalJobNumber,
      "employee": employee?.toJson(),
      "employee_finish": employeeFinish?.toJson(),
      "machine": machine?.toJson(),
      "machine_finish": machineFinish?.toJson(),
      "jobnumbers": jobnumbers.map((e) => e.toJson()).toList(),
    };
  }
}
