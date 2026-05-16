import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shopease_mobile/models/cart_item.dart';
import 'package:shopease_mobile/models/product.dart';
import 'package:shopease_mobile/services/local_storage_service.dart';

class CartController extends ChangeNotifier {
  CartController({required this.storageService});

  final LocalStorageService storageService;

  List<CartItem> _items = <CartItem>[];
  bool _isLoading = true;

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);
  bool get isLoading => _isLoading;

  int get totalItems => _items.fold<int>(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold<double>(
    0,
    (sum, item) => sum + item.product.price * item.quantity,
  );

  Future<void> restoreCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await storageService.getCart();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  void addToCart(Product product) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      _items = <CartItem>[..._items, CartItem(product: product, quantity: 1)];
    }
    _persist();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items = _items.where((item) => item.product.id != productId).toList();
    _persist();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    _items =
        _items.map((item) {
          if (item.product.id != productId) return item;
          return item.copyWith(quantity: quantity);
        }).toList();
    _persist();
    notifyListeners();
  }

  void clearCart() {
    _items = <CartItem>[];
    unawaited(storageService.clearCart());
    notifyListeners();
  }

  void _persist() {
    unawaited(storageService.saveCart(_items));
  }
}
