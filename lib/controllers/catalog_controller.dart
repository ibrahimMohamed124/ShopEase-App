import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:shopease_mobile/models/category.dart';
import 'package:shopease_mobile/models/product.dart';
import 'package:shopease_mobile/services/mock_data_service.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({required this.dataService});

  final MockDataService dataService;

  List<Product> _products = <Product>[];
  List<Product> _featuredProducts = <Product>[];
  List<Category> _categories = <Category>[];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategoryId;

  List<Product> get products => List<Product>.unmodifiable(_products);
  List<Product> get featuredProducts =>
      List<Product>.unmodifiable(_featuredProducts);
  List<Category> get categories => List<Category>.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  List<Product> get filteredProducts {
    var results = _products;

    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      results =
          results
              .where((product) => product.category == _selectedCategoryId)
              .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      results =
          results
              .where(
                (product) =>
                    product.name.toLowerCase().contains(query) ||
                    product.description.toLowerCase().contains(query),
              )
              .toList();
    }

    return results;
  }

  List<Product> productsByCategory(String categoryId) {
    return _products
        .where((product) => product.category == categoryId)
        .toList();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> loadInitial({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _error = null;
    notifyListeners();

    try {
      final featuredFuture = dataService.fetchFeaturedProducts();
      final categoriesFuture = dataService.fetchCategories();
      final productsFuture = dataService.fetchProducts();

      _featuredProducts = await featuredFuture;
      _categories = await categoriesFuture;
      _products = await productsFuture;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<Product?> fetchProductById(String productId) async {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (_) {
      return dataService.fetchProductById(productId);
    }
  }
}
