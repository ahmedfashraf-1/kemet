import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/core/utils/services/alarm_callback.dart';
import 'package:kemet/core/utils/services/notification_service.dart';
import 'package:kemet/features/notifications/data/datasources/Local_notification.dart';
import 'package:kemet/features/profile/presentation/di/profile_di.dart';
import 'package:kemet/kemet_app.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(' Handling a background message: ${message.messageId}');
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);


  setupProfileDi();
  final navigatorKey = GlobalKey<NavigatorState>();
  // initialize  FCM
  await NotificationService.instance.initialize(navigatorKey: navigatorKey);
   // Local notifications
  await LocalNotificationService.instance.initialize(key: navigatorKey); 

  // Schedule re-engagement alarm every 1 minute for test validation.
  await AndroidAlarmManager.cancel(0);
  final isAlarmScheduled = await AndroidAlarmManager.periodic(
    const Duration(minutes: 1),
    0,
    fireReEngagementNotification,
    wakeup: true,
    exact: true,
    rescheduleOnReboot: true,
  );
  debugPrint('Re-engagement periodic alarm scheduled: $isAlarmScheduled');
  

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    KemetApp(
      appRouter: AppRouter(),
      sharedPreferences: sharedPrefs,
      navigatorKey: navigatorKey,
    ),
  );
}