import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/model/record_testing_detail_model.dart';
import 'package:flutter_provider_data/model/record_testing_header_model.dart';

@immutable
class RecordTestingDetailResponse {
  final RecordTestingHeaderModel header;
  final List<RecordTestingDetailModel> details;

  const RecordTestingDetailResponse({
    required this.header,
    required this.details,
  });

  factory RecordTestingDetailResponse.fromJson(Map<String, dynamic> json) {
    return RecordTestingDetailResponse(
      header: RecordTestingHeaderModel.fromJson(json['header'] ?? {}),
      details: (json['details'] as List<dynamic>? ?? [])
          .map((e) => RecordTestingDetailModel.fromJson(e))
          .toList(),
    );
  }

  bool get hasDetails => details.isNotEmpty;
}
