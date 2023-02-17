import 'package:chatapp/config/constans.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../controllers/chat_room_controller.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatRoomView extends GetView<ChatRoomController> {
  const ChatRoomView({
    Key? key,
    this.chatRoomId,
    this.user,
  }) : super(key: key);

  final Map<String, dynamic>? user;
  final String? chatRoomId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constans.backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Constans.backgroundColor,
        title: Text(
          Get.arguments[1]['name'],
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
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 15),
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[300]!,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    Get.arguments[1]['name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              StreamBuilder(
                stream: controller.firestore.collection('users').doc(Get.arguments[1]['id']).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Positioned(
                      right: 15,
                      bottom: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: snapshot.data!['status'] == 'Online' ? Colors.greenAccent : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Constans.backgroundColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              )
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              // color: Colors.red,
              child: StreamBuilder<QuerySnapshot>(
                stream: controller.firestore
                    .collection('chatroom')
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
                                    )
                                  : MessageImage(
                                      url: snapshot.data!.docs[index]['message'],
                                      isCurrentUserLogin: snapshot.data!.docs.isNotEmpty
                                          ? snapshot.data!.docs[index]['sendBy'] == controller.userInfo.value.name
                                          : null,
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
                    controller.onSendMessage(
                        Get.arguments[0], controller.userInfo.value.name!, controller.messageController.value.text, Get.arguments[1]);
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

class MessageImage extends StatelessWidget {
  const MessageImage({
    Key? key,
    this.isCurrentUserLogin,
    this.url,
    this.userSend,
    // this.onTap,
  }) : super(key: key);

  final bool? isCurrentUserLogin;
  final String? url;
  final String? userSend;

  // final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isCurrentUserLogin! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        !isCurrentUserLogin! && userSend != null
            ? Padding(
                padding: const EdgeInsets.only(left: 5, top: 5),
                child: Text(
                  userSend ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            : const SizedBox(),
        InkWell(
          onTap: () {
            Get.dialog(
                url == ''
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: Get.width - 100,
                            height: Get.width * 1.2,
                            child: Image.network(
                              url ?? '',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white, boxShadow: const [
                                  BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]),
                                child: const Center(child: Icon(Icons.arrow_back_ios_new)),
                              ),
                            ),
                          ),
                        ],
                      ),
                barrierColor: Colors.black.withOpacity(0.7));
          },
          child: Container(
            margin: EdgeInsets.only(
                left: isCurrentUserLogin! ? Get.width / 1.85 : 5, right: isCurrentUserLogin! ? 5 : Get.width / 1.85, top: 5, bottom: 5),
            height: Get.width / 1.85,
            width: Get.width / 2.5,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: !isCurrentUserLogin! ? Colors.grey[300]!.withOpacity(0.5) : Constans.buttonColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5).copyWith(
                bottomRight: isCurrentUserLogin! ? const Radius.circular(0) : null,
                bottomLeft: !isCurrentUserLogin! ? const Radius.circular(0) : null,
              ),
            ),
            child: url == ''
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Image.network(
                    url ?? '',
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ],
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    Key? key,
    this.message = '',
    this.isCurrentUserLogin = true,
    this.userSend,
  }) : super(key: key);

  final String? message;
  final bool? isCurrentUserLogin;
  final String? userSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: isCurrentUserLogin!
            ? (message!.length / 2 * 10) >= Get.width / 3
                ? Get.width / 3
                : Get.width - (message!.length + Get.width / 3)
            : 5,
        top: 5,
        bottom: 5,
        right: isCurrentUserLogin!
            ? 5
            : (message!.length / 2 * 10) >= Get.width / 3
                ? Get.width / 3
                : Get.width - (message!.length + Get.width / 3),
      ),
      // height: 50,
      // color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          !isCurrentUserLogin! && userSend != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    userSend ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                )
              : const SizedBox(),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: !isCurrentUserLogin! ? Colors.grey[300]!.withOpacity(0.5) : Constans.buttonColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5).copyWith(
                bottomRight: isCurrentUserLogin! ? const Radius.circular(0) : null,
                bottomLeft: !isCurrentUserLogin! ? const Radius.circular(0) : null,
              ),
            ),
            child: Text(
              message ?? '',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
