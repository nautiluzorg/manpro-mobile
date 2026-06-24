import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/utils/safe_json_extension.dart';
import 'package:flutter_provider_data/utils/logger.dart';

@immutable
class ProsesModel extends Equatable {
  final String idProses;
  final String nameProses;

  const ProsesModel({
    required this.idProses,
    required this.nameProses,
  });

  /// Factory dengan safe parsing untuk menangani String JSON dari API
  factory ProsesModel.fromJson(Map<String, dynamic> json) {
    logPrint("🔍 ProsesModel.fromJson - id_proses: ${json['id_proses']}");

    return ProsesModel(
      idProses: json.safeString('id_proses'),
      nameProses: json.safeString('name_proses'),
    );
  }

  /// Serialize ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id_proses': idProses,
      'name_proses': nameProses,
    };
  }

  /// Default object untuk inisialisasi awal (Safe Default)
  static const empty = ProsesModel(
    idProses: '',
    nameProses: '',
  );

  /// Helper untuk cek apakah data sudah terisi
  bool get isValid => idProses.isNotEmpty;

  /// Update data tanpa merusak object lama
  ProsesModel copyWith({
    String? idProses,
    String? nameProses,
  }) {
    return ProsesModel(
      idProses: idProses ?? this.idProses,
      nameProses: nameProses ?? this.nameProses,
    );
  }

  @override
  List<Object?> get props => [idProses, nameProses];

  @override
  bool get stringify => true;
}
