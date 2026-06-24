import 'package:flutter_provider_data/model/testing_completed_model.dart';

class PaginatedTestingCompleted {
  final int count;
  final String? next;
  final String? previous;
  final List<TestingCompletedModel> results;

  PaginatedTestingCompleted({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedTestingCompleted.fromJson(Map<String, dynamic> json) {
    return PaginatedTestingCompleted(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((e) => TestingCompletedModel.fromJson(e))
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
