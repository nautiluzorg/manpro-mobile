//##INI ADALAH MODEL UNTUK MENAMPUNG DATA KEMBALIAN SETELAH MELAKUKAN SCAN JOBNUMBER PADA PROSES MOLDING TEST
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/model/carbonpill_model.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/goldpill_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';
import 'package:flutter_provider_data/model/summary_model.dart';

@immutable
class CheckProsesTestingModel {
  final bool exists;
  final String? idRecordTest;
  final String jobNumber;
  final String idProses;
  final String? nmProses;
  final String? runStatus;
  final String? jobStatus;
  final String? mixLotNo;
  final String? moldNumber;
  final int? moldCavity;
  final int? shootQty;
  final int? totalShootQty;
  final int? testQty;
  final int? finishQty;
  final bool checklistConfirmedMoldSetup;
  final bool checklistConfirmedVacumjigSetup;
  final String? mcTempUpper;
  final String? mcTempLower;
  final String? mcCuring;
  final String? mcPressure;
  final String? mcSettings;
  final EmployeeModel employee;
  final MachineModel machine;
  final SummaryModel summary;
  final GoldPillModel? goldPill;
  final CarbonPillModel? carbonPill;
  final String message;
  final String? notes; // null

  const CheckProsesTestingModel({
    required this.exists,
    required this.jobNumber,
    required this.idProses,
    required this.summary,
    required this.message,
    this.notes, // baru
    this.idRecordTest,
    this.nmProses,
    this.runStatus,
    this.jobStatus,
    this.mixLotNo,
    this.moldNumber,
    this.moldCavity,
    this.shootQty,
    this.totalShootQty,
    this.testQty,
    this.finishQty,
    this.checklistConfirmedMoldSetup = false,
    this.checklistConfirmedVacumjigSetup = false,
    this.mcTempUpper,
    this.mcTempLower,
    this.mcCuring,
    this.mcPressure,
    this.mcSettings,
    this.employee = EmployeeModel.empty,
    this.machine = MachineModel.empty,
    this.goldPill,
    this.carbonPill,
  });

  /// Factory dari API JSON
  factory CheckProsesTestingModel.fromJson(Map<String, dynamic> json) {
    return CheckProsesTestingModel(
      exists: json['exists'] ?? false,
      idRecordTest: json['id_record_test']?.toString(),
      jobNumber: json['jobnumber'] ?? '',
      idProses: json['id_proses'] ?? '',
      nmProses: json['nm_proses'],
      runStatus: json['run_status'],
      jobStatus: json['job_status'],
      mixLotNo: json['mix_lot_no'],
      moldNumber: json['moldnumber'],
      moldCavity: json['moldcavity'],
      shootQty: json['shoot_qty'],
      totalShootQty: json['total_shoot_qty'],
      testQty: json['test_qty'],
      finishQty: json['finish_qty'],
      checklistConfirmedMoldSetup:
          json['checklist_confirmed_mold_setup'] ?? false,
      checklistConfirmedVacumjigSetup:
          json['checklist_confirmed_vacumjig_setup'] ?? false,
      mcTempUpper: json['mc_temp_upper'],
      mcTempLower: json['mc_temp_lower'],
      mcCuring: json['mc_curing'],
      mcPressure: json['mc_pressure'],
      mcSettings: json['mc_settings'],
      employee: json['employee'] != null
          ? EmployeeModel.fromJson(json['employee'])
          : EmployeeModel.empty,
      machine: json['machine'] != null
          ? MachineModel.fromJson(json['machine'])
          : MachineModel.empty,
      summary: json['summary'] != null
          ? SummaryModel.fromJson(json['summary'])
          : SummaryModel.empty,
      goldPill: json['gold_pill'] != null
          ? GoldPillModel.fromJson(json['gold_pill'])
          : null,
      carbonPill: json['carbon_pill'] != null
          ? CarbonPillModel.fromJson(json['carbon_pill'])
          : null,
      message: json['message'] ?? '',
      notes: json['notes'],
    );
  }

  /// Serialize ke JSON
  Map<String, dynamic> toJson() {
    return {
      "exists": exists,
      "id_record_test": idRecordTest,
      "jobnumber": jobNumber,
      "id_proses": idProses,
      "nm_proses": nmProses,
      "run_status": runStatus,
      "job_status": jobStatus,
      "mix_lot_no": mixLotNo,
      "moldnumber": moldNumber,
      "moldcavity": moldCavity,
      "shoot_qty": shootQty,
      "total_shoot_qty": totalShootQty,
      "test_qty": testQty,
      "finish_qty": finishQty,
      "checklist_confirmed_mold_setup": checklistConfirmedMoldSetup,
      "checklist_confirmed_vacumjig_setup": checklistConfirmedVacumjigSetup,
      "mc_temp_upper": mcTempUpper,
      "mc_temp_lower": mcTempLower,
      "mc_curing": mcCuring,
      "mc_pressure": mcPressure,
      "mc_settings": mcSettings,
      "employee": employee.toJson(),
      "machine": machine.toJson(),
      "summary": summary.toJson(),
      "gold_pill": goldPill?.toJson(),
      "carbon_pill": carbonPill?.toJson(),
      "message": message,
      "notes": notes, // tambahkan baris ini
    };
  }

  /// ================= EMPTY (SAFE DEFAULT) =================
  /// Representasi proses testing kosong
  /// Aman untuk initial state Provider / UI
  static const empty = CheckProsesTestingModel(
    exists: false,

    // IDENTITAS
    idRecordTest: null,
    jobNumber: '',
    idProses: '',
    nmProses: null,

    // STATUS
    runStatus: null,
    jobStatus: null,

    // PRODUKSI
    mixLotNo: null,
    moldNumber: null,
    moldCavity: null,
    shootQty: null,
    totalShootQty: null,
    testQty: null,
    finishQty: null,

    // CHECKLIST
    checklistConfirmedMoldSetup: false,
    checklistConfirmedVacumjigSetup: false,

    // MACHINE SETTING
    mcTempUpper: null,
    mcTempLower: null,
    mcCuring: null,
    mcPressure: null,
    mcSettings: null,

    // RELATION
    employee: EmployeeModel.empty,
    machine: MachineModel.empty,
    summary: SummaryModel.empty,
    goldPill: null,
    carbonPill: null,

    // MESSAGE
    message: '',
    notes: null, // default null
  );

  /// Copy with (untuk update immutable)
  CheckProsesTestingModel copyWith({
    bool? exists,
    String? idRecordTest,
    String? jobNumber,
    String? idProses,
    String? nmProses,
    String? runStatus,
    String? jobStatus,
    String? mixLotNo,
    String? moldNumber,
    int? moldCavity,
    int? shootQty,
    int? totalShootQty,
    int? testQty,
    int? finishQty,
    bool? checklistConfirmedMoldSetup,
    bool? checklistConfirmedVacumjigSetup,
    String? mcTempUpper,
    String? mcTempLower,
    String? mcCuring,
    String? mcPressure,
    String? mcSettings,
    EmployeeModel? employee,
    MachineModel? machine,
    SummaryModel? summary,
    GoldPillModel? goldPill,
    CarbonPillModel? carbonPill,
    String? message,
  }) {
    return CheckProsesTestingModel(
      exists: exists ?? this.exists,
      idRecordTest: idRecordTest ?? this.idRecordTest,
      jobNumber: jobNumber ?? this.jobNumber,
      idProses: idProses ?? this.idProses,
      nmProses: nmProses ?? this.nmProses,
      runStatus: runStatus ?? this.runStatus,
      jobStatus: jobStatus ?? this.jobStatus,
      mixLotNo: mixLotNo ?? this.mixLotNo,
      moldNumber: moldNumber ?? this.moldNumber,
      moldCavity: moldCavity ?? this.moldCavity,
      shootQty: shootQty ?? this.shootQty,
      totalShootQty: totalShootQty ?? this.totalShootQty,
      testQty: testQty ?? this.testQty,
      finishQty: finishQty ?? this.finishQty,
      checklistConfirmedMoldSetup:
          checklistConfirmedMoldSetup ?? this.checklistConfirmedMoldSetup,
      checklistConfirmedVacumjigSetup: checklistConfirmedVacumjigSetup ??
          this.checklistConfirmedVacumjigSetup,
      mcTempUpper: mcTempUpper ?? this.mcTempUpper,
      mcTempLower: mcTempLower ?? this.mcTempLower,
      mcCuring: mcCuring ?? this.mcCuring,
      mcPressure: mcPressure ?? this.mcPressure,
      mcSettings: mcSettings ?? this.mcSettings,
      employee: employee ?? this.employee,
      machine: machine ?? this.machine,
      summary: summary ?? this.summary,
      goldPill: goldPill ?? this.goldPill,
      carbonPill: carbonPill ?? this.carbonPill,
      message: message ?? this.message,
    );
  }
}
