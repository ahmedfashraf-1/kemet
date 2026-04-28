import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Must be top-level function for android_alarm_manager_plus
@pragma('vm:entry-point')
Future<void> fireReEngagementNotification() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();
  print('🔥 ALARM TRIGGERED');

  // 1. Check if user is logged in
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  if (!isLoggedIn) return;

  // 2. Get saved user id
  final userId = prefs.getString('current_user_id');
  if (userId == null) return;

  // 3. Pick a random message
  const messages = [
    '𓂀 The pharaohs are waiting... Come explore Egypt\'s wonders',
    '✦ New hidden gems discovered in Luxor. Don\'t miss out',
    '𓂀 Your Egyptian journey awaits — pick up where you left off',
    '✦ Kemet misses you. Come discover ancient secrets',
    '𓂀 The Nile is calling... Your next adventure is waiting',
    '✦ Ancient mysteries await you in Kemet',
  ];
  final message = messages[Random().nextInt(messages.length)];

  // 4. Show local notification
  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await plugin.initialize(initSettings);

  const channel = AndroidNotificationChannel(
    'kemet_reengagement',
    'Kemet Reminders',
    description: 'Periodic reminders to explore Egypt',
    importance: Importance.high,
  );
  final androidImplementation = plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidImplementation?.createNotificationChannel(channel);

  final androidDetails = AndroidNotificationDetails(
    'kemet_reengagement',
    'Kemet Reminders',
    channelDescription: 'Periodic reminders to explore Egypt',
    importance: Importance.high,
    priority: Priority.high,
    color: const Color(0xFFD4AF37),
    playSound: true,
    enableVibration: true,
    styleInformation: BigTextStyleInformation(
      message,
      contentTitle: '𓂀 Kemet Awaits',
      summaryText: 'Tap to continue your journey',
    ),
    largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  );

  await plugin.show(
    42,
    '𓂀 Kemet Awaits',
    message,
    NotificationDetails(android: androidDetails),
  );

  // 5. Save to Firestore so it appears in the in-app notifications screen
  try {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': '𓂀 Kemet Awaits',
      'body': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (_) {
    // silently fail — local notification already shown
  }
}
