import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/utils/safe_json_extension.dart';
import 'package:flutter_provider_data/utils/logger.dart';

@immutable
class NgModel extends Equatable {
  final String idNg;
  final String idProses;
  final String nameProses;
  final String ngName;
  final String description;

  const NgModel({
    required this.idNg,
    required this.idProses,
    required this.nameProses,
    required this.ngName,
    required this.description,
  });

  /// Factory parsing JSON item
  factory NgModel.fromJson(Map<String, dynamic> json) {
    logPrint("🔍 NgModel.fromJson - id_ng: ${json['id_ng']}");

    return NgModel(
      idNg: json.safeString('id_ng'),
      idProses: json.safeString('id_proses'),
      nameProses: json.safeString('name_proses'),
      ngName: json.safeString('ng_name'),
      description: json.safeString('description'),
    );
  }

  /// Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_ng': idNg,
      'id_proses': idProses,
      'name_proses': nameProses,
      'ng_name': ngName,
      'description': description,
    };
  }

  /// Empty object
  static const empty = NgModel(
    idNg: '',
    idProses: '',
    nameProses: '',
    ngName: '',
    description: '',
  );

  bool get isValid => idNg.isNotEmpty;

  /// CopyWith
  NgModel copyWith({
    String? idNg,
    String? idProses,
    String? nameProses,
    String? ngName,
    String? description,
  }) {
    return NgModel(
      idNg: idNg ?? this.idNg,
      idProses: idProses ?? this.idProses,
      nameProses: nameProses ?? this.nameProses,
      ngName: ngName ?? this.ngName,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        idNg,
        idProses,
        nameProses,
        ngName,
        description,
      ];
}

/// =======================================================
/// RESPONSE MODEL
/// =======================================================

@immutable
class NgListResponseModel extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<NgModel> results;

  const NgListResponseModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory NgListResponseModel.fromJson(Map<String, dynamic> json) {
    logPrint(
      "🔍 NgListResponseModel.fromJson - count: ${json['count']}",
    );

    return NgListResponseModel(
      count: json['count'] ?? 0,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => NgModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }

  static const empty = NgListResponseModel(
    count: 0,
    next: null,
    previous: null,
    results: [],
  );

  bool get hasData => results.isNotEmpty;

  NgListResponseModel copyWith({
    int? count,
    String? next,
    String? previous,
    List<NgModel>? results,
  }) {
    return NgListResponseModel(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  @override
  List<Object?> get props => [
        count,
        next,
        previous,
        results,
      ];
}
