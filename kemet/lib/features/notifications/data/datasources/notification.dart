import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════
// Background handler — لازم يكون top-level function
// (مش جوا class) عشان FCM يقدر يشغلها لما الـ app مقفول
// ══════════════════════════════════════════
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // مش محتاجين نعمل حاجة هنا 
  // FCM بيعرض الـ system notification أوتوماتيك
  debugPrint('Background notification: ${message.notification?.title}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;


  GlobalKey<NavigatorState>? navigatorKey;

  
  Future<void> initialize({required GlobalKey<NavigatorState> key}) async {
    


// ✅ بنشترك في الـ topic بس لو الـ user مفعّلها
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('push_notifications') ?? true;
      if (enabled) {
        await _fcm.subscribeToTopic('all');
      }

    navigatorKey = key;

    // 1 Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2 permission from  user
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');


    await _saveToken();


    

final pushEnabled = prefs.getBool('settings_push_notifications') ?? true;

if (pushEnabled) {
  await _fcm.subscribeToTopic('all');
} else {
  await _fcm.unsubscribeFromTopic('all');
}

    _fcm.onTokenRefresh.listen(_updateToken);


    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

  
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {

      await Future.delayed(const Duration(seconds: 1));
      _handleNotificationTap(initialMessage);
    }
  }


  // حفظ الـ FCM token في Firebase
  
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

      debugPrint(' FCM token saved: $token');
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  Future<void> _updateToken(String token) async {
    await _saveToken();
  }

  // ══════════════════════════════════════════
  // Foreground — الـ app شغال ومفتوح
  // FCM مش بيعمل system notification تلقائي هنا
  // إحنا بنعرضها كـ SnackBar
  // ══════════════════════════════════════════
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    debugPrint(' Foreground notification: ${notification.title}');

    final context = navigatorKey?.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A0E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFC9A84C),
            width: 0.5,
          ),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Color(0xFFC9A84C),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.title != null)
                    Text(
                      notification.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (notification.body != null)
                    Text(
                      notification.body!,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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


  // Notification tap — background أو terminated
  
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.notification?.title}');
    _navigateToDetails(message);
  }

  
  // Navigate إلى NotificationDetailsScreen

  void _navigateToDetails(RemoteMessage message) {
    navigatorKey?.currentState?.pushNamed(
      Routes.notificationDetails,
      arguments: {
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
      },
    );
  }
}