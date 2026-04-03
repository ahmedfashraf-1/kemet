 import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/core/utils/services/notification_service.dart';
import 'package:kemet/features/profile/presentation/di/profile_di.dart';
import 'package:kemet/kemet_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:kemet/core/routing/app_router.dart';
// import 'package:kemet/features/profile/presentation/di/profile_di.dart';
// import 'package:kemet/kemet_app.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
  

//   setupProfileDi();
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   print("🔥 Firebase Connected Successfully");

//   final sharedPrefs = await SharedPreferences.getInstance();

//   runApp(
//     KemetApp(
//       appRouter: AppRouter(),
//       sharedPreferences: sharedPrefs,
//     ),
//   );
// }




void main() async {


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final navigatorKey = GlobalKey<NavigatorState>();
  await NotificationService.instance.initialize(navigatorKey: navigatorKey);


  // ✅ بعد Firebase
  setupProfileDi();

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    KemetApp(
      appRouter: AppRouter(),
      sharedPreferences: sharedPrefs,
      navigatorKey: navigatorKey,
    ),
  );
}
}