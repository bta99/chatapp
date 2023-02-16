import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rxdart/subjects.dart';

import '../app/routes/app_pages.dart';

class NotificationService {
  static final notification = FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();
  static Future initNotification({bool? scheduled = false}) async {
    AndroidInitializationSettings initAndroidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings iosInitializationSettings = const IOSInitializationSettings();
    final settings = InitializationSettings(android: initAndroidSettings, iOS: iosInitializationSettings);
    return notification.initialize(settings, onSelectNotification: (String? payload) {
      Map<String, dynamic> user = jsonDecode(payload!.split('-')[1]);
      String roomId = payload.split('-')[0];
      Get.toNamed(Routes.CHAT_ROOM, arguments: [roomId, user]);

      onNotification.add(payload);
    });
  }

  static Future showNotification({int? id, String? title, String? body, String? payload}) async {
    return notification.show(id!, title, body, await notificationDetails(), payload: payload);
  }

  static notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'default_notification_channel_id', 'High Importance Notifications',
        enableLights: true,
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ticker: 'ticker',
        playSound: true,
        // sound: RawResourceAndroidNotificationSound("notification")
        // channelDescription: 'description',
        // maxProgress: 1,
      ),
      iOS: IOSNotificationDetails(),
    );
  }
}
