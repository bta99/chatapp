// ignore_for_file: invalid_use_of_protected_member, avoid_print

import 'package:chatapp/service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

class MyFirebaseService {
  MyFirebaseService();

  Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await NotificationService.initNotification();
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // getDeviceFirebaseToken();
    FirebaseMessaging.onMessage.listen((message) {
      print('sadasd00');
      Map<String, dynamic>? notification = message.data;

      if (message.data.isNotEmpty) {
        NotificationService.showNotification(
          id: 1,
          title: '${notification['user']} đã nhắn tin cho bạn',
          // title: "test",
          body: notification['content'],
          // payload: '${message.data['roomId']}-${message.data['user']}'
        );
      }
    });
  }

  // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   print("Handling a background message");
  // }

  // static Future<String?> getDeviceFirebaseToken() async {
  //   print('lấy token');
  //   final token = await FirebaseMessaging.instance.getToken();
  //   debugPrint('TOKEN DEVICE: $token');
  //   return token;
  // }

  // void _onMessage() {
  //   //dang mo app ma` notify den' thi` se` goi` den` ham` nay`
  //   FirebaseMessaging.onMessage.listen((message) {
  //     print('on Message');
  //   });

  //   FirebaseMessaging.onBackgroundMessage((message) async {
  //     print('ádas');
  //   });
  // }
}
