import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/model/ng_operator_model.dart';
import 'package:flutter_provider_data/utils/safe_map_extension.dart';

@immutable
class RecordPendingDetailModel extends Equatable {
  final int idPending;
  final String idRecord;
  final String idEmployee;
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
  final String reason;
  final int qty;
  final String startPending;
  final String startTime;
  final String statusPending;
  final String employeeName;
  final String nrp;
  final String division;
  final String section;
  final int shootQty;
  final int shootTotal;
  final int sisaShoot;
  final List<NgOperatorModel> ngList;

  const RecordPendingDetailModel({
    required this.idPending,
    required this.idRecord,
    required this.idEmployee,
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
    required this.shootTotal,
    required this.sisaShoot,
    required this.ngList,
  });

  // ── Static Empty ──────────────────────────────────────────
  static const empty = RecordPendingDetailModel(
    idPending: 0,
    idRecord: '',
    idEmployee: '',
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
    reason: '',
    qty: 0,
    startPending: '',
    startTime: '',
    statusPending: '',
    employeeName: '',
    nrp: '',
    division: '',
    section: '',
    shootQty: 0,
    shootTotal: 0,
    sisaShoot: 0,
    ngList: [],
  );

  bool get isEmpty => this == RecordPendingDetailModel.empty;
  bool get isNotEmpty => this != RecordPendingDetailModel.empty;

  // ── fromJson (Safe Parsing) ───────────────────────────────
  factory RecordPendingDetailModel.fromJson(Map<String, dynamic> json) {
    return RecordPendingDetailModel(
      idPending: json.safeInt('id_pending'),
      idRecord: json.safeString('id_record'),
      idEmployee: json.safeString('id_employee'),
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
      reason: json.safeString('reason'),
      qty: json.safeInt('qty'),
      startPending: json.safeString('start_pending'),
      startTime: json.safeString('start_time'),
      statusPending: json.safeString('status_pending'),
      employeeName: json.safeString('employee_name'),
      nrp: json.safeString('nrp'),
      division: json.safeString('division'),
      section: json.safeString('section'),
      shootQty: json.safeInt('shoot_qty'),
      shootTotal: json.safeInt('shoot_total'),
      sisaShoot: json.safeInt('sisa_shoot'),
      ngList: json.safeList('ng_list',
          (e) => NgOperatorModel.fromJson(e as Map<String, dynamic>)),
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
      'status_pending': statusPending,
      'employee_name': employeeName,
      'nrp': nrp,
      'division': division,
      'section': section,
      'shoot_qty': shootQty,
      'shoot_total': shootTotal,
      'sisa_shoot': sisaShoot,
      'ng_list': ngList.map((e) => e.toJson()).toList(),
    };
  }

  // ── copyWith ──────────────────────────────────────────────
  RecordPendingDetailModel copyWith({
    int? idPending,
    String? idRecord,
    String? idEmployee,
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
    String? statusPending,
    String? employeeName,
    String? nrp,
    String? division,
    String? section,
    int? shootQty,
    int? shootTotal,
    int? sisaShoot,
    List<NgOperatorModel>? ngList,
  }) {
    return RecordPendingDetailModel(
      idPending: idPending ?? this.idPending,
      idRecord: idRecord ?? this.idRecord,
      idEmployee: idEmployee ?? this.idEmployee,
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
      statusPending: statusPending ?? this.statusPending,
      employeeName: employeeName ?? this.employeeName,
      nrp: nrp ?? this.nrp,
      division: division ?? this.division,
      section: section ?? this.section,
      shootQty: shootQty ?? this.shootQty,
      shootTotal: shootTotal ?? this.shootTotal,
      sisaShoot: sisaShoot ?? this.sisaShoot,
      ngList: ngList ?? this.ngList,
    );
  }

  // ── Equatable ─────────────────────────────────────────────
  @override
  List<Object?> get props => [
        idPending,
        idRecord,
        idEmployee,
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
        statusPending,
        employeeName,
        nrp,
        division,
        section,
        shootQty,
        shootTotal,
        sisaShoot,
        ngList,
      ];
}
