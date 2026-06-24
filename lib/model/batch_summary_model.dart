class BatchSummaryModel {
  final String batchNumber;
  final String totalJobnumber;
  final int totalNg;
  final int totalPending;
  final int totalCycleTime;
  final int totalTime;
  final int totalFinishQty;
  final int totalStartQty;
  final String drawingNumber;
  final String nameCompany;
  final String productCategory;
  final String productType;

  BatchSummaryModel({
    required this.batchNumber,
    required this.totalJobnumber,
    required this.totalNg,
    required this.totalPending,
    required this.totalCycleTime,
    required this.totalTime,
    required this.totalFinishQty,
    required this.totalStartQty,
    required this.drawingNumber,
    required this.nameCompany,
    required this.productCategory,
    required this.productType,
  });

  factory BatchSummaryModel.fromJson(Map<String, dynamic> json) {
    return BatchSummaryModel(
      batchNumber: json['batch_number'],
      totalJobnumber: json['total_jobnumber'],
      totalNg: json['total_ng'],
      totalPending: json['total_pending'],
      totalCycleTime: json['total_cycle_time'],
      totalTime: json['total_time'],
      totalFinishQty: json['total_finish_qty'],
      totalStartQty: json['total_start_qty'],
      drawingNumber: json['drawing_number'],
      nameCompany: json['name_company'],
      productCategory: json['product_category'],
      productType: json['product_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_number': batchNumber,
      'total_jobnumber': totalJobnumber,
      'total_ng': totalNg,
      'total_pending': totalPending,
      'total_cycle_time': totalCycleTime,
      'total_time': totalTime,
      'total_finish_qty': totalFinishQty,
      'total_start_qty': totalStartQty,
      'drawing_number': drawingNumber,
      'name_company': nameCompany,
      'product_category': productCategory,
      'product_type': productType,
    };
  }
}
