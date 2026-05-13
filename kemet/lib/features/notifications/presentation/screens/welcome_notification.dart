import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WelcomeNotificationUI {
  static NotificationDetails build({
    required String userName,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'kemet_channel',
        'Kemet Notifications',

        channelDescription: 'Notifications from Kemet app',

        importance: Importance.high,
        priority: Priority.high,

        icon: '@mipmap/ic_launcher',

        color: const Color(0xFFD4AF37),

        largeIcon: const DrawableResourceAndroidBitmap(
          '@mipmap/ic_launcher',
        ),

        styleInformation: BigTextStyleInformation(
          'masr mestanyak... !🔥',

          contentTitle:
              '🤩 wl33 eldoniaaa , $userName!',

          summaryText:
              'Let\'s unlock secrets 😉',
        ),
      ),
    );
  }
}