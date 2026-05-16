import 'package:flutter/foundation.dart';
import 'package:shopease_mobile/models/app_user.dart';
import 'package:shopease_mobile/services/local_storage_service.dart';
import 'package:shopease_mobile/services/mock_data_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.dataService, required this.storageService});

  final MockDataService dataService;
  final LocalStorageService storageService;

  AppUser? _user;
  bool _isLoading = true;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await storageService.getUser();
      _error = null;
    } catch (e) {
      _error = _readableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loggedInUser = await dataService.loginUser(email.trim(), password);
      _user = loggedInUser;
      await storageService.saveUser(loggedInUser);
      return true;
    } catch (e) {
      _error = _readableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final registeredUser = await dataService.registerUser(
        name,
        email,
        password,
      );
      _user = registeredUser;
      await storageService.saveUser(registeredUser);
      return true;
    } catch (e) {
      _error = _readableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await storageService.clearUser();
    _user = null;
    _error = null;
    notifyListeners();
  }

  String _readableError(Object error) {
    final raw = error.toString();
    return raw.replaceFirst('Exception: ', '');
  }
}
