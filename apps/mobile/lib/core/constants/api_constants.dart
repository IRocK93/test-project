class ApiConstants {
  // Production API host (Railway). Path prefixes (/api/v1, /api) are
  // appended by the individual service files (api_client.dart, api_service.dart,
  // companion_tab.dart) so this stays the bare origin.
  //
  // Override at build time for staging/local dev:
  //   flutter build apk --dart-define=API_BASE_URL=http://10.0.2.2:3000
  //   flutter run --dart-define=API_BASE_URL=https://babymon-api-staging.up.railway.app
  static const String baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://babymon-api-production.up.railway.app');

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';
  static const String googleLogin = '/auth/google';
  static const String appleLogin = '/auth/apple';
  static const String facebookLogin = '/auth/facebook';
  static const String updateLocale = '/users/me/locale';

  // BabyMon endpoints
  static const String babyMons = '/baby-mons';

  // Subscription endpoints
  static const String subscription = '/subscriptions/current';
  static const String validatePromo = '/subscriptions/validate-promo';
  static const String redeemPromo = '/subscriptions/redeem-promo';
  static const String devOverride = '/subscriptions/dev-override-trial';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String selectedBabyMonId = 'selected_baby_mon_id';
  static const String trialOverride = 'trial_override_days';
}

class AppConstants {
  static const int trialDays = 14;
  static const int undoWindowMinutes = 10;
  static const int proposalExpiryDays = 7;
}
