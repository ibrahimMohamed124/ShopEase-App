import 'package:shopease_mobile/models/order.dart';

class CheckoutState {
  const CheckoutState({
    this.isSubmitting = false,
    this.orderPlaced = false,
    this.paymentMethod = 'card',
    this.placedOrder,
    this.error,
    this.idempotencyKey,
  });

  final bool isSubmitting;
  final bool orderPlaced;
  final String paymentMethod;
  // [جديد] — الطلب الحقيقي اللي رجع من السيرفر بعد النجاح، عشان
  // OrderSuccessView يقدر يعرض رقم الأوردر الحقيقي بدل ما يكتفي برسالة عامة
  final Order? placedOrder;
  final String? error;
  // [جديد] — بيتولّد مرة واحدة أول ما المستخدم يدوس "Place Order"، وبيفضل
  // نفسه لو حصل error وضغط المستخدم "Place Order" تاني (retry) — عشان
  // السيرفر يقدر يمنع الأوردر المكرر. بيتمسح بعد نجاح الأوردر أو reset()
  final String? idempotencyKey;

  CheckoutState copyWith({
    bool? isSubmitting,
    bool? orderPlaced,
    String? paymentMethod,
    Order? placedOrder,
    String? error,
    bool clearError = false,
    String? idempotencyKey,
    bool clearIdempotencyKey = false,
  }) {
    return CheckoutState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      orderPlaced: orderPlaced ?? this.orderPlaced,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      placedOrder: placedOrder ?? this.placedOrder,
      error: clearError ? null : (error ?? this.error),
      idempotencyKey: clearIdempotencyKey
          ? null
          : (idempotencyKey ?? this.idempotencyKey),
    );
  }
}