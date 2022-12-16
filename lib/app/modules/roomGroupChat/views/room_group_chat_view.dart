import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../../../../config/constans.dart';
import '../../chatRoom/views/chat_room_view.dart';
import '../controllers/room_group_chat_controller.dart';
import 'package:flutter/foundation.dart' as foundation;

class RoomGroupChatView extends GetView<RoomGroupChatController> {
  const RoomGroupChatView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constans.backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Constans.backgroundColor,
        title: Text(
          Get.arguments[1],
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Constans.buttonColor,
            )),
        actions: [
          // Stack(
          //   alignment: Alignment.center,
          //   children: [
          //     Container(
          //       margin: const EdgeInsets.only(right: 15),
          //       width: 35,
          //       height: 35,
          //       decoration: BoxDecoration(
          //         color: Colors.grey[300]!,
          //         shape: BoxShape.circle,
          //       ),
          //       child: Center(
          //         child: Text(
          //           Get.arguments[0],
          //           style: const TextStyle(
          //             color: Colors.black,
          //             fontSize: 17,
          //           ),
          //         ),
          //       ),
          //     ),
          //     StreamBuilder(
          //       stream: controller.firestore.collection('users').doc(Get.arguments[1]['id']).snapshots(),
          //       builder: (context, snapshot) {
          //         if (snapshot.data != null) {
          //           return Positioned(
          //             right: 15,
          //             bottom: 10,
          //             child: Container(
          //               width: 10,
          //               height: 10,
          //               decoration: BoxDecoration(
          //                 color: snapshot.data!['status'] == 'Online' ? Colors.greenAccent : Colors.red,
          //                 shape: BoxShape.circle,
          //                 border: Border.all(
          //                   color: Constans.backgroundColor,
          //                   width: 1.5,
          //                 ),
          //               ),
          //             ),
          //           );
          //         } else {
          //           return const SizedBox();
          //         }
          //       },
          //     )
          //   ],
          // ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              // color: Colors.red,
              child: StreamBuilder<QuerySnapshot>(
                stream: controller.firestore
                    .collection('groups')
                    .doc(Get.arguments[0])
                    .collection('chats')
                    .orderBy('time', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Obx(() => ListView(
                          controller: controller.scrollController.value,
                          children: [
                            ...List.generate(
                              snapshot.data!.docs.length,
                              (index) => snapshot.data!.docs[index]['type'] == 'text'
                                  ? MessageWidget(
                                      message: snapshot.data!.docs[index]['message'],
                                      isCurrentUserLogin: snapshot.data!.docs.isNotEmpty
                                          ? snapshot.data!.docs[index]['sendBy'] == controller.userInfo.value.name
                                          : null,
                                      userSend: snapshot.data!.docs[index]['sendBy'],
                                    )
                                  : MessageImage(
                                      url: snapshot.data!.docs[index]['message'],
                                      isCurrentUserLogin: snapshot.data!.docs.isNotEmpty
                                          ? snapshot.data!.docs[index]['sendBy'] == controller.userInfo.value.name
                                          : null,
                                      userSend: snapshot.data!.docs[index]['sendBy'],
                                    ),
                            ),
                          ],
                        ));
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ),
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
                    onTap: () async {
                      controller.scrollController.value.jumpTo(controller.scrollController.value.position.maxScrollExtent);
                      controller.isScroll.value = true;
                      await SystemChannels.textInput.invokeMethod('TextInput.show');
                      controller.showEmojiKeyboard.value = true;
                    },
                    controller: controller.messageController.value,
                    style: TextStyle(
                      color: Colors.grey[300]!,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'nhập tin nhắn...',
                      hintStyle: TextStyle(
                        color: Colors.grey[300]!,
                        fontSize: 13,
                      ),
                      prefixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              await SystemChannels.textInput.invokeMethod('TextInput.hide');
                              controller.showEmojiKeyboard.value = !controller.showEmojiKeyboard.value;
                              if (controller.showEmojiKeyboard.value) {
                                await SystemChannels.textInput.invokeMethod('TextInput.show');
                              }
                            },
                            child: Obx(() => Icon(
                                  Icons.sentiment_satisfied_alt_outlined,
                                  color: controller.showEmojiKeyboard.value ? Colors.grey[300] : Constans.buttonColor,
                                )),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () async {
                              controller.getImage();
                            },
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                        ],
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
                InkWell(
                  onTap: () {
                    controller.onSendMessage(Get.arguments[0], controller.userInfo.value.name!, controller.messageController.value.text);
                  },
                  child: Container(
                    width: 39,
                    height: 39,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Constans.buttonColor,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/send.svg',
                        width: 15,
                        height: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() => controller.showEmojiKeyboard.value
              ? const SizedBox()
              : Expanded(
                  child: Offstage(
                    offstage: controller.showEmojiKeyboard.value,
                    child: SizedBox(
                        // height: 250,
                        child: EmojiPicker(
                      textEditingController: controller.messageController.value,
                      config: Config(
                        columns: 7,
                        // Issue: https://github.com/flutter/flutter/issues/28894
                        emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        gridPadding: EdgeInsets.zero,
                        initCategory: Category.RECENT,
                        bgColor: const Color(0xFFF2F2F2),
                        indicatorColor: Colors.blue,
                        iconColor: Colors.grey,
                        iconColorSelected: Colors.blue,
                        backspaceColor: Colors.blue,
                        skinToneDialogBgColor: Colors.white,
                        skinToneIndicatorColor: Colors.grey,
                        enableSkinTones: true,
                        showRecentsTab: true,
                        recentsLimit: 28,
                        replaceEmojiOnLimitExceed: false,
                        noRecents: const Text(
                          'No Recents',
                          style: TextStyle(fontSize: 20, color: Colors.black26),
                          textAlign: TextAlign.center,
                        ),
                        loadingIndicator: const SizedBox.shrink(),
                        tabIndicatorAnimDuration: kTabScrollDuration,
                        categoryIcons: const CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL,
                        checkPlatformCompatibility: true,
                      ),
                    )),
                  ),
                )),
        ],
      ),
    );
  }
}
