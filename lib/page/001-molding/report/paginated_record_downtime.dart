import 'package:flutter_provider_data/model/record_downtime_model.dart';

class PaginatedRecordDowntime {
  final int count;
  final String? next;
  final String? previous;
  final List<RecordDowntimeModel> results;

  PaginatedRecordDowntime({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedRecordDowntime.fromJson(Map<String, dynamic> json) {
    return PaginatedRecordDowntime(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((e) => RecordDowntimeModel.fromJson(e))
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
