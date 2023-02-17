import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../helper/localStorage.dart';
import '../../../../models/user.dart';
import 'package:http/http.dart' as http;

class ChatRoomController extends GetxController {
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
    reference = firestore.collection('chatroom').doc(Get.arguments[0]).collection('chats');
    scrollController = ScrollController().obs;
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

  Future<void> onSendMessage(String chatRoomId, String userSend, String message, Map<String, dynamic> user) async {
    if (message.trim().isNotEmpty) {
      await firestore.collection('chatroom').doc(chatRoomId).collection('chats').add({
        'sendBy': userSend,
        'message': message,
        'type': 'text',
        'time': FieldValue.serverTimestamp(),
      });
      // scrollController.value
      //     .animateTo(scrollController.value.position.maxScrollExtent, curve: Curves.easeInOut, duration: const Duration(milliseconds: 100));
      messageController.value.clear();
      sendNotifi(chatRoomId, user, user['tokenNotification'], message);
    } else {
      print('vui lòng nhập nội dung tin nhắn');
    }
  }

  void sendNotifi(String roomId, Map<String, dynamic> user, String sendTo, String message) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAUJP2IA4:APA91bFND4paBK1ZbKes998gSOm2xpeLDClQuvsq9ag9ko0Dy4ZQcOCXfYtS7VG3pPCxFXDxU_fm7qsJE7J3XyIhsG1gGadashUETu2s5RVj-qCHo65FoankU0d3KmWWivTQh7S98rAv',
        },
        body: jsonEncode(
          <String, dynamic>{
            // 'priority': 'high',
            "data": {
              "body": "Body of Your Notification in Data",
              "title": "Tin nhắn mới",
              "roomId": roomId,
              "content": message,
              "user": userInfo.value.name,
            },
            // "to": sendTo,
            "registration_ids": [sendTo],
            "priority": "high",
            // "notification": {
            //   "image":
            //       "https://images.unsplash.com/photo-1664574653790-cee0e10a4242?ixlib=rb-4.0.3&ixid=MnwxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60"
            // }
          },
        ),
      );
      print('done');
    } catch (e) {
      print("error push notification");
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
    firestore.collection('chatroom').doc(Get.arguments[0]).collection('chats').doc(fileName).set({
      'sendBy': userInfo.value.name,
      'message': '',
      'type': 'image',
      'time': FieldValue.serverTimestamp(),
    });
    var ref = FirebaseStorage.instance.ref().child('images').child('$fileName.jpg');

    var uploadTask = await ref.putFile(fileImage!.value).catchError(() async {
      await firestore.collection('chatroom').doc(Get.arguments[0]).collection('chats').doc(fileName).delete();
      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await firestore.collection('chatroom').doc(Get.arguments[0]).collection('chats').doc(fileName).update({
        'message': imageUrl,
      });
      print(imageUrl);
    }
  }
}
