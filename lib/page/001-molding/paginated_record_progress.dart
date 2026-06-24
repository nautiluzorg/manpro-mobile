import 'package:flutter_provider_data/model/record_on_progress_model.dart';

class PaginatedRecordProgress {
  final int count;
  final String? next;
  final String? previous;
  final List<RecordOnProgressModel> results;

  PaginatedRecordProgress({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedRecordProgress.fromJson(Map<String, dynamic> json) {
    return PaginatedRecordProgress(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((e) => RecordOnProgressModel.fromJson(e))
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
