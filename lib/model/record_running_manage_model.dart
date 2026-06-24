import 'package:flutter_provider_data/model/record_detail_model.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';

class RecordRunningManageModel {
  String idRecord;
  EmployeeModel employee;
  EmployeeModel? employeeFinish;
  MachineModel machine;
  MachineModel? machineFinish;
  String idProses;
  DateTime startTime;
  List<RecordDetailModel> detailsRecord;
  String batchNumber;
  String totalJobnumber;

  RecordRunningManageModel({
    required this.idRecord,
    required this.employee,
    this.employeeFinish,
    required this.machine,
    this.machineFinish,
    required this.idProses,
    required this.startTime,
    required this.detailsRecord,
    required this.batchNumber,
    required this.totalJobnumber,
  });

  factory RecordRunningManageModel.fromJson(Map<String, dynamic> json) {
    // 1. Mapping Employee (Start)
    final employee = EmployeeModel(
      idEmployee: json['id_employee']?.toString() ?? '',
      nrp: '',
      fullName: json['employee_name'] ?? 'Not Available',
      division: '',
      section: '',
      status: '',
    );

    // 2. Mapping Employee (Finish) - Optional
    final employeeFinish = (json['id_employee_finish'] != null)
        ? EmployeeModel(
            idEmployee: json['id_employee_finish'].toString(),
            nrp: '',
            fullName: json['employee_finish_name'] ?? 'Not Available',
            division: '',
            section: '',
            status: '',
          )
        : null;

    // 3. Mapping Machine (Start)
    // REVISI: Menggunakan copyWith agar field wajib di MachineModel terbaru terpenuhi semua
    final machine = MachineModel.empty.copyWith(
      idMc: json['id_mc']?.toString() ?? '',
      nmMc: json['machine_name']?.toString() ?? 'Not Available',
      // Jika dari backend ada data area, SN, dll, bisa ditambah di sini
      areaMc: json['area_mc']?.toString() ?? '',
    );

    // 4. Mapping Machine (Finish) - Optional
    final machineFinish = (json['id_mc_finish'] != null)
        ? MachineModel.empty.copyWith(
            idMc: json['id_mc_finish'].toString(),
            nmMc: json['machine_finish_name'] ?? 'Not Available',
            areaMc: json['area_mc_finish']?.toString() ?? '',
          )
        : null;

    return RecordRunningManageModel(
      idRecord: json['id_record']?.toString() ?? '',
      employee: employee,
      employeeFinish: employeeFinish,
      machine: machine,
      machineFinish: machineFinish,
      idProses: json['id_proses']?.toString() ?? '',
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : DateTime.now(),
      detailsRecord: (json['details_record'] as List?)
              ?.map((e) => RecordDetailModel.fromJson(e))
              .toList() ??
          [],
      batchNumber: json['batch_number']?.toString() ?? '',
      totalJobnumber: json['total_jobnumber']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_record': idRecord,
      'id_employee': employee.idEmployee,
      'employee_name': employee.fullName,
      'id_employee_finish': employeeFinish?.idEmployee,
      'employee_finish_name': employeeFinish?.fullName,
      'id_mc': machine.idMc,
      'machine_name': machine.nmMc,
      'id_mc_finish': machineFinish?.idMc,
      'machine_finish_name': machineFinish?.nmMc,
      'id_proses': idProses,
      'start_time': startTime.toIso8601String(),
      'details_record': detailsRecord.map((e) => e.toJson()).toList(),
      'batch_number': batchNumber,
      'total_jobnumber': totalJobnumber,
    };
  }
}
