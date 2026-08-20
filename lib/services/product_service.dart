import 'dart:io';

import 'package:shopease_mobile/core/network/api_client.dart';
import 'package:shopease_mobile/core/network/api_error.dart';
import 'package:shopease_mobile/models/product.dart';

class ProductService {
  ProductService({required ApiClient client}) : _client = client;

  final ApiClient _client;

  Future<List<Product>> fetchProducts({String? category, String? search}) async {
    final response = await _client.get<dynamic>(
      '/products',
      queryParameters: <String, String?>{
        'category': category,
        'search': search,
      },
    );

    return _readList(response, wrapperKeys: const ['products', 'data', 'items']);
  }

  Future<Product?> fetchProductById(String id) async {
    try {
      final response =
          await _client.get<dynamic>('/products/${Uri.encodeComponent(id)}');
      return Product.fromJson(
        _readObject(response, wrapperKeys: const ['product', 'data', 'item']),
      );
    } on ApiException catch (error) {
      if (error.statusCode == HttpStatus.notFound) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<Product>> fetchFeaturedProducts() async {
    try {
      final response = await _client.get<dynamic>('/products/featured');
      return _readList(response, wrapperKeys: const ['products', 'data', 'items']);
    } on ApiException catch (error) {
      if (error.statusCode != HttpStatus.notFound) {
        rethrow;
      }
      // السيرفر لسه معملوش endpoint مخصص للـfeatured: fallback على المنتجات اللي عندها badge
      final products = await fetchProducts();
      return products.where((product) => product.badge != null).take(6).toList();
    }
  }

  List<Product> _readList(dynamic response, {required List<String> wrapperKeys}) {
    final rawList = switch (response) {
      final List<dynamic> value => value,
      final Map<String, dynamic> value => _listFromWrappedResponse(value, wrapperKeys),
      _ => throw const ApiException(
          message: 'The server returned an unexpected list response.'),
    };

    return rawList.map((entry) => Product.fromJson(_ensureObject(entry))).toList(growable: false);
  }

  Map<String, dynamic> _readObject(dynamic response, {required List<String> wrapperKeys}) {
    if (response is! Map<String, dynamic>) {
      throw const ApiException(message: 'The server returned an unexpected object response.');
    }
    for (final key in wrapperKeys) {
      final value = response[key];
      if (value is Map<String, dynamic>) return value;
    }
    return response;
  }

  List<dynamic> _listFromWrappedResponse(Map<String, dynamic> response, List<String> wrapperKeys) {
    for (final key in wrapperKeys) {
      final value = response[key];
      if (value is List<dynamic>) return value;
    }
    throw const ApiException(message: 'The server returned an unexpected list response.');
  }

  Map<String, dynamic> _ensureObject(dynamic entry) {
    if (entry is Map<String, dynamic>) return entry;
    throw const ApiException(message: 'The server returned an unexpected item response.');
  }
}