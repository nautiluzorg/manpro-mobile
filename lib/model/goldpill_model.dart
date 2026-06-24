import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class GoldPillModel extends Equatable {
  final int id;
  final String pillType;
  final String germanSilverLotNumber;
  final String uedaUshinLotNumber;
  final String materialLotNumber;
  final String quantity;
  final String punchingDate;
  final String createdByName;

  const GoldPillModel({
    required this.id,
    required this.pillType,
    required this.germanSilverLotNumber,
    required this.uedaUshinLotNumber,
    required this.materialLotNumber,
    required this.quantity,
    required this.punchingDate,
    required this.createdByName,
  });

  /// ================== FACTORY ==================

  /// Factory dari API JSON (Safe Parsing)
  factory GoldPillModel.fromJson(Map<String, dynamic> json) {
    return GoldPillModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      pillType: json['pill_type']?.toString() ?? '',
      germanSilverLotNumber: json['german_silver_lot_number']?.toString() ?? '',
      uedaUshinLotNumber: json['ueda_ushin_lot_number']?.toString() ?? '',
      materialLotNumber: json['material_lot_number']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      punchingDate: json['punching_date']?.toString() ?? '',
      createdByName: json['created_by_name']?.toString() ?? '-',
    );
  }

  /// ================== SERIALIZATION ==================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pill_type': pillType,
      'german_silver_lot_number': germanSilverLotNumber,
      'ueda_ushin_lot_number': uedaUshinLotNumber,
      'material_lot_number': materialLotNumber,
      'quantity': quantity,
      'punching_date': punchingDate,
      'created_by_name': createdByName,
    };
  }

  /// ================== EMPTY STATE ==================

  static const empty = GoldPillModel(
    id: 0,
    pillType: '',
    germanSilverLotNumber: '',
    uedaUshinLotNumber: '',
    materialLotNumber: '',
    quantity: '',
    punchingDate: '',
    createdByName: '',
  );

  /// ================== DOMAIN LOGIC ==================

  /// Apakah GoldPill valid (sudah di-scan / loaded)
  bool get isValid => id != 0;

  /// Apakah semua lot number tersedia
  bool get isComplete =>
      germanSilverLotNumber.isNotEmpty &&
      uedaUshinLotNumber.isNotEmpty &&
      materialLotNumber.isNotEmpty;

  /// ================== UTILITY ==================

  /// Immutable update (copyWith)
  GoldPillModel copyWith({
    int? id,
    String? pillType,
    String? germanSilverLotNumber,
    String? uedaUshinLotNumber,
    String? materialLotNumber,
    String? quantity,
    String? punchingDate,
    String? createdByName,
  }) {
    return GoldPillModel(
      id: id ?? this.id,
      pillType: pillType ?? this.pillType,
      germanSilverLotNumber:
          germanSilverLotNumber ?? this.germanSilverLotNumber,
      uedaUshinLotNumber: uedaUshinLotNumber ?? this.uedaUshinLotNumber,
      materialLotNumber: materialLotNumber ?? this.materialLotNumber,
      quantity: quantity ?? this.quantity,
      punchingDate: punchingDate ?? this.punchingDate,
      createdByName: createdByName ?? this.createdByName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pillType,
        germanSilverLotNumber,
        uedaUshinLotNumber,
        materialLotNumber,
        quantity,
        punchingDate,
        createdByName,
      ];

  @override
  String toString() {
    return 'GoldPillModel(id: $id, type: $pillType, qty: $quantity)';
  }
}
