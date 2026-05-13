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

import 'package:kemet/core/routing/routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp();
  await dotenv.load(fileName: '.env');
  await AndroidAlarmManager.initialize();

  setupProfileDi();


// await LocalNotificationService.instance.initialize(
//   onTap: (title, body) {
//     debugPrint('🔔 navigatorKey state: ${navigatorKey.currentState}');
//     navigatorKey.currentState?.pushNamed(
//       Routes.notificationDetails,
//       arguments: {'title': title, 'body': body ,  'docId': null,},
//     );
//   },
// );


  // Local notifications
await LocalNotificationService.instance.initialize(
  onTap: (title, body) {
    debugPrint('🔔 PUSHING ROUTE: ${Routes.notificationDetails}');
    debugPrint('🔔 title: $title, body: $body');
    final result = navigatorKey.currentState?.pushNamed(
      Routes.notificationDetails,
      arguments: {'title': title, 'body': body},
    );
    debugPrint('🔔 push result: $result');
  },
);


  // FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.instance.initialize(navigatorKey: navigatorKey);
  
  await AndroidAlarmManager.cancel(0);
  final isAlarmScheduled = await AndroidAlarmManager.periodic(
    const Duration(hours: 24), 
    0,
    fireReEngagementNotification,
    wakeup: false,  
    exact: false,    
    rescheduleOnReboot: true,
  );
  debugPrint('Re-engagement alarm scheduled: $isAlarmScheduled');

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    KemetApp(
      appRouter: AppRouter(),
      sharedPreferences: sharedPrefs,
      navigatorKey: navigatorKey, 
    ),
  );
}
