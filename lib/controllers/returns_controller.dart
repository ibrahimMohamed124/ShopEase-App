import 'package:flutter/foundation.dart';
import 'package:shopease_mobile/models/return_request.dart';
import 'package:shopease_mobile/services/app_data_service.dart';

class ReturnsController extends ChangeNotifier {
  ReturnsController({required this.dataService});

  final AppDataService dataService;

  List<ReturnRequest> _returns = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<ReturnRequest> get returns => List.unmodifiable(_returns);
  List<ReturnRequest> get activeReturns =>
      _returns.where((r) => r.status == ReturnStatus.inReview).toList();
  List<ReturnRequest> get pastReturns =>
      _returns.where((r) => r.status != ReturnStatus.inReview).toList();

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<void> loadReturns() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _returns = await dataService.fetchReturnRequests();
    } catch (e) {
      _error = _readableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReturn({
    required String orderId,
    String? reason,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final newReturn = await dataService.submitReturnRequest(
        orderId: orderId,
        reason: reason,
      );
      _returns = [newReturn, ..._returns];
      return true;
    } catch (e) {
      _error = _readableError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String _readableError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
