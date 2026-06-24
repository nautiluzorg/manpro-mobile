import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/utils/safe_json_extension.dart';
import 'package:flutter_provider_data/utils/logger.dart';

@immutable
class ReasonDropdownModel extends Equatable {
  final String idReason;
  final String nameReason;
  final int standarTime;
  final String description;

  const ReasonDropdownModel({
    required this.idReason,
    required this.nameReason,
    required this.standarTime,
    required this.description,
  });

  /// Factory constructor dengan safe parsing untuk menangani String JSON dari API
  factory ReasonDropdownModel.fromJson(Map<String, dynamic> json) {
    logPrint(
        "🔍 ReasonDropdownModel.fromJson - id_reason: ${json['id_reason']}");

    return ReasonDropdownModel(
      idReason: json.safeString('id_reason'),
      nameReason: json.safeString('name_reason'),
      standarTime: json.safeInt('standar_time'),
      description: json.safeString('description'),
    );
  }

  /// Convert object ke JSON (untuk pengiriman payload)
  Map<String, dynamic> toJson() {
    return {
      'id_reason': idReason,
      'name_reason': nameReason,
      'standar_time': standarTime,
      'description': description,
    };
  }

  /// Objek Kosong (Safe Default)
  static const empty = ReasonDropdownModel(
    idReason: '',
    nameReason: '-- Pilih Alasan --',
    standarTime: 0,
    description: '',
  );

  @override
  List<Object?> get props => [
        idReason,
        nameReason,
        standarTime,
        description,
      ];

  @override
  bool get stringify => true;
}
