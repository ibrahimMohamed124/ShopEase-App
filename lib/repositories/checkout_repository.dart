import 'package:shopease_mobile/models/cart_item.dart';
import 'package:shopease_mobile/models/order.dart';
import 'package:shopease_mobile/services/checkout_service.dart';

class CheckoutRepository {
  CheckoutRepository({required CheckoutService checkoutService})
      : _checkoutService = checkoutService;

  final CheckoutService _checkoutService;

  // فاليديشن الفورم — نفس الحقول اللي checkout_screen.dart بتجمعها،
  // نقلناها هنا (كانت جوه الـcubit مباشرة) عشان تفضل business rule منفصلة
  // عن الـstate management زي باقي المديولز (shipping_address مثلاً)
  String? validateFields({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String zipCode,
  }) {
    if (fullName.trim().isEmpty) return 'Full name is required.';
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'Valid email is required.';
    }
    if (phone.trim().isEmpty) return 'Phone number is required.';
    if (address.trim().isEmpty) return 'Address is required.';
    if (city.trim().isEmpty) return 'City is required.';
    if (state.trim().isEmpty) return 'State is required.';
    if (zipCode.trim().isEmpty) return 'ZIP code is required.';
    return null;
  }

  // بتحول سطور الكارت (CartItem بتاعة الـCartCubit) إلى OrderItem وتبعتها
  // فعليًا للسيرفر — ده اللي كان ناقص بالكامل قبل كده (كان بس delay وهمي)
  Future<Order> placeOrder({
    required List<CartItem> cartItems,
    required double total,
    required String paymentMethod,
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String zipCode,
    String? idempotencyKey,
  }) {
    final items = cartItems
        .map(
          (c) => OrderItem(
            productId: c.product.id,
            name: c.product.name,
            imageUrl: c.product.imageUrl,
            price: c.product.price,
            quantity: c.quantity,
          ),
        )
        .toList();

    return _checkoutService.placeOrder(
      items: items,
      total: total,
      paymentMethod: paymentMethod,
      shippingAddress: {
        'name': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'street': address.trim(),
        'city': city.trim(),
        'state': state.trim(),
        'zip': zipCode.trim(),
      },
      idempotencyKey: idempotencyKey,
    );
  }
}