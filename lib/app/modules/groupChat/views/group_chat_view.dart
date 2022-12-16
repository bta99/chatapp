import 'package:chatapp/Widgets/user_chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../../../../config/constans.dart';
import '../../../routes/app_pages.dart';
import '../controllers/group_chat_controller.dart';

class GroupChatView extends GetView<GroupChatController> {
  const GroupChatView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constans.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Phòng Chat của bạn',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Constans.backgroundColor,
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Constans.buttonColor,
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: TextButton(
              onPressed: () {
                Get.toNamed(Routes.CREATE_NEW_GROUP);
              },
              child: const Text(
                'Tạo phòng',
                style: TextStyle(
                  color: Constans.buttonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Container(
          //   alignment: Alignment.center,
          //   decoration: BoxDecoration(
          //     border: Border.all(
          //       color: Colors.white,
          //     ),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   margin: const EdgeInsets.symmetric(
          //     horizontal: 15,
          //   ),
          //   padding: const EdgeInsets.symmetric(vertical: 1),
          //   height: 40,
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: TextField(
          //           style: TextStyle(
          //             color: Colors.grey[300]!,
          //             fontSize: 13,
          //           ),
          //           // controller: controller.searchController.value,
          //           // onChanged: (value) {
          //           //   controller.onSearch();
          //           // },
          //           decoration: InputDecoration(
          //             hintText: 'tìm kiếm group chat của bạn...',
          //             hintStyle: TextStyle(
          //               color: Colors.grey[300]!,
          //               fontSize: 13,
          //             ),
          //             contentPadding: const EdgeInsets.symmetric(horizontal: 5),
          //             border: const OutlineInputBorder(
          //               borderSide: BorderSide(
          //                 color: Colors.transparent,
          //               ),
          //             ),
          //             enabledBorder: const OutlineInputBorder(
          //               borderSide: BorderSide(
          //                 color: Colors.transparent,
          //               ),
          //             ),
          //             focusedBorder: const OutlineInputBorder(
          //               borderSide: BorderSide(
          //                 color: Colors.transparent,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       Container(
          //         width: 39,
          //         height: 39,
          //         decoration: const BoxDecoration(
          //           shape: BoxShape.circle,
          //           color: Constans.buttonColor,
          //         ),
          //         child: Center(
          //           child: SvgPicture.asset(
          //             'assets/images/search.svg',
          //             width: 15,
          //             height: 15,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: StreamBuilder(
                stream: controller.firestore.collection('users').doc(controller.userInfo.value.id).collection('groups').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    print(snapshot.data!.docs.length);
                    return ListView(
                      children: List.generate(
                        snapshot.data!.docs.length,
                        (index) => UserChatWidget(
                          onTap: () {
                            Get.toNamed(Routes.ROOM_GROUP_CHAT, arguments: [snapshot.data!.docs[index]['id'], snapshot.data!.docs[index]['name']]);
                          },
                          name: snapshot.data!.docs[index]['name'],
                          message: 'Nhóm Chat',
                          status: 'Online',
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      // const Center(
      //   child: Text(
      //     'Tạo phòng để trò chuyện với mọi người',
      //     style: TextStyle(fontSize: 16, color: Colors.white),
      //   ),
      // ),
    );
  }
}
