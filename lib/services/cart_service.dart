import 'package:shopease_mobile/core/network/api_client.dart';
import 'package:shopease_mobile/models/cart_item.dart';

class CartService {
  CartService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<CartItem>> loadCart() {
    return _apiClient.get<List<CartItem>>(
      '/cart',
      parser: (data) {
        final items = data as List<dynamic>;
        return items
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<void> addToCart({
    required String productId,
    required int quantity,
  }) async {
    await _apiClient.post<dynamic>(
      '/cart',
      body: {'productId': productId, 'quantity': quantity},
    );
  }

  Future<void> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    await _apiClient.patch<dynamic>(
      '/cart/$productId',
      body: {'quantity': quantity},
    );
  }

  Future<void> removeFromCart(String productId) async {
    await _apiClient.delete<dynamic>('/cart/$productId');
  }

  Future<void> clearCart() async {
    await _apiClient.delete<dynamic>('/cart');
  }
}