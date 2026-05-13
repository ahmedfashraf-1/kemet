// datasources (remote_notification_datasource)
// Goals:
// 1- Background notifications
// 2- Foreground notifications
// 3- save fcm token in firestore
// 4- tap on not.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' as doc;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// background
// top_level ---> msh gowa el class 34an el app y3raf y48alo f el background ^ terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  // display only — saving to firestore happens when user opens the app
  // (onMessageOpenedApp or getInitialMessage)
}

class RemoteNotificationDatasource {
  RemoteNotificationDatasource._();
  static final RemoteNotificationDatasource instance =
      RemoteNotificationDatasource._();

  final _fcm      = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _auth     = FirebaseAuth.instance;

  static const String _pushKey = 'settings_push_notifications';

  // callbacks ---> presentation layer handles navigation & snackbar
  void Function(RemoteMessage message)? onForegroundMessage;
  void Function(RemoteMessage message)? onMessageTap;

  Future<void> initialize({
    void Function(RemoteMessage)? onForeground,
    void Function(RemoteMessage)? onTap,
  }) async {
    onForegroundMessage = onForeground;
    onMessageTap        = onTap;

    // must first
    // connect fcm with Background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // permission from user, only ios & android>=13
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    await _saveToken();

    final prefs = await SharedPreferences.getInstance();
    final pushEnabled = prefs.getBool(_pushKey) ?? true;
    if (pushEnabled) {
      await _fcm.subscribeToTopic('all');
    } else {
      await _fcm.unsubscribeFromTopic('all');
    }

    _fcm.onTokenRefresh.listen((_) => _saveToken());

    // pressed on not. f el foreground
    FirebaseMessaging.onMessage.listen((message) {
      saveToFirestore(message);
      onForegroundMessage?.call(message);
   });

    // pressed on not. f el background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      saveToFirestore(message);
      onMessageTap?.call(message);
    });

    // pressed on not. "terminate"
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      await Future.delayed(const Duration(seconds: 1));
      saveToFirestore(initialMessage);
      onMessageTap?.call(initialMessage);
    }
  }

  Future<void> _saveToken() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;
      final token = await _fcm.getToken();
      if (token == null) return;
      await _firestore
          .collection('users')
          .doc(userId)
          .set({'fcmToken': token}, SetOptions(merge: true));
      debugPrint('✅ FCM token saved');
    } catch (e) {
      debugPrint('❌ Token save failed: $e');
    }
  }

  Future<void> saveToFirestore(RemoteMessage message) async {
    final msgId  = message.messageId;
    final userId = _auth.currentUser?.uid;
    if (userId == null || msgId == null) return;

    // duplicate check
    final existing = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('messageId', isEqualTo: msgId)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _firestore.collection('notifications').add({
      'userId':    userId,
      'messageId': msgId,
      'title':     message.notification?.title ?? '',
      'body':      message.notification?.body  ?? '',
      'isRead':    false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Notification saved with docId: ${doc.id}'); // ✅
  }

  // used by LocalNotificationDatasource welcome/landmark flows
  Future<void> saveLocalNotificationToFirestore({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId':    userId,
        'title':     title,
        'body':      body,
        'isRead':    false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Notification saved');
    } catch (e) {
      debugPrint('❌ Failed: $e');
    }

    debugPrint('✅ Notification saved with docId: ${doc.id}'); // ✅
  }

  void _navigateToDetails(RemoteMessage message) {
  debugPrint('🔔 _navigateToDetails called');
  debugPrint('🔔 navigatorKey: $navigatorKey');
  debugPrint('🔔 currentState: ${navigatorKey?.currentState}');
  
  navigatorKey?.currentState?.pushNamed(
    Routes.notificationDetails,
    arguments: {
      'docId': null,
      'title': message.notification?.title ?? '',
      'body':  message.notification?.body  ?? '',
    },
  );
}
}