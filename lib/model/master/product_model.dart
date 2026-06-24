import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/utils/safe_json_extension.dart';
import 'package:flutter_provider_data/utils/logger.dart';

@immutable
class ProductModel {
  final String bcode;
  final String drawingNumber;
  final String productType;
  final String productCategory;
  final String companyName;

  const ProductModel({
    required this.bcode,
    required this.drawingNumber,
    required this.productType,
    required this.productCategory,
    required this.companyName,
  });

  /// Factory dengan safe parsing untuk menangani String JSON dari API
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    logPrint("🔍 ProductModel.fromJson - bcode: ${json['bcode']}");

    return ProductModel(
      bcode: json.safeString('bcode'),
      drawingNumber: json.safeString('drawing_number'),
      productType: json.safeString('product_type'),
      productCategory: json.safeString('product_category'),
      companyName: json.safeString('name_company'),
    );
  }

  /// Serialize ke JSON (payload / cache)
  Map<String, dynamic> toJson() {
    return {
      'bcode': bcode,
      'drawing_number': drawingNumber,
      'product_type': productType,
      'product_category': productCategory,
      'name_company': companyName,
    };
  }

  /// Representasi product kosong (safe default)
  static const empty = ProductModel(
    bcode: '',
    drawingNumber: '',
    productType: '',
    productCategory: '',
    companyName: '',
  );

  /// Apakah product valid (sudah ter-load)
  bool get isValid => bcode.isNotEmpty;

  /// Apakah product memiliki drawing
  bool get hasDrawing => drawingNumber.isNotEmpty;

  /// Label utama untuk UI
  String get displayName => '$bcode - $productType';

  /// Copy with (immutable update)
  ProductModel copyWith({
    String? bcode,
    String? drawingNumber,
    String? productType,
    String? productCategory,
    String? companyName,
  }) {
    return ProductModel(
      bcode: bcode ?? this.bcode,
      drawingNumber: drawingNumber ?? this.drawingNumber,
      productType: productType ?? this.productType,
      productCategory: productCategory ?? this.productCategory,
      companyName: companyName ?? this.companyName,
    );
  }

  @override
  String toString() {
    return 'ProductModel(bcode: $bcode, drawingNumber: $drawingNumber, productType: $productType)';
  }
}
