import 'dart:convert';

import 'package:chatapp/Widgets/user_chat_widget.dart';
import 'package:chatapp/config/constans.dart';
import 'package:chatapp/helper/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../helper/localStorage.dart';
import '../../../../models/user.dart';

class CreateNewGroupController extends GetxController {
  RxMap<String, dynamic> user = <String, dynamic>{}.obs;
  Rx<UserModels> userInfo = UserModels().obs;
  Rx<TextEditingController> searchController = TextEditingController().obs;
  Rx<TextEditingController> groupNameController = TextEditingController().obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxList<Map<String, dynamic>> listMembers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (LocalStorage.instance.getString('userInfo')!.isNotEmpty) {
      userInfo.value = UserModels.fromJson(json.decode(LocalStorage.instance.getString('userInfo')!));
    } else {
      userInfo.value = UserModels(id: '', name: '', email: '');
    }
    listMembers.add({
      'id': userInfo.value.id,
      'name': userInfo.value.name,
      'email': userInfo.value.email,
      'isAdmin': true,
    });
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

  void addMember() {
    bool onReady = false;
    for (Map<String, dynamic> item in listMembers) {
      if (item['id'] == user['id']) {
        onReady = true;
      }
    }
    if (!onReady) {
      listMembers.add(Map.from({
        ...user,
        'isAdmin': false,
      }));
    }
    searchController.value.clear();
    user.value = {};
  }

  void deleteMember(Map<String, dynamic> data) {
    listMembers.value = listMembers.where((item) => item['id'] != data['id']).toList();
    if (listMembers.isEmpty) {
      Get.back();
    }
  }

  void showMember() async {
    Get.dialog(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Constans.backgroundColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            width: 200,
            height: 300,
            child: Scaffold(
              backgroundColor: Constans.backgroundColor,
              body: Obx(() => ListView(
                    children: [
                      const Center(
                        child: Text(
                          'Danh sách thành viên',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ...List.generate(
                        listMembers.length,
                        (index) => StreamBuilder(
                          stream: firestore.collection('users').doc(listMembers[index]['id']).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              return UserChatWidget(
                                onTap: () {
                                  listMembers[index]['id'] == userInfo.value.id
                                      ? Get.snackbar('Thông báo', 'Bạn là chủ phòng')
                                      : deleteMember(listMembers[index]);
                                },
                                name: listMembers[index]['name'],
                                message: listMembers[index]['email'],
                                status: snapshot.data!['status'],
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> createGroupChat() async {
    Helper.showLoading();
    String groupId = const Uuid().v1();
    await firestore.collection('groups').doc(groupId).set({
      'members': listMembers,
      'id': groupId,
    });

    for (Map<String, dynamic> item in listMembers) {
      String uid = item['id'];
      await firestore.collection('users').doc(uid).collection('groups').doc(groupId).set({
        'name': groupNameController.value.text,
        'id': groupId,
      });
    }
    Helper.hideLoading();
    searchController.value.clear();
    groupNameController.value.clear();
    listMembers.clear();

    Get.back();
  }
}
