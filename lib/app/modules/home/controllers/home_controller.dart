import 'dart:convert';

import 'package:chatapp/app/modules/login/controllers/login_controller.dart';
import 'package:chatapp/helper/localStorage.dart';
import 'package:chatapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  Rx<TextEditingController> searchController = TextEditingController().obs;
  RxMap<String, dynamic> user = <String, dynamic>{}.obs;
  Rx<UserModels> userInfo = UserModels().obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxList<String> historySearch = <String>[].obs;
  @override
  void onInit() {
    super.onInit();

    if (LocalStorage.instance.getString('userInfo')!.isNotEmpty) {
      userInfo.value = UserModels.fromJson(json.decode(LocalStorage.instance.getString('userInfo')!));
    } else {
      userInfo.value = UserModels(id: '', name: '', email: '');
    }
    // print('${LocalStorage.instance.getString('userInfo')!.isEmpty}');
    WidgetsBinding.instance.addObserver(this);
    setStatus('Online');
    historySearch.value = List<String>.from(json.decode(LocalStorage.instance.getString('historySearch') ?? '[]'));
  }

  void setStatus(String status) async {
    await firestore.collection('users').doc(userInfo.value.id).update({
      'status': status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus('Online');
    } else {
      setStatus('Offline');
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> onSearch() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('users').where('email', isEqualTo: searchController.value.text).get().then((value) {
        if (value.docs[0].data()['email'] != userInfo.value.email) {
          user.value = value.docs[0].data();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1.codeUnits.fold<int>(0, (a, b) => a + b) > user2.codeUnits.fold<int>(0, (a, b) => a + b)) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void logout() async {
    // try {
    //   // await auth.signOut();
    // Get.put(LoginController());
    await FirebaseMessaging.instance.deleteToken();
    await LocalStorage.instance.store.remove('userInfo');
    Get.offAndToNamed(Routes.LOGIN);
    // } catch (e) {
    //   print(e);
    // }
    // Get.find<LoginController>();
  }

  sendMessage(String body, String title, String token) async {}
}
