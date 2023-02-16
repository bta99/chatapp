import 'dart:convert';

import 'package:chatapp/firebase_service.dart';
import 'package:chatapp/helper/localStorage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../helper/helper.dart';
import '../../../../models/user.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final count = 0.obs;
  Rx<TextEditingController> nameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() async {
    await MyFirebaseService().initialize();
  }

  @override
  void onReady() {
    super.onReady();
    LocalStorage.instance.getString('userInfo') != null ? Get.offAllNamed(Routes.HOME) : null;
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }

  Future<void> register() async {
    Helper.showLoading();
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      User? user = (await auth.createUserWithEmailAndPassword(email: emailController.value.text, password: passwordController.value.text)).user;
      Helper.hideLoading();
      if (user != null) {
        user.updateDisplayName(nameController.value.text);
        String? notificationToken = await FirebaseMessaging.instance.getToken(
            vapidKey:
                'AAAAUJP2IA4:APA91bFND4paBK1ZbKes998gSOm2xpeLDClQuvsq9ag9ko0Dy4ZQcOCXfYtS7VG3pPCxFXDxU_fm7qsJE7J3XyIhsG1gGadashUETu2s5RVj-qCHo65FoankU0d3KmWWivTQh7S98rAv');
        await firestore.collection('users').doc(auth.currentUser!.uid).set({
          'name': nameController.value.text,
          'email': emailController.value.text,
          'status': 'Unavalible',
          'id': auth.currentUser!.uid,
          'tokenNotification': notificationToken,
        });
        print('Tài khoản đã được tạo!');
        Get.back();
      } else {
        print('tạo tài khoản không thành công!');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> login() async {
    Helper.showLoading();
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      User? user = (await auth.signInWithEmailAndPassword(email: emailController.value.text, password: passwordController.value.text)).user;
      Helper.hideLoading();
      String? notificationToken = await FirebaseMessaging.instance.getToken();
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'tokenNotification': notificationToken,
      });
      if (user != null) {
        print('đăng nhập thành công!');
        print(user);
        UserModels userModels = UserModels(
          id: user.uid,
          name: user.displayName,
          email: user.email,
        );
        print(jsonEncode(userModels));
        await LocalStorage.instance.setToken('userInfo', jsonEncode(userModels));
        Get.offAllNamed(Routes.HOME);
      } else {
        print('đăng nhập thất bại!');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
