class RecordCompletedModel {
  final String idRecord;
  final String operatorName;
  final String idEmployeeFinish;
  final String? jobNumber;
  final String jobCode;
  final String lotNumber;
  final String machineId;
  final String machineName;
  final DateTime startTime;
  final DateTime? finishTime;
  final int totalTime;
  final int cycleTime;
  final int downtime;
  final int ng;
  final int good;
  final int startQty;
  final String productCategory;
  final String productType;
  final String drawNumber;

  RecordCompletedModel({
    required this.idRecord,
    required this.operatorName,
    required this.idEmployeeFinish,
    this.jobNumber,
    required this.jobCode,
    required this.lotNumber,
    required this.machineId,
    required this.machineName,
    required this.startTime,
    this.finishTime,
    required this.totalTime,
    required this.cycleTime,
    required this.downtime,
    required this.ng,
    required this.good,
    required this.startQty,
    required this.productCategory,
    required this.productType,
    required this.drawNumber,
  });

  factory RecordCompletedModel.fromJson(Map<String, dynamic> json) {
    return RecordCompletedModel(
      idRecord: json['id_record'] as String,
      operatorName: json['operator_name'] as String,
      idEmployeeFinish: json['id_employee_finish'] as String,
      jobNumber: json['job_number'] as String?,
      jobCode: json['job_code'] as String,
      lotNumber: json['lot_number'] as String,
      machineId: json['machine_id'] as String,
      machineName: json['machine_name'] as String,
      startTime: DateTime.parse(json['start_time']),
      finishTime: json['finish_time'] != null
          ? DateTime.parse(json['finish_time'])
          : null,
      totalTime: json['total_time'] as int,
      cycleTime: json['cycle_time'] as int,
      downtime: json['downtime'] as int,
      ng: json['ng'] as int,
      good: json['good'] as int,
      startQty: json['start_qty'] as int,
      productCategory: json['product_category'] as String,
      productType: json['product_type'] as String,
      drawNumber: json['drawing_number'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_record': idRecord,
      'operator_name': operatorName,
      'id_employee_finish': idEmployeeFinish,
      'job_number': jobNumber,
      'job_code': jobCode,
      'lot_number': lotNumber,
      'machine_id': machineId,
      'machine_name': machineName,
      'start_time': startTime.toIso8601String(),
      'finish_time': finishTime?.toIso8601String(),
      'total_time': totalTime,
      'cycle_time': cycleTime,
      'downtime': downtime,
      'ng': ng,
      'good': good,
      'start_qty': startQty,
      'product_category': productCategory,
      'product_type': productType,
      'drawing_number': drawNumber,
    };
  }
}
