import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/utils/safe_map_extension.dart';

@immutable
class RecordPendingModel extends Equatable {
  final int idPending;
  final String idEmployee;
  final String idRecord;
  final String idProses;
  final String nameProses;
  final String bcode;
  final String customer;
  final String drawingNumber;
  final String productCategory;
  final String productType;
  final String? jobnumber;
  final String machineName;
  final String idReason;
  final String? reason;
  final int qty;
  final String startPending;
  final String startTime;
  final String status;
  final String employeeName;
  final String nrp;
  final String division;
  final String section;
  final int shootQty;

  const RecordPendingModel({
    required this.idPending,
    required this.idEmployee,
    required this.idRecord,
    required this.idProses,
    required this.nameProses,
    required this.bcode,
    required this.customer,
    required this.drawingNumber,
    required this.productCategory,
    required this.productType,
    this.jobnumber,
    required this.machineName,
    required this.idReason,
    this.reason,
    required this.qty,
    required this.startPending,
    required this.startTime,
    required this.status,
    required this.employeeName,
    required this.nrp,
    required this.division,
    required this.section,
    required this.shootQty,
  });

  // ── Static Empty ──────────────────────────────────────────
  static const empty = RecordPendingModel(
    idPending: 0,
    idEmployee: '',
    idRecord: '',
    idProses: '',
    nameProses: '',
    bcode: '',
    customer: '',
    drawingNumber: '',
    productCategory: '',
    productType: '',
    jobnumber: null,
    machineName: '',
    idReason: '',
    reason: null,
    qty: 0,
    startPending: '',
    startTime: '',
    status: '',
    employeeName: '',
    nrp: '',
    division: '',
    section: '',
    shootQty: 0,
  );

  bool get isEmpty => this == RecordPendingModel.empty;
  bool get isNotEmpty => this != RecordPendingModel.empty;

  // ── fromJson (Safe Parsing) ───────────────────────────────
  factory RecordPendingModel.fromJson(Map<String, dynamic> json) {
    return RecordPendingModel(
      idPending: json.safeInt('id_pending'),
      idEmployee: json.safeString('id_employee'),
      idRecord: json.safeString('id_record'),
      idProses: json.safeString('id_proses'),
      nameProses: json.safeString('name_proses'),
      bcode: json.safeString('bcode'),
      customer: json.safeString('customer'),
      drawingNumber: json.safeString('drawing_number'),
      productCategory: json.safeString('product_category'),
      productType: json.safeString('product_type'),
      jobnumber: json['jobnumber'] as String?,
      machineName: json.safeString('machine_name'),
      idReason: json.safeString('id_reason'),
      reason: json['reason'] as String?,
      qty: json.safeInt('qty'),
      startPending: json.safeString('start_pending'),
      startTime: json.safeString('start_time'),
      status: json.safeString('status_pending'),
      employeeName: json.safeString('employee_name'),
      nrp: json.safeString('nrp'),
      division: json.safeString('division'),
      section: json.safeString('section'),
      shootQty: json.safeInt('shoot_qty'),
    );
  }

  // ── toJson ────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id_pending': idPending,
      'id_record': idRecord,
      'id_employee': idEmployee,
      'id_proses': idProses,
      'name_proses': nameProses,
      'bcode': bcode,
      'customer': customer,
      'drawing_number': drawingNumber,
      'product_category': productCategory,
      'product_type': productType,
      'jobnumber': jobnumber,
      'machine_name': machineName,
      'id_reason': idReason,
      'reason': reason,
      'qty': qty,
      'start_pending': startPending,
      'start_time': startTime,
      'status_pending': status,
      'employee_name': employeeName,
      'nrp': nrp,
      'division': division,
      'section': section,
      'shoot_qty': shootQty,
    };
  }

  // ── copyWith ──────────────────────────────────────────────
  RecordPendingModel copyWith({
    int? idPending,
    String? idEmployee,
    String? idRecord,
    String? idProses,
    String? nameProses,
    String? bcode,
    String? customer,
    String? drawingNumber,
    String? productCategory,
    String? productType,
    String? jobnumber,
    String? machineName,
    String? idReason,
    String? reason,
    int? qty,
    String? startPending,
    String? startTime,
    String? status,
    String? employeeName,
    String? nrp,
    String? division,
    String? section,
    int? shootQty,
  }) {
    return RecordPendingModel(
      idPending: idPending ?? this.idPending,
      idEmployee: idEmployee ?? this.idEmployee,
      idRecord: idRecord ?? this.idRecord,
      idProses: idProses ?? this.idProses,
      nameProses: nameProses ?? this.nameProses,
      bcode: bcode ?? this.bcode,
      customer: customer ?? this.customer,
      drawingNumber: drawingNumber ?? this.drawingNumber,
      productCategory: productCategory ?? this.productCategory,
      productType: productType ?? this.productType,
      jobnumber: jobnumber ?? this.jobnumber,
      machineName: machineName ?? this.machineName,
      idReason: idReason ?? this.idReason,
      reason: reason ?? this.reason,
      qty: qty ?? this.qty,
      startPending: startPending ?? this.startPending,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
      employeeName: employeeName ?? this.employeeName,
      nrp: nrp ?? this.nrp,
      division: division ?? this.division,
      section: section ?? this.section,
      shootQty: shootQty ?? this.shootQty,
    );
  }

  // ── Equatable ─────────────────────────────────────────────
  @override
  List<Object?> get props => [
        idPending,
        idEmployee,
        idRecord,
        idProses,
        nameProses,
        bcode,
        customer,
        drawingNumber,
        productCategory,
        productType,
        jobnumber,
        machineName,
        idReason,
        reason,
        qty,
        startPending,
        startTime,
        status,
        employeeName,
        nrp,
        division,
        section,
        shootQty,
      ];
}































/*
class RecordPendingModel {
  final int idPending;
  final String idEmployee;
  final String idEmployeeFinish;
  final String idRecord;
  final String idProses;
  final String nameProses;
  final String bcode;
  final String customer;
  final String drawingNumber;
  final String productCategory;
  final String productType;
  final String? jobnumber; // nullable, karena bisa null
  final String machineName;
  final String idReason;
  final String? reason; // nullable, karena bisa null
  final int qty;
  final String startPending;
  final String startTime;
  final String status;
  final String employeeName;
  final String nrp;
  final String division;
  final String section;

  RecordPendingModel({
    required this.idPending,
    required this.idEmployee,
    required this.idEmployeeFinish,
    required this.idRecord,
    required this.idProses,
    required this.nameProses,
    required this.bcode,
    required this.customer,
    required this.drawingNumber,
    required this.productCategory,
    required this.productType,
    this.jobnumber,
    required this.machineName,
    required this.idReason,
    this.reason,
    required this.qty,
    required this.startPending,
    required this.startTime,
    required this.status,
    required this.employeeName,
    required this.nrp,
    required this.division,
    required this.section,
  });

  factory RecordPendingModel.fromJson(Map<String, dynamic> json) {
    return RecordPendingModel(
      idPending: json['id_pending'] ?? 0,
      idEmployee: json['id_employee'] ?? '',
      idEmployeeFinish: json['id_employee_finish'] ?? '',
      idRecord: json['id_record'] ?? '',
      idProses: json['id_proses'] ?? '',
      nameProses: json['name_proses'] ?? '',
      bcode: json['bcode'] ?? '',
      customer: json['customer'] ?? '',
      drawingNumber: json['drawing_number'] ?? '',
      productCategory: json['product_category'] ?? '',
      productType: json['product_type'] ?? '',
      jobnumber: json['jobnumber'], // nullable
      machineName: json['machine_name'] ?? '',
      idReason: json['id_reason'] ?? '',
      reason: json['reason'], // nullable
      qty: json['qty'] ?? 0,
      startPending: json['start_pending'] ?? '',
      startTime: json['start_time'] ?? '',
      status: json['status_pending'] ?? '',
      employeeName: json['employee_name'] ?? '',
      nrp: json['nrp'] ?? '',
      division: json['division'] ?? '',
      section: json['section'] ?? '',
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
      'customer': customer,
      'drawing_number': drawingNumber,
      'product_category': productCategory,
      'product_type': productType,
      'jobnumber': jobnumber,
      'machine_name': machineName,
      'id_reason': idReason,
      'reason': reason,
      'qty': qty,
      'start_pending': startPending,
      'start_time': startTime,
      'status_pending': status,
      'employee_name': employeeName,
      'nrp': nrp,
      'division': division,
      'section': section,
    };
  }
}

*/