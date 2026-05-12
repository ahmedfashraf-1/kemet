// 2 Goals
// 1- display not. on phone
// 2- save not. on firestore

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Singleton ---> only one instance on app
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance =
      LocalNotificationService._();


  // package ---> display mess. on phone
  final _plugin = FlutterLocalNotificationsPlugin();


  // Id for each not. ++
  // ++ ---> y3nii lama had ydef not. yzwed hna
  static const int _welcomeId  = 1;
  static const int _landmarkId = 2;


   // user pressed on  not. "without ui"
   GlobalKey<NavigatorState>? navigatorKey;

  // prefs.setBool(_pushKey, true); // zay map keda n3rf peha ps howa m48al not. wla laa
  // prefs.getBool(_pushKey); 
  static const String _pushKey = 'settings_push_notifications';



  // initialization :-
  // 1- notification system
  // 2- create channel
  Future<void> initialize({
    required GlobalKey<NavigatorState> key,
  }) async {

    navigatorKey = key;
    // icon in not.
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // all setting in obj. to send plugin
    const initSettings = InitializationSettings(android: androidSettings);
   //await _plugin.initialize(initSettings);
       await _plugin.initialize(
       initSettings,
       onDidReceiveNotificationResponse: _onNotificationTap,
     );

    // android need channel for each not.
    await _createChannel();
  }

  
void _onNotificationTap(NotificationResponse response) {
  final parts = (response.payload ?? '').split('||');
  final title = parts.isNotEmpty ? parts[0] : '';
  final body  = parts.length > 1 ? parts[1] : '';

  Future.delayed(const Duration(milliseconds: 300), () {

    navigatorKey?.currentState?.push(
    MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
    navigatorKey?.currentState?.pushNamed(
      Routes.notificationDetails,
      arguments: {'title': title, 'body': body},
    );
  });
}

  Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      'kemet_channel',
      'Kemet Notifications',
      description: 'Notifications from Kemet app',
      // popup + sound
      importance: Importance.high,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // in setting ---> push_not. !!
  Future<bool> _isPushEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushKey) ?? true;
  }


  // 1. Welcome Notification
  Future<void> showWelcomeNotification({
    required String userName,
    required String userId,
  }) async {
    
    if (!await _isPushEnabled()) return;

    const title = 'eh eldoniaa , excited ?!! 🤩🔥🔥';
    const body  = 'ya pasha garp w htd3elii 😉';

  //  firebase to display---> page not.
    await _saveToFirestore(
      userId: userId,
      title: 'eh eldoniaa , excited ?!! 🤩🔥🔥',
      body: 'ya pasha garp w htd3elii 😉',
    );

    // ui
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'kemet_channel',
        'Kemet Notifications',
        channelDescription: 'Notifications from Kemet app',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFD4AF37),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          'masr mestanyak... !🔥',
          //🏛
          contentTitle: '🤩 wl33 eldoniaaa , $userName!',
          summaryText: 'Let’s unlock secrets 😉',
        ),
      ),
    );

     await _plugin.show(
      _welcomeId,
      '✦ Welcome to KEMET!',
      'Discover Egypt\'s timeless landmarks. 🏛',
      details,
      payload: '$title||$body',
    );
  }


  // 2. Landmark Viewed Notification
  Future<void> showLandmarkViewedNotification({
    required String landmarkName,
    required String city,
  }) async {

    if (!await _isPushEnabled()) return;

    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final title  = 'el $landmarkName kanet helwa?🤩';
    const body   = 'akal haga 3ndna 😎';
 

    await Future.delayed(const Duration(seconds: 30));

  

    if (userId != null) {
      await _saveToFirestore(
        userId: userId,
        title: 'el $landmarkName 3gabtk ?🤩',
        body: ' a2al haga 3ndna 5li palk 😎',
      );
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'kemet_channel',
        'Kemet Notifications',
        channelDescription: 'Notifications from Kemet app',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFD4AF37),
        styleInformation: BigTextStyleInformation(
          'mtp5alsh 3lena p r2yak tyep 😜🔥',
          contentTitle: 'shofnak shoft el $landmarkName?',
          summaryText: city,
        ),
      ),
    );

  await _plugin.show(
      _landmarkId,
      'How was $landmarkName? ⭐',
      'Leave a review and help other explorers!',
      details,
      payload: '$title||$body',
    );
  }

  

Future<void> _saveToFirestore({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Notification saved');
    } catch (e) {
      debugPrint('❌ Failed: $e');
    }
  }
  
}