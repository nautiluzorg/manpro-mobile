import 'dart:convert';

class RecordStopManageModel {
  final int idPending;
  final String idRecord;
  final String idEmployee;
  final String idEmployeeFinish;
  final String idProses;
  final String nameProses;
  final String bcode;
  final String drawingNumber;
  final String productCategory;
  final String productType;
  final String jobnumber;
  final String machineName;
  final String idReason;
  final String reason;
  final int qty;
  final DateTime startPending;
  final DateTime startTime;
  final String statusPending;
  final String employeeName;
  final String nrp;
  final String division;
  final String section;
  final int shootQty;

  RecordStopManageModel({
    required this.idPending,
    required this.idRecord,
    required this.idEmployee,
    required this.idEmployeeFinish,
    required this.idProses,
    required this.nameProses,
    required this.bcode,
    required this.drawingNumber,
    required this.productCategory,
    required this.productType,
    required this.jobnumber,
    required this.machineName,
    required this.idReason,
    required this.reason,
    required this.qty,
    required this.startPending,
    required this.startTime,
    required this.statusPending,
    required this.employeeName,
    required this.nrp,
    required this.division,
    required this.section,
    required this.shootQty,
  });

  factory RecordStopManageModel.fromJson(Map<String, dynamic> json) {
    return RecordStopManageModel(
      idPending: json['id_pending'],
      idRecord: json['id_record'],
      idEmployee: json['id_employee'],
      idEmployeeFinish: json['id_employee_finish'],
      idProses: json['id_proses'],
      nameProses: json['name_proses'],
      bcode: json['bcode'],
      drawingNumber: json['drawing_number'],
      productCategory: json['product_category'],
      productType: json['product_type'],
      jobnumber: json['jobnumber'],
      machineName: json['machine_name'],
      idReason: json['id_reason'],
      reason: json['reason'],
      qty: json['qty'],
      startPending: DateTime.parse(json['start_pending']),
      startTime: DateTime.parse(json['start_time']),
      statusPending: json['status_pending'],
      employeeName: json['employee_name'],
      nrp: json['nrp'],
      division: json['division'],
      section: json['section'],
      shootQty: json['shoot_qty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pending': idPending,
      'id_record': idRecord,
      'id_employee': idEmployee,
      'id_employee_finish': idEmployeeFinish,
      'id_proses': idProses,
      'name_proses': nameProses,
      'bcode': bcode,
      'drawing_number': drawingNumber,
      'product_category': productCategory,
      'product_type': productType,
      'jobnumber': jobnumber,
      'machine_name': machineName,
      'id_reason': idReason,
      'reason': reason,
      'qty': qty,
      'start_pending': startPending.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'status_pending': statusPending,
      'employee_name': employeeName,
      'nrp': nrp,
      'division': division,
      'section': section,
      'shoot_qty': shootQty,
    };
  }

  static List<RecordStopManageModel> listFromJson(String jsonStr) {
    final data = json.decode(jsonStr) as List<dynamic>;
    return data.map((e) => RecordStopManageModel.fromJson(e)).toList();
  }
}
