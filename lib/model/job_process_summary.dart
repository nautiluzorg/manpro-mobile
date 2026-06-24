class JobProcessSummary {
  final int totalTestQty;

  JobProcessSummary({
    required this.totalTestQty,
  });

  factory JobProcessSummary.fromJson(Map<String, dynamic> json) {
    return JobProcessSummary(
      totalTestQty: json['total_test_qty'] ?? 0,
    );
  }
}
