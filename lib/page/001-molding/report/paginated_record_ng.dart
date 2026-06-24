import 'package:flutter_provider_data/model/record_ng_model.dart';

class PaginatedRecordNg {
  final int count;
  final String? next;
  final String? previous;
  final List<RecordNgModel> results;

  PaginatedRecordNg({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedRecordNg.fromJson(Map<String, dynamic> json) {
    return PaginatedRecordNg(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((e) => RecordNgModel.fromJson(e))
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
}
