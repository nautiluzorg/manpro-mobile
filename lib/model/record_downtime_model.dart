class RecordDowntimeModel {
  final int idPending;
  final String idEmployee;
  final String reasonName;
  final String idReason;
  final String employeeName;
  final String machineName;
  final DateTime startPending;
  final DateTime? finishPending;
  final int totalPending;
  final String statusPending;

  RecordDowntimeModel({
    required this.idPending,
    required this.idEmployee,
    required this.reasonName,
    required this.idReason,
    required this.employeeName,
    required this.machineName,
    required this.startPending,
    this.finishPending,
    required this.totalPending,
    required this.statusPending,
  });

  factory RecordDowntimeModel.fromJson(Map<String, dynamic> json) {
    return RecordDowntimeModel(
      idPending: json['id_pending'],
      idEmployee: json['id_employee'],
      reasonName: json['reason_name'],
      idReason: json['id_reason'],
      employeeName: json['employee_name'],
      machineName: json['machine_finish_name'],
      startPending: DateTime.parse(json['start_pending']),
      finishPending: json['finish_pending'] != null
          ? DateTime.parse(json['finish_pending'])
          : null,
      totalPending: json['total_pending'],
      statusPending: json['status_pending'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pending': idPending,
      'id_employee': idEmployee,
      'reason_name': reasonName,
      'id_reason': idReason,
      'employee_name': employeeName,
      'machine_finish_name': machineName,
      'start_pending': startPending.toIso8601String(),
      'finish_pending': finishPending?.toIso8601String(),
      'total_pending': totalPending,
      'status_pending': statusPending,
    };
  }
}
