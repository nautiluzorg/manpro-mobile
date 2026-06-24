class MonitorTestingModel {
  final int count;
  final List<RecordTesting> results;

  MonitorTestingModel({
    required this.count,
    required this.results,
  });

  factory MonitorTestingModel.fromJson(Map<String, dynamic> json) {
    return MonitorTestingModel(
      count: json['count'] ?? 0,
      results: (json['results'] as List)
          .map((item) => RecordTesting.fromJson(item))
          .toList(),
    );
  }
}

class RecordTesting {
  final String idRecordTest;
  final Employee employee;
  final Machine machine;
  final Proses proses;
  final String? startTime;
  final String? finishTime;
  final String runStatus;
  final String jobStatus;
  final int totalJobnumber;
  final int totalTime;
  final String? notes;
  final List<RecordTestingDetail> details;

  RecordTesting({
    required this.idRecordTest,
    required this.employee,
    required this.machine,
    required this.proses,
    this.startTime,
    this.finishTime,
    required this.runStatus,
    required this.jobStatus,
    required this.totalJobnumber,
    required this.totalTime,
    this.notes,
    required this.details,
  });

  factory RecordTesting.fromJson(Map<String, dynamic> json) {
    return RecordTesting(
      idRecordTest: json['id_record_test'],
      employee: Employee.fromJson(json['employee']),
      machine: Machine.fromJson(json['machine']),
      proses: Proses.fromJson(json['proses']),
      startTime: json['start_time'],
      finishTime: json['finish_time'],
      runStatus: json['run_status'],
      jobStatus: json['job_status'],
      totalJobnumber: json['total_jobnumber'] ?? 0,
      totalTime: json['total_time'] ?? 0,
      notes: json['notes'],
      details: (json['details'] as List)
          .map((d) => RecordTestingDetail.fromJson(d))
          .toList(),
    );
  }
}

class Employee {
  final String idEmployee;
  final String fullName;
  final String nrp;
  final String division;
  final String section;

  Employee({
    required this.idEmployee,
    required this.fullName,
    required this.nrp,
    required this.division,
    required this.section,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      idEmployee: json['id_employee'],
      fullName: json['full_name'],
      nrp: json['nrp'],
      division: json['division'],
      section: json['section'],
    );
  }
}

class Machine {
  final String idMc;
  final String nmMc;
  final String typeMc;
  final String brandMc;
  final String modelMc;
  final String serialNumberMc;
  final String areaMc;

  Machine({
    required this.idMc,
    required this.nmMc,
    required this.typeMc,
    required this.brandMc,
    required this.modelMc,
    required this.serialNumberMc,
    required this.areaMc,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      idMc: json['id_mc'],
      nmMc: json['nm_mc'],
      typeMc: json['type_mc'],
      brandMc: json['brand_mc'],
      modelMc: json['model_mc'],
      serialNumberMc: json['serial_number_mc'],
      areaMc: json['area_mc'],
    );
  }
}

class Proses {
  final String idProses;
  final String nameProses;

  Proses({
    required this.idProses,
    required this.nameProses,
  });

  factory Proses.fromJson(Map<String, dynamic> json) {
    return Proses(
      idProses: json['id_proses'],
      nameProses: json['name_proses'],
    );
  }
}

class RecordTestingDetail {
  final int id;
  final String jobnumber;
  final String? lotnumber;
  final String? moldnumber;
  final int? moldcavity;
  final int? shootQty;
  final int? totalShootQty;
  final int? testQty;
  final int? finishQty;
  final String? mixLotNo;
  final int? goldPillId;
  final int? carbonPillId;
  final String? drawingNumber;

  RecordTestingDetail({
    required this.id,
    required this.jobnumber,
    this.lotnumber,
    this.moldnumber,
    this.moldcavity,
    this.shootQty,
    this.totalShootQty,
    this.testQty,
    this.finishQty,
    this.mixLotNo,
    this.goldPillId,
    this.carbonPillId,
    this.drawingNumber,
  });

  factory RecordTestingDetail.fromJson(Map<String, dynamic> json) {
    return RecordTestingDetail(
      id: json['id'],
      jobnumber: json['jobnumber'],
      lotnumber: json['lotnumber'],
      moldnumber: json['moldnumber'],
      moldcavity: json['moldcavity'],
      shootQty: json['shoot_qty'],
      totalShootQty: json['total_shoot_qty'],
      testQty: json['test_qty'],
      finishQty: json['finish_qty'],
      mixLotNo: json['mix_lot_no'],
      goldPillId: json['gold_pill_id'],
      carbonPillId: json['carbon_pill_id'],
      drawingNumber: json['drawing_number'],
    );
  }
}
