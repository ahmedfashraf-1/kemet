import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance =
      LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const int _welcomeId  = 1;
  static const int _landmarkId = 2;
  static const int _reengagementId = 42;

  static const String _pushKey = 'settings_push_notifications';
  static const String _reengagementChannelId = 'kemet_reengagement';

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
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
    const reengagementChannel = AndroidNotificationChannel(
      _reengagementChannelId,
      'Kemet Reminders',
      description: 'Periodic reminders to explore Egypt',
      importance: Importance.high,
      playSound: true,
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.createNotificationChannel(reengagementChannel);
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
        'kemet_channel',
        'Kemet Notifications',
        channelDescription: 'Notifications from Kemet app',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFD4AF37),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          'Discover Egypt\'s timeless landmarks, hidden gems, and ancient wonders. 🏛',
          contentTitle: '✦ Welcome to KEMET, $userName!',
          summaryText: 'Start exploring',
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

  Future<void> scheduleReEngagementNotification() async {
    if (!await _isPushEnabled()) return;

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return;

    const messages = [
      '𓂀 The pharaohs are waiting... Come explore Egypt\'s wonders',
      '✦ New hidden gems discovered in Luxor. Don\'t miss out',
      '𓂀 Your Egyptian journey awaits — pick up where you left off',
      '✦ Kemet misses you. Come discover ancient secrets',
      '𓂀 The Nile is calling... Your next adventure is waiting',
      '✦ Ancient mysteries await you in Kemet',
    ];
    final message = messages[Random().nextInt(messages.length)];

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _reengagementChannelId,
        'Kemet Reminders',
        channelDescription: 'Periodic reminders to explore Egypt',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFD4AF37),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          message,
          contentTitle: '𓂀 Kemet Awaits',
          summaryText: 'Tap to continue your journey',
        ),
      ),
    );

    await _plugin.cancel(_reengagementId);
    await _plugin.periodicallyShow(
      _reengagementId,
      '𓂀 Kemet Awaits',
      message,
      RepeatInterval.daily,
      details,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> cancelReEngagementNotification() async {
    await _plugin.cancel(_reengagementId);
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
}