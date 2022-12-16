import 'dart:convert';

import 'package:chatapp/config/constans.dart';
import 'package:chatapp/helper/localStorage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../../../../Widgets/user_chat_widget.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import 'package:http/http.dart' as http;

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constans.backgroundColor,
      appBar: AppBar(
        title: const Text('Danh sách bạn bè'),
        backgroundColor: Constans.backgroundColor,
        elevation: 0.0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text(
                    'Logout 🖐️',
                    style: TextStyle(
                      color: Constans.buttonColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    controller.logout();
                  },
                ),
              ];
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[300]!,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Obx(() => Text(
                      controller.userInfo.value.email![0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                      ),
                    )),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            padding: const EdgeInsets.symmetric(vertical: 1),
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.grey[300]!,
                      fontSize: 13,
                    ),
                    controller: controller.searchController.value,
                    onChanged: (value) {
                      controller.onSearch();
                    },
                    decoration: InputDecoration(
                      hintText: 'tìm kiếm bạn bè của bạn...',
                      hintStyle: TextStyle(
                        color: Colors.grey[300]!,
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 39,
                  height: 39,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Constans.buttonColor,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/search.svg',
                      width: 15,
                      height: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  Obx(() => controller.user.isNotEmpty
                      ? StreamBuilder(
                          stream: controller.firestore.collection('users').doc(controller.user['id']).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              return UserChatWidget(
                                onTap: () {
                                  String roomId = controller.chatRoomId(controller.userInfo.value.name!, controller.user['name']);
                                  print(roomId);
                                  print(controller.user);
                                  controller.historySearch.add(controller.user['email']);
                                  controller.historySearch.value = controller.historySearch.toSet().toList();
                                  LocalStorage.instance.setToken('historySearch', json.encode(controller.historySearch));
                                  Get.toNamed(Routes.CHAT_ROOM, arguments: [roomId, controller.user]);
                                },
                                name: controller.user['name'],
                                message: controller.user['email'],
                                status: snapshot.data!['status'],
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        )
                      : const SizedBox()),
                  const Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'Lịch sử tìm kiếm',
                      style: TextStyle(
                        color: Constans.buttonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Obx(() => Column(
                          children: [
                            ...List.generate(
                              controller.historySearch.length,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                child: InkWell(
                                  onTap: () {
                                    controller.searchController.value.text = controller.historySearch.toList()[index].toLowerCase().trim();
                                    controller.onSearch();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.historySearch.toList()[index],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.historySearch.remove(controller.historySearch.toList()[index]);
                                          LocalStorage.instance.setToken('historySearch', json.encode(controller.historySearch.toSet().toList()));
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 17,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          // Get.toNamed(Routes.GROUP_CHAT);
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
                  'priority': 'high',
                  'data': <String, dynamic>{
                    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                    'id': '1',
                    'status': 'done',
                    'title': 'Tin nhắn mới',
                    'roomId': 'haha',
                    'user': 'Hello world',
                  },
                  "to":
                      'cxPiagt3QSavo1k5wWQpA_:APA91bEzMjd89G1l1qIUGrbUxwFGGRZpbpH4DmzAFhd1kbtSakgA0BjRdXQDeBY9wXZvbD3IxdVHvdQPWHl0cU_Z1hwcsD8pyo1BCnOpVmiCNAjSApCRs9F34gbKoUC-c5czx1XFPJbu',
                },
              ),
            );
            print('done');
          } catch (e) {
            print("error push notification");
          }
        },
        backgroundColor: Constans.buttonColor,
        child: const Icon(Icons.group_outlined),
      ),
    );
  }
}


//phần này hiển thị toàn bộ người dùng app
// Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               child: StreamBuilder(
//                 stream: controller.firestore.collection('users').snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.data != null) {
//                     print(snapshot.data!.docs.length);
//                     return ListView(
//                       children: [
//                         ...List.generate(
//                           snapshot.data!.docs.length,
//                           (index) {
//                             print(snapshot.data!.docs[0]['name']);
//                             return StreamBuilder(
//                               stream: controller.firestore.collection('users').doc(snapshot.data!.docs[index]['id']).snapshots(),
//                               builder: (context, snapshot2) {
//                                 if (snapshot2.data != null) {
//                                   return snapshot.data!.docs[index]['id'] == controller.userInfo.value.id
//                                       ? const SizedBox()
//                                       : UserChatWidget(
//                                           onTap: () {
//                                             String roomId =
//                                                 controller.chatRoomId(controller.userInfo.value.name!, snapshot.data!.docs[index]['name']);
//                                             Get.toNamed(Routes.CHAT_ROOM, arguments: [roomId, snapshot.data!.docs[index]]);
//                                           },
//                                           name: snapshot.data!.docs[index]['name'],
//                                           message: snapshot.data!.docs[index]['email'],
//                                           status: snapshot2.data!['status'],
//                                         );
//                                 } else {
//                                   return const SizedBox();
//                                 }
//                               },
//                             );
//                           },
//                         ),
//                       ],
//                     );
//                   } else {
//                     return const SizedBox();
//                   }
//                 },
//               ),
//             ),
//           )