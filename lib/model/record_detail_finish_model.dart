class DetailRecordFinishModel {
  final String jobNumber;
  final String lotNumber;
  final int finishQty;
  final BCodeModel bcode;

  DetailRecordFinishModel({
    required this.jobNumber,
    required this.lotNumber,
    required this.finishQty,
    required this.bcode,
  });

  factory DetailRecordFinishModel.fromJson(Map<String, dynamic> json) {
    // Pastikan finish_qty selalu int
    int finishQty = 0;
    if (json['finish_qty'] != null) {
      finishQty = json['finish_qty'] is int
          ? json['finish_qty']
          : int.tryParse(json['finish_qty'].toString()) ?? 0;
    }

    return DetailRecordFinishModel(
      jobNumber: json['jobnumber']?.toString() ?? '-',
      lotNumber: json['lotnumber']?.toString() ?? '-', // <-- parsing lotnumber
      finishQty: finishQty,
      bcode: json['bcode'] != null
          ? BCodeModel.fromJson(json['bcode'])
          : BCodeModel.empty(),
    );
  }
}

class BCodeModel {
  final String kode;
  final String drawingNumber;
  final String productCategory;
  final String productType;
  final String nameCompany;

  BCodeModel({
    required this.kode,
    required this.drawingNumber,
    required this.productCategory,
    required this.productType,
    required this.nameCompany,
  });

  // empty constructor untuk safety
  factory BCodeModel.empty() {
    return BCodeModel(
      kode: '-',
      drawingNumber: '-',
      productCategory: '-',
      productType: '-',
      nameCompany: '-',
    );
  }

  factory BCodeModel.fromJson(Map<String, dynamic> json) {
    return BCodeModel(
      kode: json['kode']?.toString() ?? '-',
      drawingNumber: json['drawing_number']?.toString() ?? '-',
      productCategory: json['product_category']?.toString() ?? '-',
      productType: json['product_type']?.toString() ?? '-',
      nameCompany: json['name_company']?.toString() ?? '-',
    );
  }
}
