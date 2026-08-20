import 'package:flutter/foundation.dart';
import 'package:shopease_mobile/models/payment_method.dart';
import 'package:shopease_mobile/services/app_data_service.dart';

class PaymentMethodsController extends ChangeNotifier {
  PaymentMethodsController({required this.dataService});

  final AppDataService dataService;

  List<PaymentMethod> _methods = [];
  bool _isLoading = false;
  bool _isMutating = false;
  String? _error;

  List<PaymentMethod> get methods => List.unmodifiable(_methods);
  List<PaymentMethod> get cards =>
      _methods.where((m) => m.isCard).toList();
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get error => _error;

  PaymentMethod? get defaultMethod {
    try {
      return _methods.firstWhere((m) => m.isDefault);
    } catch (_) {
      return _methods.isNotEmpty ? _methods.first : null;
    }
  }

  Future<void> loadMethods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _methods = await dataService.fetchPaymentMethods();
    } catch (e) {
      _error = _readableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCard({
    required PaymentMethodType type,
    required String lastFour,
    required String expiry,
    required String holderName,
  }) async {
    _isMutating = true;
    _error = null;
    notifyListeners();

    try {
      final newMethod = await dataService.addPaymentMethod(
        type: type,
        lastFour: lastFour,
        expiry: expiry,
        holderName: holderName,
      );
      _methods = [..._methods, newMethod];
      return true;
    } catch (e) {
      _error = _readableError(e);
      return false;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<bool> removeMethod(String id) async {
    _isMutating = true;
    _error = null;
    notifyListeners();

    try {
      await dataService.removePaymentMethod(id);
      _methods = _methods.where((m) => m.id != id).toList();
      return true;
    } catch (e) {
      _error = _readableError(e);
      return false;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  void setDefault(String id) {
    _methods = _methods.map((m) => m.copyWith(isDefault: m.id == id)).toList();
    notifyListeners();
  }

  String _readableError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
