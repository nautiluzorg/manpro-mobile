import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/model/carbonpill_model.dart';
import 'package:flutter_provider_data/model/goldpill_model.dart';
import 'package:flutter_provider_data/model/master/product_model.dart';

@immutable
class RecordDetModel {
  final int id;
  final ProductModel product;
  final GoldPillModel goldPillDetail;
  final CarbonPillModel carbonPillDetail;
  final String jobnumber;
  final String lotnumber;
  final String moldnumber;
  final int moldcavity;
  final int shootQty;
  final int startQty;
  final int finishQty;
  final String mixLotNo;
  final String idRecord;

  const RecordDetModel({
    required this.id,
    required this.product,
    required this.goldPillDetail,
    required this.carbonPillDetail,
    required this.jobnumber,
    required this.lotnumber,
    required this.moldnumber,
    required this.moldcavity,
    required this.shootQty,
    required this.startQty,
    required this.finishQty,
    required this.mixLotNo,
    required this.idRecord,
  });

  /// Factory dari JSON API
  factory RecordDetModel.fromJson(Map<String, dynamic> json) {
    return RecordDetModel(
      id: json['id'] ?? 0,
      product: ProductModel.fromJson(json['product'] ?? {}),
      goldPillDetail: json['gold_pill_detail'] != null
          ? GoldPillModel.fromJson(json['gold_pill_detail'])
          : GoldPillModel.empty,
      carbonPillDetail: json['carbon_pill_detail'] != null
          ? CarbonPillModel.fromJson(json['carbon_pill_detail'])
          : CarbonPillModel.empty,
      jobnumber: json['jobnumber']?.toString() ?? '',
      lotnumber: json['lotnumber']?.toString() ?? '',
      moldnumber: json['moldnumber']?.toString() ?? '',
      moldcavity: json['moldcavity'] ?? 0,
      shootQty: json['shoot_qty'] ?? 0,
      startQty: json['start_qty'] ?? 0,
      finishQty: json['finish_qty'] ?? 0,
      mixLotNo: json['mix_lot_no']?.toString() ?? '',
      idRecord: json['id_record']?.toString() ?? '',
    );
  }
}
