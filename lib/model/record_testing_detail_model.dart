import 'package:flutter/foundation.dart';

@immutable
class RecordTestingDetailModel {
  final String bcode;
  final String drawingNumber;
  final String productCategory;
  final String productType;
  final String companyName;

  final String? jobnumber;
  final String? lotnumber;
  final String? moldnumber;
  final int? moldcavity;

  final int? qty;
  final int? totalShootQty;
  final int testQty;
  final int finishQty;

  final String? mixLotNo;
  final String? goldPill;
  final String? carbonPill;

  final String? mcTempUpper;
  final String? mcTempLower;
  final String? mcCuring;
  final String? mcPressure;
  final String? mcSettings;

  final bool checklistMoldSetup;
  final bool checklistVacumjigSetup;

  const RecordTestingDetailModel({
    required this.bcode,
    required this.drawingNumber,
    required this.productCategory,
    required this.productType,
    required this.companyName,
    this.jobnumber,
    this.lotnumber,
    this.moldnumber,
    this.moldcavity,
    this.qty,
    this.totalShootQty,
    required this.testQty,
    required this.finishQty,
    this.mixLotNo,
    this.goldPill,
    this.carbonPill,
    this.mcTempUpper,
    this.mcTempLower,
    this.mcCuring,
    this.mcPressure,
    this.mcSettings,
    required this.checklistMoldSetup,
    required this.checklistVacumjigSetup,
  });

  factory RecordTestingDetailModel.fromJson(Map<String, dynamic> json) {
    return RecordTestingDetailModel(
      bcode: json['bcode']?.toString() ?? '',
      drawingNumber: json['drawing_number']?.toString() ?? '',
      productCategory: json['product_category']?.toString() ?? '',
      productType: json['product_type']?.toString() ?? '',
      companyName: json['name_company']?.toString() ?? '',
      jobnumber: json['jobnumber']?.toString(),
      lotnumber: json['lotnumber']?.toString(),
      moldnumber: json['moldnumber']?.toString(),
      moldcavity: json['moldcavity'],
      qty: json['qty'],
      totalShootQty: json['total_shoot_qty'],
      testQty: json['test_qty'] ?? 0,
      finishQty: json['finish_qty'] ?? 0,
      mixLotNo: json['mix_lot_no']?.toString(),
      goldPill: json['gold_pill']?.toString(),
      carbonPill: json['carbon_pill']?.toString(),
      mcTempUpper: json['mc_temp_upper']?.toString(),
      mcTempLower: json['mc_temp_lower']?.toString(),
      mcCuring: json['mc_curing']?.toString(),
      mcPressure: json['mc_pressure']?.toString(),
      mcSettings: json['mc_settings']?.toString(),
      checklistMoldSetup: json['checklist_mold_setup'] ?? false,
      checklistVacumjigSetup: json['checklist_vacumjig_setup'] ?? false,
    );
  }
}
