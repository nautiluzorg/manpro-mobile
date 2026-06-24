import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/model/master/product_model.dart';
import 'package:flutter_provider_data/utils/safe_json_extension.dart';
import 'package:flutter_provider_data/utils/logger.dart';

@immutable
class RecordDetailModel extends Equatable {
  final int id;
  final ProductModel bcode;
  final String jobNumber;
  final String lotNumber;
  final int startQty;
  final int finishQty;
  final int qtyNg;
  final String mixLotNo;
  final String moldNumber;
  final int moldCavity;
  final int shootQty;

  const RecordDetailModel({
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
    required this.shootQty,
  });

  /// Factory dengan safe parsing untuk menangani String JSON dari API
  factory RecordDetailModel.fromJson(Map<String, dynamic> json) {
    logPrint("🔍 RecordDetailModel.fromJson - id: ${json['id']}");

    // 🔧 FIX: Gunakan safeMap untuk bcode yang bisa jadi String JSON
    final bcodeMap = json.safeMap('bcode');

    return RecordDetailModel(
      id: json.safeInt('id'),
      bcode: bcodeMap.isNotEmpty
          ? ProductModel.fromJson(bcodeMap)
          : ProductModel.empty,
      jobNumber: json.safeString('jobnumber'),
      lotNumber: json.safeString('lotnumber'),
      startQty: json.safeInt('start_qty'),
      finishQty: json.safeInt('finish_qty'),
      qtyNg: json.safeInt('qty_ng'),
      mixLotNo: json.safeString('mix_lot_no'),
      moldNumber: json.safeString('moldnumber'),
      moldCavity: json.safeInt('moldcavity'),
      shootQty: json.safeInt('shoot_qty'),
    );
  }

  /// Serialize ke JSON untuk payload API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bcode': bcode.toJson(),
      'jobnumber': jobNumber,
      'lotnumber': lotNumber,
      'start_qty': startQty,
      'finish_qty': finishQty,
      'qty_ng': qtyNg,
      'mix_lot_no': mixLotNo,
      'moldnumber': moldNumber,
      'moldcavity': moldCavity,
      'shoot_qty': shootQty,
    };
  }

  /// Safe Default Object
  static const empty = RecordDetailModel(
    id: 0,
    bcode: ProductModel.empty,
    jobNumber: '',
    lotNumber: '',
    startQty: 0,
    finishQty: 0,
    qtyNg: 0,
    mixLotNo: '',
    moldNumber: '',
    moldCavity: 0,
    shootQty: 0,
  );

  /// Helper Logic: Hitung sisa qty yang bagus
  int get goodQty => finishQty - qtyNg;

  /// Update data secara immutable
  RecordDetailModel copyWith({
    int? id,
    ProductModel? bcode,
    String? jobNumber,
    String? lotNumber,
    int? startQty,
    int? finishQty,
    int? qtyNg,
    String? mixLotNo,
    String? moldNumber,
    int? moldCavity,
    int? shootQty,
  }) {
    return RecordDetailModel(
      id: id ?? this.id,
      bcode: bcode ?? this.bcode,
      jobNumber: jobNumber ?? this.jobNumber,
      lotNumber: lotNumber ?? this.lotNumber,
      startQty: startQty ?? this.startQty,
      finishQty: finishQty ?? this.finishQty,
      qtyNg: qtyNg ?? this.qtyNg,
      mixLotNo: mixLotNo ?? this.mixLotNo,
      moldNumber: moldNumber ?? this.moldNumber,
      moldCavity: moldCavity ?? this.moldCavity,
      shootQty: shootQty ?? this.shootQty,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bcode,
        jobNumber,
        lotNumber,
        startQty,
        finishQty,
        qtyNg,
        mixLotNo,
        moldNumber,
        moldCavity,
        shootQty,
      ];

  @override
  bool get stringify => true;
}
