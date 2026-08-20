import 'package:shopease_mobile/core/network/api_client.dart';
import 'package:shopease_mobile/core/network/api_error.dart';
import 'package:shopease_mobile/models/order.dart';

class OrdersService {
  OrdersService({required ApiClient client}) : _client = client;

  final ApiClient _client;

  // GET /orders — لازم يرجع array (خام أو تحت 'orders'/'data')، بنتعامل مع
  // الحالتين زي WishlistService.findAll بالظبط
  Future<List<Order>> fetchOrders() {
    return _client.get<List<Order>>(
      '/orders',
      parser: (data) {
        final raw = data is Map<String, dynamic>
            ? (data['orders'] ?? data['data'] ?? const [])
            : data;
        final list = raw as List<dynamic>;
        return list
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // GET /orders/:id — مفيدة لشاشة تفاصيل أوردر لاحقًا (زي "Buy Again" /
  // "Track Order" الموجودين في التصميم بس من غير أي منطق حاليًا)
  Future<Order?> fetchOrderById(String id) async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/orders/$id');
      final orderJson = response['order'] ?? response['data'] ?? response;
      if (orderJson is! Map<String, dynamic>) return null;
      return Order.fromJson(orderJson);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  // [جديد] — PATCH /orders/:id/cancel، بيرجع الأوردر بعد ما status يتحدث
  // لـ'cancelled' من السيرفر (مش بنغيره محليًا فقط عشان لو فيه business rule
  // زي "متأخر أوي على الإلغاء" السيرفر هو اللي يقرر ويرفض لو محتاج)
  Future<Order> cancelOrder(String id) {
    return _client.patch<Order>(
      '/orders/$id/cancel',
      parser: (data) {
        final orderJson = data is Map<String, dynamic>
            ? (data['order'] ?? data['data'] ?? data)
            : data;
        return Order.fromJson(orderJson as Map<String, dynamic>);
      },
    );
  }
}
