import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LandmarkNotificationUI {
  static NotificationDetails build({
    required String landmarkName,
    required String city,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'kemet_channel',
        'Kemet Notifications',

        channelDescription:
            'Notifications from Kemet app',

        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,

        icon: '@mipmap/ic_launcher',

        color: const Color(0xFFD4AF37),

        styleInformation: BigTextStyleInformation(
          'mtp5alsh 3lena p r2yak tyep 😜🔥',

          contentTitle:
              'shofnak shoft el $landmarkName?',

          summaryText: city,
        ),
      ),
    );
  }
}