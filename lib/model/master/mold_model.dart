import 'package:flutter/foundation.dart';

@immutable
class MoldModel {
  final String id;
  final String mouldAge;
  final String toolNumber;
  final String cavity;
  final String dateIncoming;
  final String quaranteeShoot;
  final String lastMaintenance;
  final String createdAt;
  final String status;
  final bool isDeleted;
  final String drawingNumber;
  final String deletedAt;
  final String deletedBy;

  const MoldModel({
    required this.id,
    required this.mouldAge,
    required this.toolNumber,
    required this.cavity,
    required this.dateIncoming,
    required this.quaranteeShoot,
    required this.lastMaintenance,
    required this.createdAt,
    required this.status,
    required this.isDeleted,
    required this.drawingNumber,
    required this.deletedAt,
    required this.deletedBy,
  });

  /// Factory dari API JSON
  factory MoldModel.fromJson(Map<String, dynamic> json) {
    return MoldModel(
      id: json['id']?.toString() ?? '',
      mouldAge: json['mould_age']?.toString() ?? '',
      toolNumber: json['tool_number']?.toString() ?? '',
      cavity: json['cavity']?.toString() ?? '',
      dateIncoming: json['date_incoming']?.toString() ?? '',
      quaranteeShoot: json['quarantee_shoot']?.toString() ?? '',
      lastMaintenance: json['last_maintenance']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isDeleted: json['is_deleted'] ?? false,
      drawingNumber: json['drawing_number']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
    );
  }

  /// Serialize ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mould_age': mouldAge,
      'tool_number': toolNumber,
      'cavity': cavity,
      'date_incoming': dateIncoming,
      'quarantee_shoot': quaranteeShoot,
      'last_maintenance': lastMaintenance,
      'created_at': createdAt,
      'status': status,
      'is_deleted': isDeleted,
      'drawing_number': drawingNumber,
      'deleted_at': deletedAt,
      'deleted_by': deletedBy,
    };
  }

  /// Representasi mold kosong (safe default)
  static const empty = MoldModel(
    id: '',
    mouldAge: '',
    toolNumber: '',
    cavity: '',
    dateIncoming: '',
    quaranteeShoot: '',
    lastMaintenance: '',
    createdAt: '',
    status: '',
    isDeleted: false,
    drawingNumber: '',
    deletedAt: '',
    deletedBy: '',
  );

  /// ================== DOMAIN LOGIC ==================

  /// Apakah mold valid (sudah ter-load)
  bool get isValid => id.isNotEmpty;

  /// Apakah mold aktif (business rule)
  bool get isActive => status == '01' && !isDeleted;

  /// Cavity sebagai integer (aman untuk kalkulasi)
  // int get cavityValue => int.tryParse(cavity) ?? 0;
  int? get cavityValue => cavity.trim().isEmpty ? null : int.tryParse(cavity);

  /// Tool number sebagai integer
  int get toolNumberValue => int.tryParse(toolNumber) ?? 0;

  /// ================== UTILITY ==================

  /// Copy with (immutable update)
  MoldModel copyWith({
    String? id,
    String? mouldAge,
    String? toolNumber,
    String? cavity,
    String? dateIncoming,
    String? quaranteeShoot,
    String? lastMaintenance,
    String? createdAt,
    String? status,
    bool? isDeleted,
    String? drawingNumber,
    String? deletedAt,
    String? deletedBy,
  }) {
    return MoldModel(
      id: id ?? this.id,
      mouldAge: mouldAge ?? this.mouldAge,
      toolNumber: toolNumber ?? this.toolNumber,
      cavity: cavity ?? this.cavity,
      dateIncoming: dateIncoming ?? this.dateIncoming,
      quaranteeShoot: quaranteeShoot ?? this.quaranteeShoot,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      drawingNumber: drawingNumber ?? this.drawingNumber,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  @override
  String toString() {
    return 'MoldModel(id: $id, toolNumber: $toolNumber, cavity: $cavity)';
  }
}
