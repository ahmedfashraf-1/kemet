// 4 Goals :-
// 1- Background notifications
// 2- Foreground notifications
// 3- save fcm token in firestore
// 4- tap on not.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

// background 
// top_level ---> msh gowa el class 34an el app y3raf y48alo f el background ^ terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  
  WidgetsFlutterBinding.ensureInitialized();

  final notification = message.notification;
  if (notification == null) return;

  final plugin = FlutterLocalNotificationsPlugin();

  
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  await plugin.initialize(
    const InitializationSettings(android: androidSettings),
  );

  await plugin.show(
    0,
    notification.title,
    notification.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'kemet_channel',
        'Kemet Notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  GlobalKey<NavigatorState>? navigatorKey;

  Future<void> initialize({required GlobalKey<NavigatorState> key}) async {
    navigatorKey = key;

    // must first
    // connect fcm with Background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);


    // permission from user ,only ios & android>=13
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    await _saveToken();

    
    final prefs = await SharedPreferences.getInstance();
    final pushEnabled = prefs.getBool('settings_push_notifications') ?? true;
    if (pushEnabled) {
      await _fcm.subscribeToTopic('all');
    } else {
      await _fcm.unsubscribeFromTopic('all');
    }

    _fcm.onTokenRefresh.listen((_) => _saveToken());

    // pressed on not. f el foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // pressed on not. f el background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _saveToFirestore(message);
      _navigateToDetails(message);
    });

    // not working
    // pressed on not. "terminate"
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {

      await Future.delayed(const Duration(seconds: 1));
      _saveToFirestore(initialMessage);
      _navigateToDetails(initialMessage);
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
      debugPrint(' FCM token saved');
    } catch (e) {
      debugPrint(' Token save failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _saveToFirestore(message);

    final context = navigatorKey?.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A0E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFC9A84C), width: 0.5),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.notifications_outlined,
                color: Color(0xFFC9A84C), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.title != null)
                    Text(notification.title!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  if (notification.body != null)
                    Text(notification.body!,
                        style: const TextStyle(
                            color: Color(0xFFAAAAAA), fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: const Color(0xFFC9A84C),
          onPressed: () => _navigateToDetails(message),
        ),
      ),
    );
  }

  void _navigateToDetails(RemoteMessage message) {
    navigatorKey?.currentState?.pushNamed(
      Routes.notificationsScreen,
    );
  }


  Future<void> _saveToFirestore(RemoteMessage message) async {
  final msgId = message.messageId;
  final userId = _auth.currentUser?.uid;
  if (userId == null || msgId == null) return;

  final existing = await _firestore
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('messageId', isEqualTo: msgId)
      .get();

  if (existing.docs.isNotEmpty) return; 

  await _firestore.collection('notifications').add({
    'userId': userId,
    'messageId': msgId,
    'title': message.notification?.title ?? '',
    'body': message.notification?.body ?? '',
    'isRead': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
}