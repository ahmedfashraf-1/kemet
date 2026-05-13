// datasources (local_notification_datasource)
// Goal: display notification on phone only

import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kemet/features/notifications/data/datasources/remote_notification.dart';
import 'package:kemet/features/notifications/presentation/screens/landmark_notification.dart';
import 'package:kemet/features/notifications/presentation/screens/fav_notification.dart';
import 'package:kemet/features/notifications/presentation/screens/welcome_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {

// 1 init

  // Singleton Pattern ---> 1 obj on all project ,akeed plugin w7da ps l kolo msh kul page plugin
  LocalNotificationService._();
  static final LocalNotificationService instance =
      LocalNotificationService._();

  //creat plugin from package , talk android and ios 
  final _plugin = FlutterLocalNotificationsPlugin();

  // Id for each not. ++
  static const int _welcomeId = 1;
  static const int _landmarkId = 2;
  static const int _favoriteId = 3;
  static const int _reviewId = 4; 


  // for check permission with shared preference
  static const String _pushKey = 'settings_push_notifications';

  // callback ---> presentation layer handles navigation
  void Function(String title, String body)? onNotificationTap;

  // initialization:
  // 1- notification system
  // 2- create channel
  Future<void> initialize({
    void Function(String title, String body)? onTap,
  }) async {
    onNotificationTap = onTap;

    // icon in not.
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    // initialize ONCE only with the tap handler
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // android need channel for each not.
    await _createChannel();
  }


 // os -> flutter sent response
  void _onNotificationTap(NotificationResponse response) {
  final parts = (response.payload ?? '').split('||');
  final title = parts.isNotEmpty ? parts[0] : '';
  final body = parts.length > 1 ? parts[1] : '';
  debugPrint('🔔 onNotificationTap callback: $onNotificationTap');
  onNotificationTap?.call(title, body);
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
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
  }

  // in setting ---> push_not. !!
  Future<bool> _isPushEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushKey) ?? true;  }

  // 1. Welcome Notification
  Future<void> showWelcomeNotification({required String userName , required String userId,}) async {
    if (!await _isPushEnabled()) return;

    const title = 'eh eldoniaa , excited ?!! 🤩🔥🔥';
    const body = 'ya pasha garp w htd3elii 😉';

    final details =
    WelcomeNotificationUI.build(
      userName: userName,
    );

    await _plugin.show(
      _welcomeId,
      '✦ Welcome to KEMET!',
      'Discover Egypt\'s timeless landmarks. 🏛',
      details,
      payload: '$title||$body',
    );

    
      await RemoteNotificationDatasource.instance
    .saveLocalNotificationToFirestore(
      userId: userId,
      title: title,
      body: body,
    );



  }


  // 2. Landmark Viewed Notification
  Future<void> showLandmarkViewedNotification({
    required String landmarkName,
    required String city
  }) async {
    if (!await _isPushEnabled()) return;

    final title = 'el $landmarkName kanet helwa?🤩';
    const body = 'a2al haga 3ndna 😎';

    await Future.delayed(const Duration(seconds: 30));

    final details =
    LandmarkNotificationUI.build(
      landmarkName: landmarkName,
      city: city,
    );

    await _plugin.show(
      _landmarkId,
      'How was $landmarkName? ⭐',
      'Leave a review and help other explorers!',
      details,
      payload: '$title||$body',
    );
    final userId = FirebaseAuth.instance.currentUser?.uid;
if (userId == null) return;
    await RemoteNotificationDatasource.instance
    .saveLocalNotificationToFirestore(
      userId: userId,
      title: title,
      body: body,
    );
  }




     

Future<void> showFavoriteNotification({
  required bool added,
  required String userId,
}) async {
  if (!await _isPushEnabled()) return;

  final title = added ? 'Saved to Favorites! ❤️.' : 'Removed from Favorites 💔';
  final body  = added ? 'You can find it anytime in your list✨.' : 'atgr7t 💔💔';

  final details = ReviewNotificationUI.build();
  await _plugin.show(
    _favoriteId,
    title,
    body,
    details,
    payload: '$title||$body',
  );

  await RemoteNotificationDatasource.instance
      .saveLocalNotificationToFirestore(
    userId: userId,
    title: title,
    body: body,
  );
}

     



Future<void> showReviewNotification({required bool added}) async {
  if (!await _isPushEnabled()) return;

  final title = added ? 'Review submitted!🎉✨' : 'Review Deleted 🗑️';
  final body  = added ? 'rgolaaa 😎🔥': 'leeh tayp !! ';

 final details = ReviewNotificationUI.build();

  await _plugin.show(
    _reviewId,
    title,
    body,
    details,
    payload: '$title||$body',
  );

}

}
