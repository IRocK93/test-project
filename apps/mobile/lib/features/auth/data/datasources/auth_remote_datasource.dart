import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../data/api_client.dart';
import '../../domain/entities/user.dart';

class AuthRemoteDatasource {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  AuthRemoteDatasource({required ApiClient apiClient, required SharedPreferences prefs})
      : _apiClient = apiClient,
        _prefs = prefs;

  Future<({User user, String token})> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        final token = response.data['accessToken'] as String;
        final refreshToken = response.data['refreshToken'] as String? ?? '';
        await _prefs.setString('accessToken', token);
        await _prefs.setString('userId', user.id);
        await _prefs.setString('userEmail', user.email);
        await _apiClient.saveTokens(token, refreshToken, user.id);
        return (user: user, token: token);
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Invalid email or password';
      throw Exception(message);
    }
  }

  Future<({User user, String token})> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {'email': email, 'password': password, 'name': name},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          final user = User.fromJson(response.data['user'] ?? {});
          final token = response.data['accessToken'] as String? ?? '';
          final refreshToken = response.data['refreshToken'] as String? ?? '';
          await _prefs.setString('accessToken', token);
          await _prefs.setString('userId', user.id);
          await _prefs.setString('userEmail', user.email);
          await _apiClient.saveTokens(token, refreshToken, user.id);
          return (user: user, token: token);
        } else {
          final responseType = response.data.runtimeType.toString();
          final responseContent = response.data.toString();
          throw Exception('Unexpected response format. Type: $responseType, Content: $responseContent');
        }
      } else {
        final errorMsg = response.data is Map ? response.data['message'] : 
                         response.data is List ? response.data.join(', ') : 
                         'Failed to register (Status: ${response.statusCode})';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final body = e.response?.data;
      String message;
      if (body is Map) {
        message = body['message']?.toString() ?? body.toString();
      } else {
        message = body?.toString() ?? 'No response body';
      }
      throw Exception('Registration failed (${statusCode ?? 'no status'}): $message');
    }
  }

  /// Generic POST method for auth-related endpoints (biometric, forgot-password, etc.)
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return await _apiClient.post(path, data: data);
  }

  Future<void> logout() async {
    final token = _prefs.getString('accessToken');
    if (token != null) {
      try {
        await _apiClient.post(
          ApiConstants.logout,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } catch (_) {}
    }
    await clearToken();
  }

  Future<void> clearToken() async {
    await _prefs.remove('accessToken');
    await _prefs.remove('userId');
    await _prefs.remove('userEmail');
  }

  Future<User?> getCurrentUser() async {
    final userId = _prefs.getString('userId');
    if (userId == null) return null;
    return User(
      id: userId,
      email: _prefs.getString('userEmail') ?? '',
      createdAt: DateTime.now(),
    );
  }

  Future<bool> isLoggedIn() async {
    return _prefs.containsKey('accessToken');
  }
}