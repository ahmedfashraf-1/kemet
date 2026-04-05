 import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/core/utils/services/notification_service.dart';
import 'package:kemet/features/notifications/data/datasources/local_notification.dart';
import 'package:kemet/features/profile/presentation/di/profile_di.dart';
import 'package:kemet/kemet_app.dart';
import 'package:shared_preferences/shared_preferences.dart';


// دالة استقبال الرسائل في الخلفية
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Handling a background message: ${message.messageId}');
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);


  setupProfileDi();
  final navigatorKey = GlobalKey<NavigatorState>();
  // initialize  FCM
  await NotificationService.instance.initialize(navigatorKey: navigatorKey);
  
// ysma7lii a3mel navi. mn para el app 
await LocalNotificationService.instance.initialize(key: navigatorKey);
   //Local notifications
  //await LocalNotificationService.instance.initialize();
 
  

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    KemetApp(
      appRouter: AppRouter(),
      sharedPreferences: sharedPrefs,
      navigatorKey: navigatorKey,
    ),
  );
}