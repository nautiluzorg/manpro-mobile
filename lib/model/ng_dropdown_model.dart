import 'package:flutter_provider_data/utils/safe_json_extension.dart';

class NgDropdownModel {
  final String idNg;
  final String ngName;
  final String nameProses; // ← sesuaikan dengan response API

  NgDropdownModel({
    required this.idNg,
    required this.ngName,
    required this.nameProses,
  });

  factory NgDropdownModel.fromJson(Map<String, dynamic> json) {
    return NgDropdownModel(
      idNg: json.safeString('id_ng'),
      ngName: json.safeString('ng_name'),
      nameProses: json.safeString('name_proses'),
    );
  }
}
