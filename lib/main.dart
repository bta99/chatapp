import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/helper/localStorage.dart';
import 'package:chatapp/service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/routes/app_pages.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  NotificationService.showNotification(
      id: 1,
      title: '${message.data['user']['name']} đã nhắn tin cho bạn',
      body: message.data['content'],
      payload: '${message.data['roomId']}-${message.data['user']}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalStorage.init();
  await NotificationService.initNotification();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  NotificationSettings settings = await firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  String? token = await firebaseMessaging.getToken(
    vapidKey:
        "AAAAUJP2IA4:APA91bFND4paBK1ZbKes998gSOm2xpeLDClQuvsq9ag9ko0Dy4ZQcOCXfYtS7VG3pPCxFXDxU_fm7qsJE7J3XyIhsG1gGadashUETu2s5RVj-qCHo65FoankU0d3KmWWivTQh7S98rAv",
  );

  print(token);

  print(settings.authorizationStatus);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }

    NotificationService.showNotification(
        id: 0,
        title: '${message.data['user']['name']} đã nhắn tin cho bạn',
        body: message.data['content'],
        payload: '${message.data['roomId']}-${message.data['user']}');
  });

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   print('when opened app');
  // });

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        fontFamily: GoogleFonts.questrial().fontFamily,
      ),
    ),
  );
}
