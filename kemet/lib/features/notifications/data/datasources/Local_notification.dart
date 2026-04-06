import 'dart:ui';
import 'dart:typed_data';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/utils/services/alarm_callback.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance =
      LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const int _welcomeId  = 1;
  static const int _landmarkId = 2;
  static const int _reEngagementAlarmId = 42;

  static const String _pushKey = 'settings_push_notifications';

  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    _navigatorKey = navigatorKey;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _navigatorKey?.currentState?.pushNamed(Routes.notificationsScreen);
      },
    );
    await _createChannel();
  }

  Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      'kemet_channel',
      'Kemet Notifications',
      description: 'Notifications from Kemet app',
      importance: Importance.high,
      playSound: true,
    );
    const welcomeChannel = AndroidNotificationChannel(
      'kemet_welcome',
      'Kemet Welcome',
      description: 'Welcome and important notifications from Kemet',
      importance: Importance.high,
      playSound: true,
    );
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(channel);
    await androidImplementation?.createNotificationChannel(welcomeChannel);
  }

  // in setting
  Future<bool> _isPushEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushKey) ?? true;
  }


  // 1. Welcome Notification
  
  Future<void> showWelcomeNotification({
    required String userName,
    required String userId,
  }) async {
    
    if (!await _isPushEnabled()) return;

    await _saveToFirestore(
      userId: userId,
      title: '✦ Welcome to KEMET!',
      body: 'Discover Egypt\'s timeless landmarks. Your journey starts now. 🏛',
    );

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'kemet_welcome',
        'Kemet Welcome',
        channelDescription: 'Welcome and important notifications from Kemet',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFD4AF37),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        styleInformation: BigTextStyleInformation(
          'Welcome back, $userName 𓂀\nYour Egyptian journey continues...',
          htmlFormatBigText: false,
          contentTitle: '✦ Welcome to KEMET',
          htmlFormatContentTitle: false,
          summaryText: 'Kemet',
          htmlFormatSummaryText: false,
        ),
      ),
    );

    await _plugin.show(
      _welcomeId,
      '✦ Welcome to KEMET!',
      'Discover Egypt\'s timeless landmarks. 🏛',
      details,
    );
  }


  // 2. Landmark Viewed Notification

  Future<void> showLandmarkViewedNotification({
    required String landmarkName,
    required String city,
  }) async {
    await Future.delayed(const Duration(seconds: 30));

  
    if (!await _isPushEnabled()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      await _saveToFirestore(
        userId: userId,
        title: 'How was $landmarkName? ⭐',
        body: 'Leave a review and help other explorers!',
      );
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'kemet_channel',
        'Kemet Notifications',
        channelDescription: 'Notifications from Kemet app',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFD4AF37),
        styleInformation: BigTextStyleInformation(
          'Share your experience with other explorers and help them discover this amazing place.',
          contentTitle: 'How was $landmarkName?',
          summaryText: city,
        ),
      ),
    );

    await _plugin.show(
      _landmarkId,
      'How was $landmarkName? ⭐',
      'Leave a review and help other explorers!',
      details,
    );
  }

  Future<void> _saveToFirestore({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> scheduleReEngagementNotification() async {
    await AndroidAlarmManager.initialize();

    await AndroidAlarmManager.periodic(
      const Duration(minutes: 1),
      _reEngagementAlarmId,
      fireReEngagementNotification,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  Future<void> cancelReEngagementNotification() async {
    await AndroidAlarmManager.cancel(_reEngagementAlarmId);
  }
}