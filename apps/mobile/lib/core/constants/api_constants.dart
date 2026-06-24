class ApiConstants {
  // Updated for Android emulator to reach host machine's localhost
  static const String baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000');

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';
  static const String googleLogin = '/auth/google';
  static const String appleLogin = '/auth/apple';
  static const String facebookLogin = '/auth/facebook';

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
