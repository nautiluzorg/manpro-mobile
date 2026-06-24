class TestingCompletedModel {
  final String idRecordTest;
  final String employeeId;
  final String employeeName;
  final String machineId;
  final String machineName;
  final String prosesId;
  final String prosesName;
  final DateTime? startTime;
  final DateTime? finishTime;
  final int? totalTime;
  final int? totalJobNumber;
  final String? status;
  final String? notes;
  final String? jobNumber;
  final String? lotNumber;
  final String? moldNumber;
  final int? moldCavity;
  final String? drawNumber;
  final String productCategory;
  final String productType;

  TestingCompletedModel({
    required this.idRecordTest,
    required this.employeeId,
    required this.employeeName,
    required this.machineId,
    required this.machineName,
    required this.prosesId,
    required this.prosesName,
    required this.startTime,
    required this.finishTime,
    required this.totalTime,
    required this.totalJobNumber,
    required this.status,
    required this.notes,
    required this.jobNumber,
    required this.lotNumber,
    required this.moldNumber,
    required this.moldCavity,
    required this.drawNumber,
    required this.productCategory,
    required this.productType,
  });

  factory TestingCompletedModel.fromJson(Map<String, dynamic> json) {
    return TestingCompletedModel(
      idRecordTest: json['id_record_test'] ?? '',
      employeeId: json['employee_id'] ?? '',
      employeeName: json['employee_name'] ?? '',
      machineId: json['machine_id'] ?? '',
      machineName: json['machine_name'] ?? '',
      prosesId: json['proses_id'] ?? '',
      prosesName: json['proses_name'] ?? '',
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'])
          : null,
      finishTime: json['finish_time'] != null
          ? DateTime.tryParse(json['finish_time'])
          : null,
      totalTime: json['total_time'] != null
          ? json['total_time'] is double
              ? (json['total_time'] as double).toInt()
              : int.tryParse(json['total_time'].toString().split('.')[0])
          : null,
      totalJobNumber: json['total_jobnumber'] != null
          ? int.tryParse(json['total_jobnumber'].toString())
          : null,
      status: json['status'],
      notes: json['notes'],
      jobNumber: json['jobnumber'],
      lotNumber: json['lot_number'],
      moldNumber: json['mold_number'],
      moldCavity: json['mold_cavity'] != null
          ? int.tryParse(json['mold_cavity'].toString())
          : null,
      drawNumber: json['drawing_number'],
      productCategory: json['product_category'] ?? '',
      productType: json['product_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_record_test': idRecordTest,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'machine_id': machineId,
      'machine_name': machineName,
      'proses_id': prosesId,
      'proses_name': prosesName,
      'start_time': startTime?.toIso8601String(),
      'finish_time': finishTime?.toIso8601String(),
      'total_time': totalTime,
      'total_job_number': totalJobNumber,
      'status': status,
      'notes': notes,
      'jobnumber': jobNumber,
      'lot_number': lotNumber,
      'mold_number': moldNumber,
      'mold_cavity': moldCavity,
      'drawing_number': drawNumber,
      'product_category': productCategory,
      'product_type': productType,
    };
  }
}
