class RecordModel {
  final String idRecord;
  final Employee idEmployee; // <- ini string, karena dari field "id_employee"
  final Machine idMc;
  final Proses idProses;
  final String? startTime;
  final String? finishTime;
  final int totalPending;
  final int cycleTime;
  final int totalTime;
  final String runStatus;
  final String jobStatus;
  final bool isDeleted;
  final List<RecordDetail> detailsRecord;
  final List<dynamic> ngData;

  RecordModel({
    required this.idRecord,
    required this.idEmployee,
    required this.idMc,
    required this.idProses,
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
  factory RecordModel.fromJson(Map<String, dynamic> json) {
    var detailsJson = json['details_record'] as List<dynamic>? ?? [];

    return RecordModel(
      idRecord: json['id_record'] ?? '',
      idEmployee: Employee.fromJson(json['id_employee'] ?? {}),
      idMc: Machine.fromJson(json['id_mc'] ?? {}),
      idProses: Proses.fromJson(json['id_proses'] ?? {}),
      startTime: json['start_time'],
      finishTime: json['finish_time'],
      totalPending: json['total_pending'] ?? 0,
      cycleTime: json['cycle_time'] ?? 0,
      totalTime: json['total_time'] ?? 0,
      runStatus: json['run_status'] ?? '',
      jobStatus: json['job_status'] ?? '',
      isDeleted: json['is_deleted'] ?? false,
      detailsRecord: detailsJson.map((d) => RecordDetail.fromJson(d)).toList(),
      ngData: json['ng_data'] ?? [],
    );
  }
}

class Employee {
  final String idEmployee;
  final String nrp;
  final String fullName;
  final String division;
  final String section;

  Employee({
    required this.idEmployee,
    required this.nrp,
    required this.fullName,
    required this.division,
    required this.section,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      idEmployee: json['id_employee'] ?? '',
      nrp: json['nrp'] ?? '',
      fullName: json['full_name'] ?? '',
      division: json['division'] ?? '',
      section: json['section'] ?? '',
    );
  }
}

class Machine {
  final String idMc;
  final String nmMc;
  final String areaMc;

  Machine({
    required this.idMc,
    required this.nmMc,
    required this.areaMc,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      idMc: json['id_mc'] ?? '',
      nmMc: json['nm_mc'] ?? '',
      areaMc: json['area_mc'] ?? '',
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

class RecordDetail {
  final int id;
  final Product bcode;
  final String jobNumber;
  final String lotNumber;
  final int startQty;
  final int finishQty;
  final int qtyNg;
  final String mixLotNo;
  final String moldNumber;
  final int moldCavity;

  RecordDetail({
    required this.id,
    required this.bcode,
    required this.jobNumber,
    required this.lotNumber,
    required this.startQty,
    required this.finishQty,
    required this.qtyNg,
    required this.mixLotNo,
    required this.moldNumber,
    required this.moldCavity,
  });

  factory RecordDetail.fromJson(Map<String, dynamic> json) {
    return RecordDetail(
      id: json['id'] ?? 0,
      bcode: Product.fromJson(json['bcode'] ?? {}),
      jobNumber: json['jobnumber'] ?? '',
      lotNumber: json['lotnumber'] ?? '',
      startQty: json['start_qty'] ?? 0,
      finishQty: json['finish_qty'] ?? 0,
      qtyNg: json['qty_ng'] ?? 0,
      mixLotNo: json['mix_lot_no'] ?? '',
      moldNumber: json['moldnumber'] ?? '',
      moldCavity: json['moldcavity'] ?? 0,
    );
  }
}

class Product {
  final String kode;
  final String drawingNumber;
  final String productType;
  final String nameCompany;

  Product({
    required this.kode,
    required this.drawingNumber,
    required this.productType,
    required this.nameCompany,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      kode: json['kode'] ?? '',
      drawingNumber: json['drawing_number'] ?? '',
      productType: json['product_type'] ?? '',
      nameCompany: json['name_company'] ?? '',
    );
  }
}
