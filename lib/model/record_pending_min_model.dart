import 'package:flutter_provider_data/model/pending_reason_model.dart';

class RecordPendingMinModel {
  final int idPending;
  final PendingReasonModel reason;
  final String proses;
  final DateTime startPending;
  final DateTime? finishPending;
  final int totalPending;
  final String statusPending;

  RecordPendingMinModel({
    required this.idPending,
    required this.reason,
    required this.proses,
    required this.startPending,
    this.finishPending,
    required this.totalPending,
    required this.statusPending,
  });

  factory RecordPendingMinModel.fromJson(Map<String, dynamic> json) {
    return RecordPendingMinModel(
      idPending: json['id_pending'],
      reason: PendingReasonModel.fromJson(json['reason']),
      proses: json['proses'],
      startPending: DateTime.parse(json['start_pending']),
      finishPending: json['finish_pending'] != null
          ? DateTime.parse(json['finish_pending'])
          : null,
      totalPending: json['total_pending'],
      statusPending: json['status_pending'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pending': idPending,
      'reason': reason.toJson(),
      'proses': proses,
      'start_pending': startPending.toIso8601String(),
      'finish_pending': finishPending?.toIso8601String(),
      'total_pending': totalPending,
      'status_pending': statusPending,
    };
  }
}
