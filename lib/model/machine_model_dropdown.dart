import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class MachineModelDropdown extends Equatable {
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

  const MachineModelDropdown({
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

  /// Factory dengan pengamanan null-safety (mencegah error 'Null is not subtype of String')
  factory MachineModelDropdown.fromJson(Map<String, dynamic> json) {
    return MachineModelDropdown(
      idMc: json['id_mc']?.toString() ?? '',
      nmMc: json['nm_mc']?.toString() ?? '',
      nmRegMc: json['nm_reg_mc']?.toString() ?? '',
      itemMc: json['item_mc']?.toString() ?? '',
      categoryMc: json['category_mc']?.toString() ?? '',
      sapIdMc: json['sap_id_mc']?.toString() ?? '',
      serialNumberMc: json['serial_number_mc']?.toString() ?? '',
      assetNoMc: json['asset_no_mc']?.toString() ?? '',
      areaMc: json['area_mc']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdByName: json['created_by_name']?.toString() ?? '-',
    );
  }

  /// Default object untuk inisialisasi awal
  static const empty = MachineModelDropdown(
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

  MachineModelDropdown copyWith({
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
    return MachineModelDropdown(
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
