import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReviewNotificationUI {

  static NotificationDetails build() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'kemet_channel',
        'Kemet Notifications',
        channelDescription: 'Notifications from Kemet app',

        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,

        icon: '@mipmap/ic_launcher',
        color: Color(0xFFD4AF37),
      ),
    );
  }
}