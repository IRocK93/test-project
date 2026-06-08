import 'package:dio/dio.dart';
import '../services/api_service.dart';

/// API Client wrapper for making HTTP requests
class ApiClient {
  final ApiService _apiService;

  ApiClient(this._apiService);

  Dio get dio => _apiService.dio;

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _apiService.dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _apiService.dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _apiService.dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _apiService.dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _apiService.dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Save auth tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _apiService.saveTokens(accessToken, refreshToken);
  }

  /// Clear auth tokens
  Future<void> clearTokens() async {
    await _apiService.clearTokens();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _apiService.isLoggedIn();
  }
}