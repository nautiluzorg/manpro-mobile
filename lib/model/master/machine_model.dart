import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/utils/safe_json_extension.dart';
import 'package:flutter_provider_data/utils/logger.dart';

@immutable
class MachineModel extends Equatable {
  final String idMc;
  final String nmMc;
  final String nmRegMc;
  final String itemMc;
  final String categoryMc;
  final String sapIdMc;
  final String serialNumberMc;
  final String assetNoMc;
  final String areaMc;
  final String status;
  final String createdByName;

  const MachineModel({
    required this.idMc,
    required this.nmMc,
    required this.nmRegMc,
    required this.itemMc,
    required this.categoryMc,
    required this.sapIdMc,
    required this.serialNumberMc,
    required this.assetNoMc,
    required this.areaMc,
    required this.status,
    required this.createdByName,
  });

  /// Factory dengan safe parsing untuk menangani String JSON dari API
  factory MachineModel.fromJson(Map<String, dynamic> json) {
    logPrint("🔍 MachineModel.fromJson - id_mc: ${json['id_mc']}");

    return MachineModel(
      idMc: json.safeString('id_mc'),
      nmMc: json.safeString('nm_mc'),
      nmRegMc: json.safeString('nm_reg_mc'),
      itemMc: json.safeString('item_mc'),
      categoryMc: json.safeString('category_mc'),
      sapIdMc: json.safeString('sap_id_mc'),
      serialNumberMc: json.safeString('serial_number_mc'),
      assetNoMc: json.safeString('asset_no_mc'),
      areaMc: json.safeString('area_mc'),
      status: json.safeString('status'),
      createdByName: json.safeString('created_by_name'),
    );
  }

  /// Serialize ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id_mc': idMc,
      'nm_mc': nmMc,
      'nm_reg_mc': nmRegMc,
      'item_mc': itemMc,
      'category_mc': categoryMc,
      'sap_id_mc': sapIdMc,
      'serial_number_mc': serialNumberMc,
      'asset_no_mc': assetNoMc,
      'area_mc': areaMc,
      'status': status,
      'created_by_name': createdByName,
    };
  }

  /// Default object untuk inisialisasi awal di Provider
  static const empty = MachineModel(
    idMc: '',
    nmMc: '',
    nmRegMc: '',
    itemMc: '',
    categoryMc: '',
    sapIdMc: '',
    serialNumberMc: '',
    assetNoMc: '',
    areaMc: '',
    status: '',
    createdByName: '',
  );

  bool get isValid => idMc.isNotEmpty;

  /// Update data tanpa merusak object lama (penting untuk Provider)
  MachineModel copyWith({
    String? idMc,
    String? nmMc,
    String? nmRegMc,
    String? itemMc,
    String? categoryMc,
    String? sapIdMc,
    String? serialNumberMc,
    String? assetNoMc,
    String? areaMc,
    String? status,
    String? createdByName,
  }) {
    return MachineModel(
      idMc: idMc ?? this.idMc,
      nmMc: nmMc ?? this.nmMc,
      nmRegMc: nmRegMc ?? this.nmRegMc,
      itemMc: itemMc ?? this.itemMc,
      categoryMc: categoryMc ?? this.categoryMc,
      sapIdMc: sapIdMc ?? this.sapIdMc,
      serialNumberMc: serialNumberMc ?? this.serialNumberMc,
      assetNoMc: assetNoMc ?? this.assetNoMc,
      areaMc: areaMc ?? this.areaMc,
      status: status ?? this.status,
      createdByName: createdByName ?? this.createdByName,
    );
  }

  @override
  List<Object?> get props => [
        idMc,
        nmMc,
        nmRegMc,
        itemMc,
        categoryMc,
        sapIdMc,
        serialNumberMc,
        assetNoMc,
        areaMc,
        status,
        createdByName,
      ];
}
