class RecordOnProgressModel {
  final String idRecord;
  final String operatorName;
  final String idEmployeeFinish;
  final String jobNumber;
  final String jobCode;
  final String lotNumber;
  final String machineId;
  final String machineName;
  final String idProses;
  final DateTime startTime;
  final String batchNumber;
  final String runStatus;
  final String jobStatus;
  final int startQty;
  final String drawingNumber;
  final String productCategory;
  final String productType;

  RecordOnProgressModel({
    required this.idRecord,
    required this.operatorName,
    required this.idEmployeeFinish,
    required this.jobNumber,
    required this.jobCode,
    required this.lotNumber,
    required this.machineId,
    required this.machineName,
    required this.idProses,
    required this.startTime,
    required this.batchNumber,
    required this.runStatus,
    required this.jobStatus,
    required this.startQty,
    required this.drawingNumber,
    required this.productCategory,
    required this.productType,
  });

  // Factory constructor untuk parsing dari JSON
  factory RecordOnProgressModel.fromJson(Map<String, dynamic> json) {
    return RecordOnProgressModel(
      idRecord: json['id_record'] as String,
      operatorName: json['operator_name'] as String,
      idEmployeeFinish: json['id_employee_finish'] as String,
      jobNumber: json['job_number'] as String,
      jobCode: json['job_code'] as String,
      lotNumber: json['lot_number'] as String,
      machineId: json['machine_id'] as String,
      machineName: json['machine_name'] as String,
      idProses: json['id_proses'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      batchNumber: json['batch_number'] as String,
      runStatus: json['run_status'] as String,
      jobStatus: json['job_status'] as String,
      startQty: json['start_qty'] as int,
      drawingNumber: json['drawing_number'] as String,
      productCategory: json['product_category'] as String,
      productType: json['product_type'] as String,
    );
  }

  // Method untuk convert ke JSON (optional)
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
      'id_proses': idProses,
      'start_time': startTime.toIso8601String(),
      'batch_number': batchNumber,
      'run_status': runStatus,
      'job_status': jobStatus,
      'start_qty': startQty,
      'drawing_number': drawingNumber,
      'product_category': productCategory,
      'product_type': productType,
    };
  }
}
