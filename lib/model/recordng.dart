class RecordNg {
  final String idNg;
  final String ngName;
  final int qty;

  RecordNg({required this.idNg, required this.ngName, required this.qty});

  // Fungsi untuk mengonversi data JSON menjadi objek RecordNg
  factory RecordNg.fromJson(Map<String, dynamic> json) {
    return RecordNg(
      idNg: json['id_ng'],
      ngName: json['ng_name'],
      qty: json['qty'],
    );
  }

  static List<RecordNg> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => RecordNg.fromJson(item)).toList();
  }
}
