import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/core/utils/services/alarm_callback.dart';
import 'package:kemet/core/utils/services/notification_service.dart';
import 'package:kemet/features/notifications/data/datasources/Local_notification.dart';
import 'package:kemet/features/payment/presentation/di/payment_di.dart';
import 'package:kemet/features/order/presentation/di/order_di.dart';
import 'package:kemet/features/profile/presentation/di/profile_di.dart';
import 'package:kemet/core/network/network_info.dart';
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

  // Register NetworkInfo globally
 final getIt = GetIt.instance;

getIt.registerSingleton<NetworkInfo>(
  NetworkInfoImpl(
    InternetConnectionChecker.instance,
  ),
);

  setupProfileDi();
  // Payment DI: register Paymob client, repository, usecases and cubit
  try {
    setupPaymentDi();
  } catch (_) {
    // Ignore DI errors at startup — they will be surfaced when opening payment UI
  }
  // Order DI: register order datasource, repository, usecases and cubit
  try {
    setupOrderDi();
  } catch (_) {
    // Ignore DI errors at startup — they will be surfaced when opening checkout
  }
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
