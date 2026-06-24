class DowntimeSummaryModel {
  final String idReason;
  final String reasonName;
  final int totalPending;
  final int totalCase;

  DowntimeSummaryModel(
      {required this.idReason,
      required this.reasonName,
      required this.totalPending,
      required this.totalCase});

  factory DowntimeSummaryModel.fromJson(Map<String, dynamic> json) {
    return DowntimeSummaryModel(
      idReason: json['id_reason'],
      reasonName: json['reason_name'],
      totalPending: json['total_pending'],
      totalCase: json['total_cases'],
    );
  }
}
