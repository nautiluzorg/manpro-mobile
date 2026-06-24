class MachineLayoutModel {
  final String idMc;
  final String name;
  final String type;
  final String area;
  final String runStatus;
  final String? activeRecordId;
  final String? activeRecordType; // 'process' | 'testing'

  MachineLayoutModel({
    required this.idMc,
    required this.name,
    required this.type,
    required this.area,
    required this.runStatus,
    this.activeRecordId,
    this.activeRecordType,
  });

  factory MachineLayoutModel.fromJson(Map<String, dynamic> json) {
    return MachineLayoutModel(
      idMc: json['id_mc'] as String? ?? '',
      name: json['nm_mc'] as String? ?? '',
      type: json['type_mc'] as String? ?? '',
      area: json['area_mc'] as String? ?? '',
      runStatus: json['run_status'] as String? ?? '',
      activeRecordId: json['active_record_id'] as String?,
      activeRecordType: json['active_record_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mc': idMc,
      'nm_mc': name,
      'type_mc': type,
      'area_mc': area,
      'run_status': runStatus,
      'active_record_id': activeRecordId,
      'active_record_type': activeRecordType,
    };
  }
}
