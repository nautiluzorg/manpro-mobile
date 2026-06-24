import 'master/employee_model.dart';
import 'master/machine_model.dart';
import 'master/proses_model.dart';
import 'master/reason_model.dart';
import 'master/product_model.dart';

class RecordFinishDetailModel {
  final String idRecord;
  final EmployeeModel employee;
  final EmployeeModel employeeFinish;
  final MachineModel machine;
  final MachineModel machineFinish;
  final ProsesModel proses;
  final String startTime;
  final String finishTime;
  final int totalPending;
  final int totalNg;
  final int cycleTime;
  final int totalTime;
  final String runStatus;
  final String jobStatus;
  final bool isMultiOperator;
  final bool isDeleted;
  final String? deletedAt;
  final String? deletedBy;
  final String batchNumber;
  final String totalJobnumber;

  final List<DetailsRecord> detailsRecord;
  final List<RecordPending> recordPendings;
  final List<NgRecord> recordNgs;
  final List<RecordShoot> recordShoots;
  final List<RecordMachine> recordMachines; // <--- tambahkan ini

  RecordFinishDetailModel({
    required this.idRecord,
    required this.employee,
    required this.employeeFinish,
    required this.machine,
    required this.machineFinish,
    required this.proses,
    required this.startTime,
    required this.finishTime,
    required this.totalPending,
    required this.totalNg,
    required this.cycleTime,
    required this.totalTime,
    required this.runStatus,
    required this.jobStatus,
    required this.isMultiOperator,
    required this.isDeleted,
    this.deletedAt,
    this.deletedBy,
    required this.batchNumber,
    required this.totalJobnumber,
    required this.detailsRecord,
    required this.recordPendings,
    required this.recordNgs,
    required this.recordShoots,
    required this.recordMachines,
  });

  factory RecordFinishDetailModel.fromJson(Map<String, dynamic> json) {
    return RecordFinishDetailModel(
      idRecord: json['id_record'],
      employee: EmployeeModel.fromJson(json['employee']),
      employeeFinish: EmployeeModel.fromJson(json['employee_finish']),
      machine: MachineModel.fromJson(json['machine']),
      machineFinish: MachineModel.fromJson(json['machine_finish']),
      proses: ProsesModel.fromJson(json['proses']),
      startTime: json['start_time'],
      finishTime: json['finish_time'],
      totalPending: json['total_pending'],
      totalNg: json['total_ng'],
      cycleTime: json['cycle_time'],
      totalTime: json['total_time'],
      runStatus: json['run_status'],
      jobStatus: json['job_status'],
      isMultiOperator: json['is_multi_operator'],
      isDeleted: json['is_deleted'],
      deletedAt: json['deleted_at'],
      deletedBy: json['deleted_by'],
      batchNumber: json['batch_number'],
      totalJobnumber: json['total_jobnumber'],
      detailsRecord: (json['details_record'] as List)
          .map((e) => DetailsRecord.fromJson(e))
          .toList(),
      recordPendings: (json['record_pendings'] as List)
          .map((e) => RecordPending.fromJson(e))
          .toList(),
      recordNgs: (json['record_ngs'] as List)
          .map((e) => NgRecord.fromJson(e))
          .toList(),
      recordShoots: (json['record_shoots'] as List)
          .map((e) => RecordShoot.fromJson(e))
          .toList(),
      recordMachines: (json['record_machines'] as List)
          .map((e) => RecordMachine.fromJson(e))
          .toList(),
    );
  }
}

// ================= Sub Models ================= //

class DetailsRecord {
  final int id;
  final ProductModel bcode;
  final String jobnumber;
  final String lotnumber;
  final int startQty;
  final int finishQty;
  final String mixLotNo;
  final String moldnumber;
  final int moldcavity;
  final int shootQty;
  final int? goldPill;
  final int? carbonPill;

  DetailsRecord({
    required this.id,
    required this.bcode,
    required this.jobnumber,
    required this.lotnumber,
    required this.startQty,
    required this.finishQty,
    required this.mixLotNo,
    required this.moldnumber,
    required this.moldcavity,
    required this.shootQty,
    this.goldPill,
    this.carbonPill,
  });

  factory DetailsRecord.fromJson(Map<String, dynamic> json) {
    return DetailsRecord(
      id: json['id'] ?? 0,
      bcode: ProductModel.fromJson(json['bcode']),
      jobnumber: json['jobnumber'] ?? '',
      lotnumber: json['lotnumber'] ?? '',
      startQty: json['start_qty'] ?? 0,
      finishQty: json['finish_qty'] ?? 0,
      mixLotNo: json['mix_lot_no'] ?? '',
      moldnumber: json['moldnumber'] ?? '',
      moldcavity: json['moldcavity'] ?? 0,
      shootQty: json['shoot_qty'] ?? 0,
      goldPill: json['gold_pill'],
      carbonPill: json['carbon_pill'],
    );
  }
}

class RecordPending {
  final int idPending;
  final String startPending;
  final String finishPending;
  final int totalPending;
  final String statusPending;
  final ReasonModel reason;
  final EmployeeModel employee;
  final ProductModel bcode;

  RecordPending({
    required this.idPending,
    required this.startPending,
    required this.finishPending,
    required this.totalPending,
    required this.statusPending,
    required this.reason,
    required this.employee,
    required this.bcode,
  });

  factory RecordPending.fromJson(Map<String, dynamic> json) {
    return RecordPending(
      idPending: json['id_pending'] ?? 0,
      startPending: json['start_pending'] ?? '',
      finishPending: json['finish_pending'] ?? '',
      totalPending: json['total_pending'] ?? 0,
      statusPending: json['status_pending'] ?? '',
      reason: ReasonModel.fromJson(json['id_reason']),
      employee: EmployeeModel.fromJson(json['id_employee']),
      bcode: ProductModel.fromJson(json['bcode']),
    );
  }
}

class NgRecord {
  final String idNg;
  final String ngName;
  final int qty;

  NgRecord({
    required this.idNg,
    required this.ngName,
    required this.qty,
  });

  factory NgRecord.fromJson(Map<String, dynamic> json) {
    return NgRecord(
      idNg: json['id_ng'] ?? '',
      ngName: json['ng_name'] ?? '',
      qty: json['qty'] ?? 0,
    );
  }
}

class RecordShoot {
  final int id;
  final String jobnumber;
  final int totalNg;
  final int shootQty;
  final String idRecord;
  final String idEmployeeFinish;
  final String fullName;

  RecordShoot({
    required this.id,
    required this.jobnumber,
    required this.totalNg,
    required this.shootQty,
    required this.idRecord,
    required this.idEmployeeFinish,
    required this.fullName,
  });

  factory RecordShoot.fromJson(Map<String, dynamic> json) {
    return RecordShoot(
      id: json['id'],
      jobnumber: json['jobnumber'],
      totalNg: json['total_ng'],
      shootQty: json['shoot_qty'],
      idRecord: json['id_record'],
      idEmployeeFinish: json['id_employee_finish'],
      fullName: json['full_name'],
    );
  }
}

class RecordMachine {
  final int id;
  final String idMc;
  final String nmMc;

  RecordMachine({
    required this.id,
    required this.idMc,
    required this.nmMc,
  });

  factory RecordMachine.fromJson(Map<String, dynamic> json) {
    return RecordMachine(
      id: json['id'] ?? 0,
      idMc: json['id_mc'] ?? '',
      nmMc: json['nm_mc'] ?? '',
    );
  }
}





/*
import 'employee_model.dart';
import 'machine_model.dart';
import 'proses_model.dart';
import 'reason_model.dart';
// import 'ng_dropdown_model.dart';
import 'product_model.dart';

class RecordFinishDetailModel {
  final String idRecord;
  final EmployeeModel employee;
  final EmployeeModel employeeFinish;
  final MachineModel machine;
  final MachineModel machineFinish;
  final ProsesModel proses;
  final String startTime;
  final String finishTime;
  final int totalPending;
  final int totalNg;
  final int cycleTime;
  final int totalTime;
  final String runStatus;
  final String jobStatus;
  final bool isMultiOperator;
  final bool isDeleted;
  final String? deletedAt;
  final String? deletedBy;
  final String batchNumber;
  final String totalJobnumber;

  final List<DetailsRecord> detailsRecord;
  final List<RecordPending> recordPendings;
  final List<NgRecord> recordNgs;
  final List<RecordShoot> recordShoots;

  RecordFinishDetailModel({
    required this.idRecord,
    required this.employee,
    required this.employeeFinish,
    required this.machine,
    required this.machineFinish,
    required this.proses,
    required this.startTime,
    required this.finishTime,
    required this.totalPending,
    required this.totalNg,
    required this.cycleTime,
    required this.totalTime,
    required this.runStatus,
    required this.jobStatus,
    required this.isMultiOperator,
    required this.isDeleted,
    this.deletedAt,
    this.deletedBy,
    required this.batchNumber,
    required this.totalJobnumber,
    required this.detailsRecord,
    required this.recordPendings,
    required this.recordNgs,
    required this.recordShoots,
  });

  factory RecordFinishDetailModel.fromJson(Map<String, dynamic> json) {
    return RecordFinishDetailModel(
      idRecord: json['id_record'] ?? '',
      employee: EmployeeModel.fromJson(json['employee']),
      employeeFinish: EmployeeModel.fromJson(json['employee_finish']),
      machine: MachineModel.fromJson(json['machine']),
      machineFinish: MachineModel.fromJson(json['machine_finish']),
      proses: ProsesModel.fromJson(json['proses']),
      startTime: json['start_time'] ?? '',
      finishTime: json['finish_time'] ?? '',
      totalPending: json['total_pending'] ?? 0,
      totalNg: json['total_ng'] ?? 0,
      cycleTime: json['cycle_time'] ?? 0,
      totalTime: json['total_time'] ?? 0,
      runStatus: json['run_status'] ?? '',
      jobStatus: json['job_status'] ?? '',
      isMultiOperator: json['is_multi_operator'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'],
      deletedBy: json['deleted_by'],
      batchNumber: json['batch_number'] ?? '',
      totalJobnumber: json['total_jobnumber'] ?? '',
      detailsRecord: (json['details_record'] as List<dynamic>?)
              ?.map((e) => DetailsRecord.fromJson(e))
              .toList() ??
          [],
      recordPendings: (json['record_pendings'] as List<dynamic>?)
              ?.map((e) => RecordPending.fromJson(e))
              .toList() ??
          [],
      recordNgs: (json['record_ngs'] as List<dynamic>?)
              ?.map((e) => NgRecord.fromJson(e))
              .toList() ??
          [],
      recordShoots: (json['record_shoots'] as List<dynamic>?)
              ?.map((e) => RecordShoot.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// ================= Sub Models ================= //

class DetailsRecord {
  final int id;
  final ProductModel bcode;
  final String jobnumber;
  final String lotnumber;
  final int startQty;
  final int finishQty;
  final String mixLotNo;
  final String moldnumber;
  final int moldcavity;
  final int shootQty;
  final int? goldPill;
  final int? carbonPill;

  DetailsRecord({
    required this.id,
    required this.bcode,
    required this.jobnumber,
    required this.lotnumber,
    required this.startQty,
    required this.finishQty,
    required this.mixLotNo,
    required this.moldnumber,
    required this.moldcavity,
    required this.shootQty,
    this.goldPill,
    this.carbonPill,
  });

  factory DetailsRecord.fromJson(Map<String, dynamic> json) {
    return DetailsRecord(
      id: json['id'] ?? 0,
      bcode: ProductModel.fromJson(json['bcode']),
      jobnumber: json['jobnumber'] ?? '',
      lotnumber: json['lotnumber'] ?? '',
      startQty: json['start_qty'] ?? 0,
      finishQty: json['finish_qty'] ?? 0,
      mixLotNo: json['mix_lot_no'] ?? '',
      moldnumber: json['moldnumber'] ?? '',
      moldcavity: json['moldcavity'] ?? 0,
      shootQty: json['shoot_qty'] ?? 0,
      goldPill: json['gold_pill'],
      carbonPill: json['carbon_pill'],
    );
  }
}

class RecordPending {
  final int idPending;
  final String startPending;
  final String finishPending;
  final int totalPending;
  final String statusPending;
  final ReasonModel reason;
  final EmployeeModel employee;
  final ProductModel bcode;

  RecordPending({
    required this.idPending,
    required this.startPending,
    required this.finishPending,
    required this.totalPending,
    required this.statusPending,
    required this.reason,
    required this.employee,
    required this.bcode,
  });

  factory RecordPending.fromJson(Map<String, dynamic> json) {
    return RecordPending(
      idPending: json['id_pending'] ?? 0,
      startPending: json['start_pending'] ?? '',
      finishPending: json['finish_pending'] ?? '',
      totalPending: json['total_pending'] ?? 0,
      statusPending: json['status_pending'] ?? '',
      reason: ReasonModel.fromJson(json['id_reason']),
      employee: EmployeeModel.fromJson(json['id_employee']),
      bcode: ProductModel.fromJson(json['bcode']),
    );
  }
}

class NgRecord {
  final String idNg;
  final String ngName;
  final int qty;

  NgRecord({
    required this.idNg,
    required this.ngName,
    required this.qty,
  });

  factory NgRecord.fromJson(Map<String, dynamic> json) {
    return NgRecord(
      idNg: json['id_ng'] ?? '',
      ngName: json['ng_name'] ?? '',
      qty: json['qty'] ?? 0,
    );
  }
}

class RecordShoot {
  final int id;
  final String jobnumber;
  final int totalNg;
  final int shootQty;
  final String idRecord;
  final String idEmployeeFinish;

  RecordShoot({
    required this.id,
    required this.jobnumber,
    required this.totalNg,
    required this.shootQty,
    required this.idRecord,
    required this.idEmployeeFinish,
  });

  factory RecordShoot.fromJson(Map<String, dynamic> json) {
    return RecordShoot(
      id: json['id'] ?? 0,
      jobnumber: json['jobnumber'] ?? '',
      totalNg: json['total_ng'] ?? 0,
      shootQty: json['shoot_qty'] ?? 0,
      idRecord: json['id_record'] ?? '',
      idEmployeeFinish: json['id_employee_finish'] ?? '',
    );
  }
}
*/


