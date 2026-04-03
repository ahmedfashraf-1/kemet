import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kemet/core/routing/routes.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM background message received: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _topicName = 'test';
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'Used for important push notifications while app is in foreground.';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isInitialized = false;

  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey}) async {
    if (_isInitialized) return;
    _navigatorKey = navigatorKey;

    await _initializeLocalNotifications();
    await _requestPermissions();
    await _configureForegroundPresentation();
    await _logAndSubscribe();
    _wireMessageListeners();

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Notification permission status: ${settings.authorizationStatus}');

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationPayload(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(channel);
  }

  Future<void> _configureForegroundPresentation() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _logAndSubscribe() async {
    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');

    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed: $newToken');
    });

    await _messaging.subscribeToTopic(_topicName);
    debugPrint('Subscribed to topic: $_topicName');
  }

  void _wireMessageListeners() {
    FirebaseMessaging.onMessage.listen((message) async {
      await _showForegroundLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_navigateFromRemoteMessage);

    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _navigateFromRemoteMessage(message);
      }
    });
  }

  Future<void> _showForegroundLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? 'New Notification';
    final body = notification.body ?? '';

    final payload = jsonEncode({
      'route': message.data['route'] ?? Routes.HomeScreen,
      'title': title,
      'body': body,
    });

    await _localNotifications.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  void _navigateFromRemoteMessage(RemoteMessage message) {
    final route = _asNullableString(message.data['route']) ?? Routes.HomeScreen;
    _pushRoute(
      route,
      arguments: {
        'title':
            message.notification?.title ?? _asNullableString(message.data['title']),
        'body':
            message.notification?.body ?? _asNullableString(message.data['body']),
      },
    );
  }

  void _handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      _pushRoute(Routes.HomeScreen);
      return;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        final route = decoded['route'] as String? ?? Routes.HomeScreen;
        _pushRoute(
          route,
          arguments: {
            'title': decoded['title'] as String?,
            'body': decoded['body'] as String?,
          },
        );
        return;
      }
    } catch (_) {
      // Fallback to a safe route if payload is malformed.
    }

    _pushRoute(Routes.HomeScreen);
  }

  void _pushRoute(String route, {Object? arguments}) {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;
    navigator.pushNamed(route, arguments: arguments);
  }

  String? _asNullableString(Object? value) {
    if (value == null) return null;
    return value.toString();
  }
}

@pragma('vm:entry-point')
void _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  // Handled by Firebase on app open; keep entry-point for background tap safety.
}
