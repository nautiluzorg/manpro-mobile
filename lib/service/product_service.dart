import 'package:dio/dio.dart';
import 'package:flutter_provider_data/model/master/product_model.dart';

import 'dio_client.dart';

class ProductService {
  final Dio _dio;

  ProductService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<ProductModel>> getProductDropdown({
    String search = '',
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/api/product-dropdown-list/',
      cancelToken: cancelToken,
      queryParameters: search.trim().isEmpty
          ? null
          : <String, dynamic>{'search': search.trim()},
    );

    final data = response.data;
    if (data is! List) {
      throw const FormatException('Format data product tidak valid.');
    }

    return data
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((product) => product.hasDrawing)
        .toList();
  }
}
