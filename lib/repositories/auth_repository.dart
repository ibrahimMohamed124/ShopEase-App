import 'package:shopease_mobile/core/utils/token_storage.dart';
import 'package:shopease_mobile/models/app_user.dart';
import 'package:shopease_mobile/services/forgot_password_service.dart';
import 'package:shopease_mobile/services/login_service.dart';
import 'package:shopease_mobile/services/register_service.dart';

class AuthRepository {
  AuthRepository({
    required TokenStorage tokenStorage,
    required LoginService loginService,
    required RegisterService registerService,
    required ForgotPasswordService forgotPasswordService,
  })  : _tokenStorage = tokenStorage,
        _loginService = loginService,
        _registerService = registerService,
        _forgotPasswordService = forgotPasswordService;

  final TokenStorage _tokenStorage;
  final LoginService _loginService;
  final RegisterService _registerService;
  final ForgotPasswordService _forgotPasswordService;

  Future<AppUser> login(String email, String password) {
    return _loginService.login(email, password);
  }

  Future<AppUser> register(String name, String email, String password) {
    return _registerService.register(name, email, password);
  }

  Future<void> requestPasswordReset(String email) {
    return _forgotPasswordService.requestReset(email);
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }
}