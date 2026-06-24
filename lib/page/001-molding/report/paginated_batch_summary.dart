import 'package:flutter_provider_data/model/batch_summary_model.dart';

class PaginatedBatchSummary {
  final int count;
  final String? next;
  final String? previous;
  final List<BatchSummaryModel> results;

  PaginatedBatchSummary({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedBatchSummary.fromJson(Map<String, dynamic> json) {
    return PaginatedBatchSummary(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((e) => BatchSummaryModel.fromJson(e))
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
