import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class CarbonPillModel extends Equatable {
  final int id;
  final String pillType;
  final String carbonLotNumber;
  final String
      carbonDateProduction; // Menggunakan String agar konsisten dengan model lain di UI
  final String version;
  final String carbonThickness;
  final String createdByName;

  const CarbonPillModel({
    required this.id,
    required this.pillType,
    required this.carbonLotNumber,
    required this.carbonDateProduction,
    required this.version,
    required this.carbonThickness,
    required this.createdByName,
  });

  /// ================== FACTORY ==================

  /// Factory dari API JSON (Safe Parsing)
  factory CarbonPillModel.fromJson(Map<String, dynamic> json) {
    return CarbonPillModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      pillType: json['pill_type']?.toString() ?? '',
      carbonLotNumber: json['carbon_lot_number']?.toString() ?? '',
      carbonDateProduction: json['carbon_date_production']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      carbonThickness: json['carbon_thickness']?.toString() ?? '',
      createdByName: json['created_by_name']?.toString() ?? '-',
    );
  }

  /// ================== SERIALIZATION ==================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pill_type': pillType,
      'carbon_lot_number': carbonLotNumber,
      'carbon_date_production': carbonDateProduction,
      'version': version,
      'carbon_thickness': carbonThickness,
      'created_by_name': createdByName,
    };
  }

  /// ================== EMPTY STATE ==================

  static const empty = CarbonPillModel(
    id: 0,
    pillType: '',
    carbonLotNumber: '',
    carbonDateProduction: '',
    version: '',
    carbonThickness: '',
    createdByName: '',
  );

  /// ================== DOMAIN LOGIC ==================

  /// Apakah CarbonPill valid (sudah di-scan / loaded)
  bool get isValid => id != 0;

  /// Apakah lot number tersedia
  bool get hasLot => carbonLotNumber.isNotEmpty;

  /// ================== UTILITY ==================

  /// Immutable update (copyWith)
  CarbonPillModel copyWith({
    int? id,
    String? pillType,
    String? carbonLotNumber,
    String? carbonDateProduction,
    String? version,
    String? carbonThickness,
    String? createdByName,
  }) {
    return CarbonPillModel(
      id: id ?? this.id,
      pillType: pillType ?? this.pillType,
      carbonLotNumber: carbonLotNumber ?? this.carbonLotNumber,
      carbonDateProduction: carbonDateProduction ?? this.carbonDateProduction,
      version: version ?? this.version,
      carbonThickness: carbonThickness ?? this.carbonThickness,
      createdByName: createdByName ?? this.createdByName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pillType,
        carbonLotNumber,
        carbonDateProduction,
        version,
        carbonThickness,
        createdByName,
      ];

  @override
  String toString() {
    return 'CarbonPillModel(id: $id, lot: $carbonLotNumber, version: $version)';
  }
}
