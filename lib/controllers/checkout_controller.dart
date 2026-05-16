import 'package:flutter/foundation.dart';

class CheckoutController extends ChangeNotifier {
  bool _isSubmitting = false;
  bool _orderPlaced = false;
  String _paymentMethod = 'card';
  String? _error;

  bool get isSubmitting => _isSubmitting;
  bool get orderPlaced => _orderPlaced;
  String get paymentMethod => _paymentMethod;
  String? get error => _error;

  double shippingFor(double subtotal) {
    return subtotal > 100 ? 0 : 9.99;
  }

  double taxFor(double subtotal) {
    return subtotal * 0.08;
  }

  double grandTotalFor(double subtotal) {
    return subtotal + shippingFor(subtotal) + taxFor(subtotal);
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void reset() {
    _error = null;
    _orderPlaced = false;
    notifyListeners();
  }

  Future<bool> placeOrder({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String zipCode,
  }) async {
    final validationError = _validateFields(
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
      city: city,
      state: state,
      zipCode: zipCode,
    );

    if (validationError != null) {
      _error = validationError;
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _orderPlaced = false;
    _error = null;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));

    _isSubmitting = false;
    _orderPlaced = true;
    notifyListeners();
    return true;
  }

  String? _validateFields({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String zipCode,
  }) {
    if (fullName.trim().isEmpty) {
      return 'Full name is required.';
    }

    if (email.trim().isEmpty || !email.contains('@')) {
      return 'Valid email is required.';
    }

    if (phone.trim().isEmpty) {
      return 'Phone number is required.';
    }

    if (address.trim().isEmpty) {
      return 'Address is required.';
    }

    if (city.trim().isEmpty) {
      return 'City is required.';
    }

    if (state.trim().isEmpty) {
      return 'State is required.';
    }

    if (zipCode.trim().isEmpty) {
      return 'ZIP code is required.';
    }

    return null;
  }
}
