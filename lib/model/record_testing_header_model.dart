import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';

@immutable
class RecordTestingHeaderModel {
  final String idRecordTest;
  final String runStatus;
  final String jobStatus;
  final String status;
  final String? notes;
  final DateTime startTime;
  final DateTime? finishTime;
  final int totalTime;
  final int totalJobnumber;

  final EmployeeModel employee;
  final MachineModel machine;

  const RecordTestingHeaderModel({
    required this.idRecordTest,
    required this.runStatus,
    required this.jobStatus,
    required this.status,
    this.notes,
    required this.startTime,
    this.finishTime,
    required this.totalTime,
    required this.totalJobnumber,
    required this.employee,
    required this.machine,
  });

  factory RecordTestingHeaderModel.fromJson(Map<String, dynamic> json) {
    return RecordTestingHeaderModel(
      idRecordTest: json['id_record_test']?.toString() ?? '',
      runStatus: json['run_status']?.toString() ?? '',
      jobStatus: json['job_status']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      startTime: DateTime.parse(json['start_time']),
      finishTime: json['finish_time'] != null
          ? DateTime.parse(json['finish_time'])
          : null,
      totalTime: json['total_time'] ?? 0,
      totalJobnumber: json['total_jobnumber'] ?? 0,
      employee: EmployeeModel.fromJson(json['employee'] ?? {}),
      machine: MachineModel.fromJson(json['machine'] ?? {}),
    );
  }

  bool get isActive => jobStatus == 'open';

  @override
  String toString() {
    return 'RecordTestingHeader(id: $idRecordTest, status: $runStatus)';
  }
}
