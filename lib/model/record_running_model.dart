import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';
import 'package:flutter_provider_data/model/master/proses_model.dart';
import 'package:flutter_provider_data/model/record_detail_model.dart';
import 'package:flutter_provider_data/utils/safe_json_extension.dart';

@immutable
class RecordRunningModel extends Equatable {
  final String idRecord;
  final String idProses;
  final String batchNumber;
  final String totalJobnumber;
  final String? startTime;
  final String? finishTime;
  final int totalPending;
  final int totalNg;
  final int cycleTime;
  final int totalTime;
  final String runStatus;
  final String jobStatus;
  final String? notes;
  final bool isDeleted;
  final List<RecordDetailModel> detailsRecord;
  final EmployeeModel? activeEmployee;
  final MachineModel? activeMachine;
  final ProsesModel proses;

  const RecordRunningModel({
    required this.idRecord,
    required this.idProses,
    required this.batchNumber,
    required this.totalJobnumber,
    this.startTime,
    this.finishTime,
    required this.totalPending,
    required this.totalNg,
    required this.cycleTime,
    required this.totalTime,
    required this.runStatus,
    required this.jobStatus,
    this.notes,
    required this.isDeleted,
    required this.detailsRecord,
    required this.proses,
    this.activeEmployee,
    this.activeMachine,
  });

  // ── Static Empty ──────────────────────────────────────────
  static const empty = RecordRunningModel(
    idRecord: '',
    idProses: '',
    batchNumber: '',
    totalJobnumber: '',
    totalPending: 0,
    totalNg: 0,
    cycleTime: 0,
    totalTime: 0,
    runStatus: '',
    jobStatus: '',
    isDeleted: false,
    detailsRecord: [],
    proses: ProsesModel.empty,
    activeEmployee: null,
    activeMachine: null,
  );

  bool get isEmpty => this == RecordRunningModel.empty;
  bool get isNotEmpty => this != RecordRunningModel.empty;

  // ── Status Getters ────────────────────────────────────────
  bool get isOpen => jobStatus.toLowerCase() == 'open';
  bool get isRunning => runStatus.toLowerCase() == 'running';
  bool get isClosed => jobStatus.toLowerCase() == 'close';
  bool get isPending => runStatus.toLowerCase() == 'pending'; // ✅ tambahan

  // ── fromJson (Safe Parsing) ───────────────────────────────
  factory RecordRunningModel.fromJson(Map<String, dynamic> json) {
    final prosesMap = json.safeMap('proses');
    final ProsesModel finalProses = prosesMap.isNotEmpty
        ? ProsesModel.fromJson(prosesMap)
        : ProsesModel(
            idProses: json.safeString('id_proses'),
            nameProses: json.safeString('id_proses'),
          );

    return RecordRunningModel(
      idRecord: json.safeString('id_record'),
      idProses: json.safeString('id_proses'),
      batchNumber: json.safeString('batch_number'),
      totalJobnumber: json.safeString('total_jobnumber'),
      startTime: json['start_time']?.toString(),
      finishTime: json['finish_time']?.toString(),
      totalPending: json.safeInt('total_pending'),
      totalNg: json.safeInt('total_ng'),
      cycleTime: json.safeInt('cycle_time'),
      totalTime: json.safeInt('total_time'),
      runStatus: json.safeString('run_status'),
      jobStatus: json.safeString('job_status'),
      notes: json['notes']?.toString(),
      isDeleted: json.safeBool('is_deleted'),
      detailsRecord: json.safeObjectList(
        'details_record',
        (m) => RecordDetailModel.fromJson(m),
        defaultValue: RecordDetailModel.empty,
      ),
      proses: finalProses,
      activeEmployee:
          json.safeObject('active_employee', EmployeeModel.fromJson),
      activeMachine: json.safeObject('active_machine', MachineModel.fromJson),
    );
  }

  // ── toJson ────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id_record': idRecord,
      'id_proses': idProses,
      'batch_number': batchNumber,
      'total_jobnumber': totalJobnumber,
      'start_time': startTime,
      'finish_time': finishTime,
      'total_pending': totalPending,
      'total_ng': totalNg,
      'cycle_time': cycleTime,
      'total_time': totalTime,
      'run_status': runStatus,
      'job_status': jobStatus,
      'notes': notes,
      'is_deleted': isDeleted,
      'details_record': detailsRecord.map((d) => d.toJson()).toList(),
      'proses': proses.toJson(),
      'active_employee': activeEmployee?.toJson(),
      'active_machine': activeMachine?.toJson(),
    };
  }

  // ── copyWith ──────────────────────────────────────────────
  RecordRunningModel copyWith({
    String? idRecord,
    String? idProses,
    String? batchNumber,
    String? totalJobnumber,
    String? startTime,
    String? finishTime,
    int? totalPending,
    int? totalNg,
    int? cycleTime,
    int? totalTime,
    String? runStatus,
    String? jobStatus,
    String? notes,
    bool? isDeleted,
    List<RecordDetailModel>? detailsRecord,
    ProsesModel? proses,
    EmployeeModel? activeEmployee,
    MachineModel? activeMachine,
  }) {
    return RecordRunningModel(
      idRecord: idRecord ?? this.idRecord,
      idProses: idProses ?? this.idProses,
      batchNumber: batchNumber ?? this.batchNumber,
      totalJobnumber: totalJobnumber ?? this.totalJobnumber,
      startTime: startTime ?? this.startTime,
      finishTime: finishTime ?? this.finishTime,
      totalPending: totalPending ?? this.totalPending,
      totalNg: totalNg ?? this.totalNg,
      cycleTime: cycleTime ?? this.cycleTime,
      totalTime: totalTime ?? this.totalTime,
      runStatus: runStatus ?? this.runStatus,
      jobStatus: jobStatus ?? this.jobStatus,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      detailsRecord: detailsRecord ?? this.detailsRecord,
      proses: proses ?? this.proses,
      activeEmployee: activeEmployee ?? this.activeEmployee,
      activeMachine: activeMachine ?? this.activeMachine,
    );
  }

  // ── Equatable ─────────────────────────────────────────────
  @override
  List<Object?> get props => [
        idRecord,
        idProses,
        batchNumber,
        totalJobnumber,
        startTime,
        finishTime,
        totalPending,
        totalNg,
        cycleTime,
        totalTime,
        runStatus,
        jobStatus,
        notes,
        isDeleted,
        detailsRecord,
        activeEmployee,
        activeMachine,
        proses,
      ];

  @override
  bool get stringify => true;
}
