import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease_mobile/controllers/checkout_controller.dart';
import 'package:shopease_mobile/core/network/api_error.dart';
import 'package:shopease_mobile/core/utils/idempotency_key.dart';
import 'package:shopease_mobile/models/cart_item.dart';

import 'checkout_state.dart';

export 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({required this.checkoutController})
      : super(const CheckoutState());

  final CheckoutController checkoutController;

  double shippingFor(double subtotal) => subtotal > 100 ? 0 : 9.99;

  // [تعديل] — round لأقرب قرش عشان floating point multiplication
  // (subtotal * 0.08) بيطلّع أرقام فيها decimal places أكتر من 2
  // (زي 3.4392000000000005)، وده كان بيخلي grandTotalFor يبعت total
  // مرفوض من IsNumber({ maxDecimalPlaces: 2 }) في checkout.dto.ts
  double taxFor(double subtotal) =>
      (subtotal * 0.08 * 100).round() / 100;

  double grandTotalFor(double subtotal) =>
      ((subtotal + shippingFor(subtotal) + taxFor(subtotal)) * 100)
          .round() /
      100;

  // [جديد] — لو المستخدم غيّر طريقة الدفع بعد محاولة فاشلة (قبل ما يدوس
  // "Place Order" تاني)، الـbody بقى مختلف عن اللي اتحسب منه requestHash
  // القديم. لو سبنا نفس idempotencyKey، السيرفر هيرفضها بـ409 (mismatch)
  // بدل ما يعمل الأوردر الجديد. فبنمسح الـkey القديم عشان يتولّد واحد جديد
  void setPaymentMethod(String method) => emit(state.copyWith(
        paymentMethod: method,
        clearIdempotencyKey: true,
      ));

  void reset() => emit(state.copyWith(
        orderPlaced: false,
        clearError: true,
        clearIdempotencyKey: true,
      ));

  // [تعديل] — كانت بتعمل Future.delayed(900ms) وترجع true من غير ما تكلم
  // السيرفر خالص. دلوقتي بتنادي فعليًا على CheckoutController اللي بيبعت
  // الأوردر لـPOST /orders، وبتحفظ الـorder الحقيقي في الـstate
  Future<bool> placeOrder({
    required List<CartItem> cartItems,
    required double total,
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String zipCode,
  }) async {
    final validationError = checkoutController.validateFields(
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
      city: city,
      state: state,
      zipCode: zipCode,
    );

    if (validationError != null) {
      emit(this.state.copyWith(error: validationError));
      return false;
    }

    // [جديد] — بنولّد الـkey مرة واحدة بس ونفضل نستخدمه في كل retry
    // (طالما مفيش reset() أو نجاح) عشان لو المستخدم دوس "Place Order" تاني
    // بعد error، السيرفر يقدر يتعرف إنها نفس المحاولة ومايعملش أوردر مكرر
    final idempotencyKey = this.state.idempotencyKey ?? generateIdempotencyKey();

    emit(this.state.copyWith(
      isSubmitting: true,
      orderPlaced: false,
      clearError: true,
      idempotencyKey: idempotencyKey,
    ));

    try {
      final order = await checkoutController.placeOrder(
        cartItems: cartItems,
        total: total,
        paymentMethod: this.state.paymentMethod,
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: state,
        zipCode: zipCode,
        idempotencyKey: idempotencyKey,
      );

      emit(this.state.copyWith(
        isSubmitting: false,
        orderPlaced: true,
        placedOrder: order,
        clearIdempotencyKey: true,
      ));
      return true;
    } on ApiException catch (e) {
      emit(this.state.copyWith(isSubmitting: false, error: e.message));
      return false;
    } catch (e) {
      emit(this.state.copyWith(
        isSubmitting: false,
        error: 'Something went wrong while placing your order.',
      ));
      return false;
    }
  }
}