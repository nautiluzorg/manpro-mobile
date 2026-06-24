class PendingReasonModel {
  final String idReason;
  final String nameReason;
  final int standarTime;
  final String description;
  final bool isDeleted;
  final DateTime? deletedAt;
  final dynamic deletedBy;

  PendingReasonModel({
    required this.idReason,
    required this.nameReason,
    required this.standarTime,
    required this.description,
    required this.isDeleted,
    this.deletedAt,
    this.deletedBy,
  });

  factory PendingReasonModel.fromJson(Map<String, dynamic> json) {
    return PendingReasonModel(
      idReason: json['id_reason'],
      nameReason: json['name_reason'],
      standarTime: json['standar_time'],
      description: json['description'],
      isDeleted: json['is_deleted'],
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      deletedBy: json['deleted_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reason': idReason,
      'name_reason': nameReason,
      'standar_time': standarTime,
      'description': description,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }
}
