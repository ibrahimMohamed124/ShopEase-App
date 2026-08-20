import 'package:shopease_mobile/models/cart_item.dart';
import 'package:shopease_mobile/models/order.dart';
import 'package:shopease_mobile/repositories/checkout_repository.dart';

// [تعديل] — النسخة القديمة كانت ChangeNotifier مستقلة، بتعمل simulated
// delay وترجع true من غير ما تلمس أي repository أو service خالص. استبدلناها
// بطبقة رفيعة بتفوّت لـCheckoutRepository، بالظبط زي CartController/
// ShippingAddressController، عشان تتماشى مع باقي المشروع وتبقى مربوطة
// فعليًا بالسيرفر.
class CheckoutController {
  CheckoutController({required CheckoutRepository checkoutRepository})
      : _checkoutRepository = checkoutRepository;

  final CheckoutRepository _checkoutRepository;

  String? validateFields({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String zipCode,
  }) =>
      _checkoutRepository.validateFields(
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: state,
        zipCode: zipCode,
      );

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
  }) =>
      _checkoutRepository.placeOrder(
        cartItems: cartItems,
        total: total,
        paymentMethod: paymentMethod,
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: state,
        zipCode: zipCode,
        idempotencyKey: idempotencyKey,
      );
}