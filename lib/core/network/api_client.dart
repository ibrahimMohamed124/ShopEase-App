import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shopease_mobile/core/network/api_error.dart';
import 'package:shopease_mobile/core/utils/token_storage.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    HttpClient? httpClient,
    this.timeout = const Duration(seconds: 20),
    required TokenStorage tokenStorage,
    this.onSessionExpired,   // [جديد]
  })  : _httpClient = httpClient ?? HttpClient(),
        _tokenStorage = tokenStorage;

  final String baseUrl;
  final Duration timeout;
  final HttpClient _httpClient;
  final TokenStorage _tokenStorage;

  /// [جديد] بينادَى لما الـrefresh نفسه يفشل — يعني الجلسة خلصت فعلًا.
  /// اربطها بأي منطق logout + navigate to login في الـDI.
  final Future<void> Function()? onSessionExpired;

  // [جديد] عشان لو أكتر من request جالها 401 في نفس اللحظة، يشتركوا
  // في نفس محاولة الـrefresh بدل ما كل واحد يعمل refresh لوحده.
  Future<bool>? _refreshFuture;

  Future<T> get<T>(
    String path, {
    Map<String, String?> queryParameters = const {},
    T Function(dynamic data)? parser,
  }) {
    return _send<T>('GET', path, queryParameters: queryParameters, parser: parser);
  }

  Future<T> post<T>(
    String path, {
    Map<String, String?> queryParameters = const {},
    Object? body,
    T Function(dynamic data)? parser,
    // [جديد] — عشان لو الـcaller محتاج يبعت header زي Idempotency-Key
    // من غير ما نعمل method جديد أو نغيّر توقيع _send بالكامل
    Map<String, String> headers = const {},
  }) {
    return _send<T>(
      'POST',
      path,
      queryParameters: queryParameters,
      body: body,
      parser: parser,
      headers: headers,
    );
  }

  Future<T> put<T>(
    String path, {
    Map<String, String?> queryParameters = const {},
    Object? body,
    T Function(dynamic data)? parser,
  }) {
    return _send<T>('PUT', path, queryParameters: queryParameters, body: body, parser: parser);
  }

  Future<T> patch<T>(
    String path, {
    Map<String, String?> queryParameters = const {},
    Object? body,
    T Function(dynamic data)? parser,
  }) {
    return _send<T>('PATCH', path, queryParameters: queryParameters, body: body, parser: parser);
  }

  Future<T> delete<T>(
    String path, {
    Map<String, String?> queryParameters = const {},
    T Function(dynamic data)? parser,
  }) {
    return _send<T>('DELETE', path, queryParameters: queryParameters, parser: parser);
  }

Future<T> uploadFile<T>(
  String path, {
  required String fieldName,
  required File file,
  T Function(dynamic data)? parser,
}) async {
  final uri = _buildUri(path, const {});
  final request = http.MultipartRequest('POST', uri);

  final token = await _tokenStorage.readToken();
  if (token != null && token.isNotEmpty) {
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
  }

  request.files.add(
    await http.MultipartFile.fromPath(
      fieldName,
      file.path,
      // [جديد] — من غير ده، http.MultipartFile.fromPath() مبيحددش الـ
      // content-type من نفسه وبيبعت 'application/octet-stream' كـdefault،
      // فالسيرفر بيرفضها حتى لو الصورة JPG فعلاً وصح 100%
      contentType: _mediaTypeForPath(file.path),
    ),
  );

  final streamedResponse = await request.send().timeout(timeout);
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode < HttpStatus.ok ||
      response.statusCode >= HttpStatus.multipleChoices) {
    throw ApiException(
      statusCode: response.statusCode,
      message: _readErrorMessage(response.body) ??
          'Request failed with status ${response.statusCode}.',
    );
  }

  final decoded = jsonDecode(response.body);
  if (parser != null) return parser(decoded);
  return decoded as T;
}

  Future<T> _send<T>(
    String method,
    String path, {
    Map<String, String?> queryParameters = const {},
    Object? body,
    T Function(dynamic data)? parser,
    bool isRetry = false,   // [جديد]
    Map<String, String> headers = const {},   // [جديد]
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);

      final request = await _httpClient.openUrl(method, uri).timeout(timeout);

      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final token = await _tokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      // [جديد] — extra headers زي Idempotency-Key. بعد الـauth header
      // القياسي عشان لو حد بعت override لـAuthorization غلط بالغلط
      // الافتراضي (token) هو اللي يفوز، مش أي حاجة جاية من الـcaller
      for (final entry in headers.entries) {
        if (entry.value.trim().isNotEmpty) {
          request.headers.set(entry.key, entry.value);
        }
      }

      if (body != null) {
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(timeout);
      final rawBody = await utf8.decoder.bind(response).join().timeout(timeout);

      // [جديد] — اعتراض الـ401 قبل الـerror handling العادي
      if (response.statusCode == HttpStatus.unauthorized &&
          !isRetry &&
          !path.startsWith('/auth/')) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return _send<T>(
            method,
            path,
            queryParameters: queryParameters,
            body: body,
            parser: parser,
            isRetry: true,
            headers: headers,
          );
        }
        await _handleSessionExpired();
        throw const ApiException(
          statusCode: HttpStatus.unauthorized,
          message: 'Your session has expired. Please sign in again.',
        );
      }

      if (response.statusCode < HttpStatus.ok ||
          response.statusCode >= HttpStatus.multipleChoices) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _readErrorMessage(rawBody) ??
              'Request failed with status ${response.statusCode}.',
        );
      }

      if (rawBody.trim().isEmpty) {
        return null as T;
      }

      final decodedBody = jsonDecode(rawBody);

      if (parser != null) {
        return parser(decodedBody);
      }

      return decodedBody as T;
    } on ApiException {
      rethrow;
    } on TimeoutException catch (error) {
      throw ApiException(message: 'The server took too long to respond.', cause: error);
    } on SocketException catch (error) {
      throw ApiException(message: 'Could not connect to the server.', cause: error);
    } on FormatException catch (error) {
      throw ApiException(message: 'The server returned invalid data.', cause: error);
    } on TypeError catch (error) {
      throw ApiException(message: 'The server returned data in an unexpected format.', cause: error);
    }
  }

  // [جديد] — الـmutex بتاع الـrefresh
  Future<bool> _refreshAccessToken() {
    return _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  // [جديد] — نداء منفصل تمامًا لـ/auth/refresh (مش عن طريق _send عشان نتفادى infinite loop)
  Future<bool> _performRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final uri = _buildUri('/auth/refresh', const {});
      final request = await _httpClient.openUrl('POST', uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode({'refreshToken': refreshToken}));

      final response = await request.close().timeout(timeout);
      final rawBody = await utf8.decoder.bind(response).join().timeout(timeout);

      if (response.statusCode < HttpStatus.ok ||
          response.statusCode >= HttpStatus.multipleChoices) {
        return false;
      }
      if (rawBody.trim().isEmpty) return false;

      final decoded = jsonDecode(rawBody);
      if (decoded is! Map<String, dynamic>) return false;

      final newToken = decoded['token'] ?? decoded['accessToken'];
      final newRefreshToken = decoded['refreshToken'];
      if (newToken is! String || newToken.isEmpty) return false;

      await _tokenStorage.saveTokens(
        token: newToken,
        refreshToken: newRefreshToken is String ? newRefreshToken : null,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // [جديد]
  Future<void> _handleSessionExpired() async {
    await _tokenStorage.clearToken();
    if (onSessionExpired != null) {
      await onSessionExpired!();
    }
  }

  // [جديد] — بيحدد الـcontent-type الصح حسب امتداد الملف عشان الـfileFilter
  // بتاع multer في السيرفر (اللي بيتأكد إن الصورة jpeg/png/webp) يقبلها
  MediaType? _mediaTypeForPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return null; // سيب http يحدد الافتراضي لو امتداد غريب
    }
  }

  Uri _buildUri(String path, Map<String, String?> queryParameters) {
    final trimmedBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$trimmedBaseUrl$normalizedPath');

    final filteredQuery = <String, String>{
      ...uri.queryParameters,
      for (final entry in queryParameters.entries)
        if (entry.value != null && entry.value!.trim().isNotEmpty)
          entry.key: entry.value!.trim(),
    };

    return uri.replace(queryParameters: filteredQuery.isEmpty ? null : filteredQuery);
  }

  String? _readErrorMessage(String rawBody) {
    if (rawBody.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final errors = decoded['errors'];
        if (errors is Map<String, dynamic>) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
          }
        }

        final message = decoded['message'] ?? decoded['error'] ?? decoded['title'];
        if (message != null && '$message'.trim().isNotEmpty) {
          return '$message';
        }
      }
    } on FormatException {
      return rawBody.trim();
    }

    return null;
  }

  void close() {
    _httpClient.close();
  }
}