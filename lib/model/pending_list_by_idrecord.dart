class PendingListByIdrecord {
  final int idPending;
  final String nameReason;
  final String startPending;
  final String finishPending;
  final int totalPending;

  PendingListByIdrecord({
    required this.idPending,
    required this.nameReason,
    required this.startPending,
    required this.finishPending,
    required this.totalPending,
  });

  factory PendingListByIdrecord.fromJson(Map<String, dynamic> json) {
    return PendingListByIdrecord(
      idPending: json['id_pending'],
      nameReason: json['id_reason']['name_reason'],
      startPending: json['start_pending'],
      finishPending: json['finish_pending'],
      totalPending: json['total_pending'],
    );
  }

  static List<PendingListByIdrecord> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => PendingListByIdrecord.fromJson(item))
        .toList();
  }
}
