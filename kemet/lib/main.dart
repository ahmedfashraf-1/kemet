import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/utils/services/alarm_callback.dart';
import 'package:kemet/core/utils/services/notification_service.dart';
import 'package:kemet/features/notifications/data/datasources/Local_notification.dart';
import 'package:kemet/features/payment/presentation/di/payment_di.dart';
import 'package:kemet/features/order/presentation/di/order_di.dart';
import 'package:kemet/features/profile/presentation/di/profile_di.dart';
import 'package:kemet/core/network/network_info.dart';
import 'package:kemet/kemet_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // fcm
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);


  // DI setup
  final getIt = GetIt.instance;
  getIt.registerSingleton<NetworkInfo>(
    NetworkInfoImpl(InternetConnectionChecker.instance),
  );
  setupProfileDi();

  // Payment DI: register Paymob client, repository, usecases and cubit
  try {
    setupPaymentDi();
    debugPrint('Payment DI setup successful');
  } catch (e) {
    debugPrint('Payment DI setup failed: $e');
  }
  // Order DI: register order datasource, repository, usecases and cubit
  try {
    setupOrderDi();
    debugPrint('Order DI setup successful');
  } catch (e) {
    debugPrint('Order DI setup failed: $e');
  }


  // Local notifications
  await LocalNotificationService.instance.initialize(
    onTap: (title, body) {
      debugPrint('🔔 PUSHING ROUTE: ${Routes.notificationDetails}');
      navigatorKey.currentState?.pushNamed(
        Routes.notificationDetails,
        arguments: {'title': title, 'body': body},
      );
    },
  );

  // initialize  FCM
  await NotificationService.instance.initialize(navigatorKey: navigatorKey);


  
  await AndroidAlarmManager.cancel(0);
  final isAlarmScheduled = await AndroidAlarmManager.periodic(
    const Duration(minutes: 1),
    0,
    fireReEngagementNotification,
    wakeup: false,  
    exact: false,    
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
