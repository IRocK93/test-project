import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/data/api_client.dart';
import '../../domain/entities/user.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/json_utils.dart';

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
        final user = User.fromJson(parseJsonMap(response.data['user']) ?? {});
        final token = parseString(response.data['accessToken']) ?? '';
        final refreshToken = parseString(response.data['refreshToken']) ?? '';
        await _prefs.setString('accessToken', token);
        await _prefs.setString('userId', user.id);
        await _prefs.setString('userEmail', user.email);
        await _apiClient.saveTokens(token, refreshToken ?? '', user.id);
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
    required DateTime dateOfBirth,
    required bool tosAccepted,
    required bool privacyAccepted,
    required bool consentToDataProcessing,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'tosAccepted': tosAccepted,
          'privacyAccepted': privacyAccepted,
          'consentToDataProcessing': consentToDataProcessing,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          final user = User.fromJson(parseJsonMap(response.data['user']) ?? {});
          final token = parseString(response.data['accessToken']) ?? '';
          final refreshToken = parseString(response.data['refreshToken']) ?? '';
          await _prefs.setString('accessToken', token);
          await _prefs.setString('userId', user.id);
          await _prefs.setString('userEmail', user.email);
          await _apiClient.saveTokens(token, refreshToken ?? '', user.id);
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
      } catch (e) { 
        // ignore: avoid_print
        print('Logout API call failed (non-critical): $e'); 
      }
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

  Future<({User user, String token})> googleLogin(String idToken) async {
    final res = await _apiClient.post(ApiConstants.googleLogin, data: {'idToken': idToken, 'provider': 'google'});
    final data = res.data as Map<String, dynamic>;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String?;
    if (refreshToken != null) {
      await _prefs.setString('refreshToken', refreshToken);
    }
    await _prefs.setString('accessToken', token);
    await _prefs.setString('userId', user.id);
    await _prefs.setString('userEmail', user.email);
    await _apiClient.saveTokens(token, refreshToken ?? '', user.id);
    return (user: user, token: token);
  }

  Future<({User user, String token})> appleLogin(String idToken) async {
    final res = await _apiClient.post(ApiConstants.appleLogin, data: {'idToken': idToken, 'provider': 'apple'});
    final data = res.data as Map<String, dynamic>;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String?;
    if (refreshToken != null) {
      await _prefs.setString('refreshToken', refreshToken);
    }
    await _prefs.setString('accessToken', token);
    await _prefs.setString('userId', user.id);
    await _prefs.setString('userEmail', user.email);
    await _apiClient.saveTokens(token, refreshToken ?? '', user.id);
    return (user: user, token: token);
  }

  Future<({User user, String token})> facebookLogin(String accessToken) async {
    final res = await _apiClient.post(ApiConstants.facebookLogin, data: {'idToken': accessToken, 'provider': 'facebook'});
    final data = res.data as Map<String, dynamic>;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String?;
    if (refreshToken != null) {
      await _prefs.setString('refreshToken', refreshToken);
    }
    await _prefs.setString('accessToken', token);
    await _prefs.setString('userId', user.id);
    await _prefs.setString('userEmail', user.email);
    await _apiClient.saveTokens(token, refreshToken ?? '', user.id);
    return (user: user, token: token);
  }
}
