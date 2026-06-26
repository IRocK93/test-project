import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dio interceptor that injects the `Accept-Language` header based on the
/// user's saved locale preference.
///
/// Falls back to `'en'` if no locale is saved. The value is read from
/// SharedPreferences key `'user_locale'` on every request so locale
/// changes take effect immediately without restarting the app.
///
/// Usage:
/// ```dart
/// dio.interceptors.add(LocaleInterceptor());
/// ```
class LocaleInterceptor extends Interceptor {
  static const _localeKey = 'user_locale';
  static const _fallbackLocale = 'en';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString(_localeKey) ?? _fallbackLocale;
    options.headers['Accept-Language'] = locale;
    return handler.next(options);
  }
}
