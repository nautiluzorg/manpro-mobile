import 'dart:convert';

// Model utama Pending

class Pending {
  final int idPending;
  final Record idRecord;
  final Reason idReason;
  final Employee idEmployee;
  final Proses idProses;
  final Bcode bcode;
  final String statusPending;
  final String startPending;
  final String? finishPending;
  final int totalPending;

  Pending({
    required this.idPending,
    required this.idRecord,
    required this.idReason,
    required this.idEmployee,
    required this.idProses,
    required this.bcode,
    required this.statusPending,
    required this.startPending,
    this.finishPending,
    required this.totalPending,
  });

  factory Pending.fromJson(Map<String, dynamic> json) {
    return Pending(
      idPending: json['id_pending'] ?? 0,
      idRecord: Record.fromJson(json['id_record']),
      idReason: Reason.fromJson(json['id_reason']),
      idEmployee: Employee.fromJson(json['id_employee']),
      idProses: Proses.fromJson(json['id_proses']),
      bcode: Bcode.fromJson(json['bcode']),
      statusPending: json['status_pending'] ?? '',
      startPending: json['start_pending'] ?? '',
      finishPending: json['finish_pending'] ?? '',
      totalPending: json['total_pending'] ?? 0,
    );
  }
}

class Record {
  final String idRecord;
  final Employee idEmployee;
  final Proses idProses;
  final Bcode bcode;
  final Machine idMc;
  final String jobNumber;
  final int startQty;
  final String startTime;
  final String? finishTime;
  final int finishQty;
  final int qtyNg;
  final int totalPending;
  final int cycleTime;
  final int totalTime;
  final String runStatus;
  final String jobStatus;

  Record({
    required this.idRecord,
    required this.idEmployee,
    required this.idProses,
    required this.bcode,
    required this.idMc,
    required this.jobNumber,
    required this.startQty,
    required this.startTime,
    this.finishTime,
    required this.finishQty,
    required this.qtyNg,
    required this.totalPending,
    required this.cycleTime,
    required this.totalTime,
    required this.runStatus,
    required this.jobStatus,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      idRecord: json['id_record'],
      idEmployee: Employee.fromJson(json['id_employee']),
      idProses: Proses.fromJson(json['id_proses']),
      bcode: Bcode.fromJson(json['bcode']),
      idMc: Machine.fromJson(json['id_mc']),
      jobNumber: json['jobnumber'] ?? '',
      startQty: json['start_qty'] ?? 0,
      startTime: json['start_time'] ?? '',
      finishTime: json['finish_time'] ?? '',
      finishQty: json['finish_qty'] ?? 0,
      qtyNg: json['qty_ng'] ?? 0,
      totalPending: json['total_pending'] ?? 0,
      cycleTime: json['cycle_time'] ?? 0,
      totalTime: json['total_time'] ?? 0,
      runStatus: json['run_status'] ?? '',
      jobStatus: json['job_status'] ?? '',
    );
  }
}

class Employee {
  final String idEmployee;
  final String nrp;
  final String fullName;
  final String division;
  final String section;
  final String status;

  Employee({
    required this.idEmployee,
    required this.nrp,
    required this.fullName,
    required this.division,
    required this.section,
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      idEmployee: json['id_employee'] ?? '',
      nrp: json['nrp'],
      fullName: json['full_name'] ?? '',
      division: json['division'] ?? '',
      section: json['section'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class Proses {
  final String idProses;
  final String nameProses;
  final String descriptions;

  Proses({
    required this.idProses,
    required this.nameProses,
    required this.descriptions,
  });

  factory Proses.fromJson(Map<String, dynamic> json) {
    return Proses(
      idProses: json['id_proses'] ?? '',
      nameProses: json['name_proses'] ?? '',
      descriptions: json['descriptions'] ?? '',
    );
  }
}

class Bcode {
  final String bcode;
  final String drawingNumber;
  final String productType;
  final int qtyLot;
  final String codeCompany;
  final String country;

  Bcode({
    required this.bcode,
    required this.drawingNumber,
    required this.productType,
    required this.qtyLot,
    required this.codeCompany,
    required this.country,
  });

  factory Bcode.fromJson(Map<String, dynamic> json) {
    return Bcode(
      bcode: json['bcode'],
      drawingNumber: json['drawing_number'] ?? '',
      productType: json['product_type'] ?? '',
      qtyLot: json['qty_lot'] ?? '',
      codeCompany: json['code_company'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class Machine {
  final String idMc;
  final String nmMc;
  final String typeMc;
  final String brandMc;
  final String serialNumberMc;
  final String dateOfManufactureMc;
  final String statusMc;

  Machine({
    required this.idMc,
    required this.nmMc,
    required this.typeMc,
    required this.brandMc,
    required this.serialNumberMc,
    required this.dateOfManufactureMc,
    required this.statusMc,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      idMc: json['id_mc'] ?? '',
      nmMc: json['nm_mc'],
      typeMc: json['type_mc'] ?? '',
      brandMc: json['brand_mc'] ?? '',
      serialNumberMc: json['serial_number_mc'] ?? '',
      dateOfManufactureMc: json['date_of_manufacture_mc'] ?? '',
      statusMc: json['status_mc'] ?? '',
    );
  }
}

class Reason {
  final String idReason;
  final String nameReason;
  final String description;

  Reason({
    required this.idReason,
    required this.nameReason,
    required this.description,
  });

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(
      idReason: json['id_reason'] ?? '',
      nameReason: json['name_reason'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

List<Pending> parsePendingList(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Pending>((json) => Pending.fromJson(json)).toList();
}
