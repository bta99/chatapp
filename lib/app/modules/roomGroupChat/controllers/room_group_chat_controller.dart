import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../helper/localStorage.dart';
import '../../../../models/user.dart';

class RoomGroupChatController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Rx<UserModels> userInfo = UserModels().obs;
  Rx<TextEditingController> messageController = TextEditingController().obs;
  late Rx<ScrollController> scrollController;
  late CollectionReference reference;
  RxBool showEmojiKeyboard = true.obs;
  RxBool isScroll = false.obs;
  Rx<File>? fileImage = File('').obs;
  @override
  void onInit() {
    super.onInit();
    userInfo.value = UserModels.fromJson(json.decode(LocalStorage.instance.getString('userInfo')!));
    reference = firestore.collection('groups').doc(Get.arguments[0]).collection('chats');
    scrollController = ScrollController().obs;
    // Future.delayed(
    //     const Duration(
    //       seconds: 1,
    //     ), () {
    //   scrollController.value.jumpTo(scrollController.value.position.maxScrollExtent);
    // });
  }

  @override
  void onReady() {
    super.onReady();
    try {
      reference.snapshots().listen((event) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (isScroll.value) {
            scrollController.value
                .animateTo(scrollController.value.position.maxScrollExtent, curve: Curves.easeInOut, duration: const Duration(milliseconds: 100));
            // Get.snackbar('Thông báo', 'Tin nhắn mới');
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void onClose() {
    scrollController.value.dispose();
    super.onClose();
  }

  Future<void> onSendMessage(String chatRoomId, String userSend, String message) async {
    if (message.trim().isNotEmpty) {
      await firestore.collection('groups').doc(chatRoomId).collection('chats').add({
        'sendBy': userSend,
        'message': message,
        'type': 'text',
        'time': FieldValue.serverTimestamp(),
      });
      // scrollController.value
      //     .animateTo(scrollController.value.position.maxScrollExtent, curve: Curves.easeInOut, duration: const Duration(milliseconds: 100));
      messageController.value.clear();
    } else {
      print('vui lòng nhập nội dung tin nhắn');
    }
  }

  Future<void> getImage() async {
    ImagePicker imagePicker = ImagePicker();
    await imagePicker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        fileImage!.value = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future<void> uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;
    firestore.collection('groups').doc(Get.arguments[0]).collection('chats').doc(fileName).set({
      'sendBy': userInfo.value.name,
      'message': '',
      'type': 'image',
      'time': FieldValue.serverTimestamp(),
    });
    var ref = FirebaseStorage.instance.ref().child('images').child('$fileName.jpg');

    var uploadTask = await ref.putFile(fileImage!.value).catchError(() async {
      await firestore.collection('groups').doc(Get.arguments[0]).collection('chats').doc(fileName).delete();
      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await firestore.collection('groups').doc(Get.arguments[0]).collection('chats').doc(fileName).update({
        'message': imageUrl,
      });
      print(imageUrl);
    }
  }
}
