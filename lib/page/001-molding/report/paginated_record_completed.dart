import 'package:flutter_provider_data/model/record_completed_model.dart';

class PaginatedRecordCompleted {
  final int count;
  final String? next;
  final String? previous;
  final List<RecordCompletedModel> results;

  PaginatedRecordCompleted({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedRecordCompleted.fromJson(Map<String, dynamic> json) {
    return PaginatedRecordCompleted(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((e) => RecordCompletedModel.fromJson(e))
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
