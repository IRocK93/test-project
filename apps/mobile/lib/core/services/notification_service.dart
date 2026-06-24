import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:baby_mon/core/data/api_client.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  ApiClient? _apiClient;
  String? _userId;

  /// Initialize notification service with API client for token registration.
  Future<void> initialize({ApiClient? apiClient, String? userId}) async {
    _apiClient = apiClient;
    _userId = userId;

    await _requestPermissions();
    await _initializeLocalNotifications();

    final token = await getFCMToken();
    if (token != null && _apiClient != null && _userId != null) {
      await _sendTokenToBackend(token);
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      if (_apiClient != null && _userId != null) {
        _sendTokenToBackend(token);
      }
    });

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen for notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true, badge: true, sound: true, provisional: false,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Payload contains navigation data from the push notification
  }

  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (message.notification != null) {
      await _showLocalNotification(message);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'babymon_channel', 'BabyMon Notifications',
      channelDescription: 'Notifications from BabyMon app',
      importance: Importance.high, priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'BabyMon',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Navigation handled by app router via payload data
  }

  Future<void> _sendTokenToBackend(String token) async {
    if (_apiClient == null || _userId == null) return;
    try {
      await _apiClient!.post('/notifications/register-device', data: {
        'deviceToken': token,
        'platform': 'android',
      });
    } catch (_) {
      // Token registration is best-effort; don't crash the app
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
