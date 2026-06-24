/// Model class for Reason data
class ReasonModel {
  final String idReason;
  final String nameReason;
  final int standarTime;
  final String? description;

  const ReasonModel({
    required this.idReason,
    required this.nameReason,
    required this.standarTime,
    this.description,
  });

  /// Create object from JSON
  factory ReasonModel.fromJson(Map<String, dynamic> json) {
    return ReasonModel(
      idReason: json['id_reason']?.toString() ?? '',
      nameReason: json['name_reason']?.toString() ?? '',
      standarTime: int.tryParse(json['standar_time'].toString()) ?? 0,
      description: json['description']?.toString(),
    );
  }

  /// Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_reason': idReason,
      'name_reason': nameReason,
      'standar_time': standarTime,
      'description': description,
    };
  }

  /// Copy with modification
  ReasonModel copyWith({
    String? idReason,
    String? nameReason,
    int? standarTime,
    String? description,
  }) {
    return ReasonModel(
      idReason: idReason ?? this.idReason,
      nameReason: nameReason ?? this.nameReason,
      standarTime: standarTime ?? this.standarTime,
      description: description ?? this.description,
    );
  }

  /// Convert List JSON to List<ReasonModel>
  static List<ReasonModel> fromJsonList(List<dynamic> list) {
    return list.map((item) => ReasonModel.fromJson(item)).toList();
  }

  /// Convert List<ReasonModel> to List JSON
  static List<Map<String, dynamic>> toJsonList(List<ReasonModel> list) {
    return list.map((item) => item.toJson()).toList();
  }

  @override
  String toString() =>
      'ReasonModel(id: $idReason, name: $nameReason, time: $standarTime)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReasonModel &&
        other.idReason == idReason &&
        other.nameReason == nameReason &&
        other.standarTime == standarTime &&
        other.description == description;
  }

  @override
  int get hashCode =>
      idReason.hashCode ^
      nameReason.hashCode ^
      standarTime.hashCode ^
      description.hashCode;
}

























/*
class ReasonModel {
  final String idReason;
  final String nameReason;
  final int standarTime;
  final String description;

  ReasonModel({
    required this.idReason,
    required this.nameReason,
    required this.standarTime,
    required this.description,
  });

  factory ReasonModel.fromJson(Map<String, dynamic> json) {
    return ReasonModel(
      idReason: json['id_reason'],
      nameReason: json['name_reason'],
      standarTime: json['standar_time'],
      description: json['description'],
    );
  }
}
*/