class NgSummaryModel {
  final String idNg;
  final String ngName;
  final int totalQty;

  NgSummaryModel(
      {required this.idNg, required this.ngName, required this.totalQty});

  factory NgSummaryModel.fromJson(Map<String, dynamic> json) {
    return NgSummaryModel(
      idNg: json['id_ng'],
      ngName: json['ng_name'],
      totalQty: json['total_qty'],
    );
  }
}
