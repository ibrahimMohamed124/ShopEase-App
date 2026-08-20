import 'package:shopease_mobile/models/app_user.dart';
import 'package:shopease_mobile/repositories/auth_repository.dart';

class AuthController {
  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<AppUser> login(String email, String password) {
    return _authRepository.login(email, password);
  }

  Future<AppUser> register(String name, String email, String password) {
    return _authRepository.register(name, email, password);
  }

  Future<void> requestPasswordReset(String email) {
    return _authRepository.requestPasswordReset(email);
  }

  Future<void> logout() {
    return _authRepository.logout();
  }
}