import 'package:shopease_mobile/core/network/api_client.dart';
import 'package:shopease_mobile/core/network/api_error.dart';
import 'package:shopease_mobile/core/utils/token_storage.dart';
import 'package:shopease_mobile/models/app_user.dart';

class RegisterService {
  RegisterService({
    required ApiClient client,
    required TokenStorage tokenStorage,
  })  : _client = client,
        _tokenStorage = tokenStorage;

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  Future<AppUser> register(String name, String email, String password) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );

    final token = response['token'] ?? response['accessToken'];
    if (token is String && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
    }

    final userJson = response['user'] ?? response['data'] ?? response;
    if (userJson is! Map<String, dynamic>) {
      throw const ApiException(message: 'The server returned an unexpected user response.');
    }

    return AppUser.fromJson(userJson);
  }
}
