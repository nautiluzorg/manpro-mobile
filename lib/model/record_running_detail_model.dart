import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';
import 'package:flutter_provider_data/model/master/proses_model.dart';
import 'package:flutter_provider_data/model/record_detail_model.dart';
import 'package:flutter_provider_data/utils/safe_json_extension.dart';

@immutable
class RecordRunningDetailModel extends Equatable {
  final String idRecord;
  final EmployeeModel activeEmployee;
  final MachineModel activeMachine;
  final ProsesModel proses;
  final String? startTime;
  final String? finishTime;
  final int totalPending;
  final int cycleTime;
  final int totalTime;
  final String runStatus;
  final String jobStatus;
  final bool isDeleted;
  final List<RecordDetailModel> detailsRecord;
  final List<dynamic> ngData;

  const RecordRunningDetailModel({
    required this.idRecord,
    required this.activeEmployee,
    required this.activeMachine,
    required this.proses,
    this.startTime,
    this.finishTime,
    required this.totalPending,
    required this.cycleTime,
    required this.totalTime,
    required this.runStatus,
    required this.jobStatus,
    required this.isDeleted,
    required this.detailsRecord,
    required this.ngData,
  });

  factory RecordRunningDetailModel.fromJson(Map<String, dynamic> json) {
    // Parsing nested objects menggunakan extension safeMap agar anti-crash
    final employeeMap = json.safeMap('active_employee');
    final machineMap = json.safeMap('active_machine');
    final prosesMap = json.safeMap('proses');
    final detailsList = json.safeList('details_record');

    return RecordRunningDetailModel(
      idRecord: json.safeString('id_record'),
      // Jika data null, EmployeeModel.fromJson akan mengembalikan model kosong (asumsi standar project kita)
      activeEmployee: EmployeeModel.fromJson(employeeMap),
      activeMachine: MachineModel.fromJson(machineMap),
      proses: ProsesModel.fromJson(prosesMap),

      startTime: json['start_time']?.toString(),
      finishTime: json['finish_time']?.toString(),
      totalPending: json.safeInt('total_pending'),
      cycleTime: json.safeInt('cycle_time'),
      totalTime: json.safeInt('total_time'),
      runStatus: json.safeString('run_status'),
      jobStatus: json.safeString('job_status'),
      isDeleted: json.safeBool('is_deleted'),

      detailsRecord: detailsList
          .map((d) => d is Map<String, dynamic>
              ? RecordDetailModel.fromJson(d)
              : RecordDetailModel.empty)
          .toList(),
      ngData: json.safeList('ng_data'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_record': idRecord,
      'active_employee': activeEmployee.toJson(),
      'active_machine': activeMachine.toJson(),
      'proses': proses.toJson(),
      'start_time': startTime,
      'finish_time': finishTime,
      'total_pending': totalPending,
      'cycle_time': cycleTime,
      'total_time': totalTime,
      'run_status': runStatus,
      'job_status': jobStatus,
      'is_deleted': isDeleted,
      'details_record': detailsRecord.map((e) => e.toJson()).toList(),
      'ng_data': ngData,
    };
  }

  static const empty = RecordRunningDetailModel(
    idRecord: '',
    activeEmployee: EmployeeModel.empty,
    activeMachine: MachineModel.empty,
    proses: ProsesModel.empty,
    totalPending: 0,
    cycleTime: 0,
    totalTime: 0,
    runStatus: '',
    jobStatus: '',
    isDeleted: false,
    detailsRecord: [],
    ngData: [],
  );

  @override
  List<Object?> get props => [
        idRecord,
        activeEmployee,
        activeMachine,
        proses,
        startTime,
        finishTime,
        totalPending,
        cycleTime,
        totalTime,
        runStatus,
        jobStatus,
        isDeleted,
        detailsRecord,
        ngData,
      ];

  @override
  bool get stringify => true;
}
