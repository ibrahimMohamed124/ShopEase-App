import 'package:shopease_mobile/core/network/api_client.dart';
import 'package:shopease_mobile/core/network/api_error.dart';
import 'package:shopease_mobile/models/order.dart';

class CheckoutService {
  CheckoutService({required ApiClient client}) : _client = client;

  final ApiClient _client;

  // POST /orders — بيرجع الـorder اللي اتحفظ فعلًا (بالـid الحقيقي بتاعه)
  // عشان OrdersScreen يقدر يعرضه بعدين. الـresponse ممكن يكون تحت 'order'
  // أو 'data' أو الكائن نفسه من غير غلاف، فبنتعامل مع التلاتة زي باقي
  // الـservices في المشروع (shipping_address_service.dart مثلاً)
  // [جديد] — idempotencyKey اختياري: لو الـcaller بعته، بيتضاف كـheader
  // Idempotency-Key. السيرفر (checkout.controller.ts) بيستخدمه عشان لو
  // نفس الأوردر اتبعت مرتين (دبل-كليك على "Place Order"، أو retry بعد
  // timeout في الشبكة) يرجّع نفس الأوردر القديم بدل ما يعمل أوردر
  // ويخصم ستوك تاني. من غيره، السلوك زي ما هو بالظبط
  Future<Order> placeOrder({
    required List<OrderItem> items,
    required double total,
    required String paymentMethod,
    required Map<String, String> shippingAddress,
    String? idempotencyKey,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/orders',
      body: {
        'items': items.map((i) => i.toJson()).toList(),
        'total': total,
        'paymentMethod': paymentMethod,
        'shippingAddress': shippingAddress,
      },
      headers: idempotencyKey != null && idempotencyKey.trim().isNotEmpty
          ? {'Idempotency-Key': idempotencyKey.trim()}
          : const {},
    );

    final orderJson = response['order'] ?? response['data'] ?? response;
    if (orderJson is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'The server returned an unexpected order response.',
      );
    }
    return Order.fromJson(orderJson);
  }
}