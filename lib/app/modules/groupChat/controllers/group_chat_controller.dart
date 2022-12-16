import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../helper/localStorage.dart';
import '../../../../models/user.dart';

class GroupChatController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Rx<UserModels> userInfo = UserModels().obs;

  @override
  void onInit() {
    super.onInit();
    if (LocalStorage.instance.getString('userInfo')!.isNotEmpty) {
      userInfo.value = UserModels.fromJson(json.decode(LocalStorage.instance.getString('userInfo')!));
    } else {
      userInfo.value = UserModels(id: '', name: '', email: '');
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
}
