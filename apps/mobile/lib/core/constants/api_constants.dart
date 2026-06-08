class ApiConstants {
  // Updated for Android emulator to reach host machine's localhost
  static const String baseUrl = 'http://10.0.2.2:3000'; 
  // static const String baseUrl = 'http://localhost:3000'; // Web/Desktop testing

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';

  // BabyMon endpoints
  static const String babyMons = '/baby-mons';

  // Subscription endpoints
  static const String subscription = '/subscriptions/current';
  static const String devOverride = '/subscriptions/dev-override-trial';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String selectedBabyMonId = 'selected_baby_mon_id';
  static const String trialOverride = 'trial_override_days';
}

class AppConstants {
  static const int trialDays = 14;
  static const int undoWindowMinutes = 10;
  static const int proposalExpiryDays = 7;
}
