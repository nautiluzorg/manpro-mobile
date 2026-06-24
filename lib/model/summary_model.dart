import 'package:flutter/foundation.dart';

@immutable
class SummaryModel {
  final int totalTestQty;

  const SummaryModel({
    required this.totalTestQty,
  });

  /// Factory dari API JSON
  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      totalTestQty: json['total_test_qty'] is int
          ? json['total_test_qty']
          : int.tryParse(json['total_test_qty']?.toString() ?? '0') ?? 0,
    );
  }

  /// Serialize ke JSON
  Map<String, dynamic> toJson() {
    return {
      'total_test_qty': totalTestQty,
    };
  }

  /// Representasi summary kosong (safe default)
  static const empty = SummaryModel(totalTestQty: 0);

  /// ================== DOMAIN LOGIC ==================

  /// Apakah summary valid (totalTestQty > 0)
  bool get isValid => totalTestQty > 0;

  /// ================== UTILITY ==================

  /// Copy with (untuk immutable update)
  SummaryModel copyWith({
    int? totalTestQty,
  }) {
    return SummaryModel(
      totalTestQty: totalTestQty ?? this.totalTestQty,
    );
  }

  @override
  String toString() {
    return 'SummaryModel(totalTestQty: $totalTestQty)';
  }
}


/*
class SummaryModel {
  final int totalTestQty;

  SummaryModel({required this.totalTestQty});

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      totalTestQty: json['total_test_qty'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "total_test_qty": totalTestQty,
      };
}
*/