import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/utils/safe_map_extension.dart';

@immutable
class NgOperatorModel extends Equatable {
  final String idNg;
  final String ngName;
  final int qty;
  final int shootQty;
  final String? jobnumber;
  final String? idEmployee;
  final String? employeeName;

  const NgOperatorModel({
    required this.idNg,
    required this.ngName,
    required this.qty,
    required this.shootQty,
    this.jobnumber,
    this.idEmployee,
    this.employeeName,
  });

  // ── Static Empty ──────────────────────────────────────────
  static const empty = NgOperatorModel(
    idNg: '',
    ngName: '',
    qty: 0,
    shootQty: 0,
    jobnumber: null,
    idEmployee: null,
    employeeName: null,
  );

  bool get isEmpty => this == NgOperatorModel.empty;
  bool get isNotEmpty => this != NgOperatorModel.empty;

  // ── fromJson (Safe Parsing) ───────────────────────────────
  factory NgOperatorModel.fromJson(Map<String, dynamic> json) {
    return NgOperatorModel(
      idNg: json.safeString('id_ng'),
      ngName: json.safeString('ng_name'),
      qty: json.safeInt('qty'),
      shootQty: json.safeInt('shoot_qty'),
      jobnumber: json['jobnumber'] as String?,
      idEmployee: json['id_employee'] as String?,
      employeeName: json['employee_name'] as String?,
    );
  }

  // ── toJson ────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id_ng': idNg,
      'ng_name': ngName,
      'qty': qty,
      'shoot_qty': shootQty,
      'jobnumber': jobnumber,
      'id_employee': idEmployee,
      'employee_name': employeeName,
    };
  }

  // ── copyWith ──────────────────────────────────────────────
  NgOperatorModel copyWith({
    String? idNg,
    String? ngName,
    int? qty,
    int? shootQty,
    String? jobnumber,
    String? idEmployee,
    String? employeeName,
  }) {
    return NgOperatorModel(
      idNg: idNg ?? this.idNg,
      ngName: ngName ?? this.ngName,
      qty: qty ?? this.qty,
      shootQty: shootQty ?? this.shootQty,
      jobnumber: jobnumber ?? this.jobnumber,
      idEmployee: idEmployee ?? this.idEmployee,
      employeeName: employeeName ?? this.employeeName,
    );
  }

  // ── Equatable ─────────────────────────────────────────────
  @override
  List<Object?> get props => [
        idNg,
        ngName,
        qty,
        shootQty,
        jobnumber,
        idEmployee,
        employeeName,
      ];
}
