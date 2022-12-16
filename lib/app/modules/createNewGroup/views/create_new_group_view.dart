import 'package:chatapp/config/constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../../../../Widgets/textfield_custom.dart';
import '../../../../Widgets/user_chat_widget.dart';
import '../controllers/create_new_group_controller.dart';

class CreateNewGroupView extends GetView<CreateNewGroupController> {
  const CreateNewGroupView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constans.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Nhóm mới',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Constans.backgroundColor,
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
                controller.showMember();
              },
              child: Obx(() => Text(
                    '${controller.listMembers.length} user',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: () {
                if (controller.groupNameController.value.text.trim().isNotEmpty) {
                  controller.createGroupChat();
                } else {
                  Get.showSnackbar(
                    const GetSnackBar(
                      title: 'Thông báo',
                      message: 'Vui lòng nhập tên Nhóm',
                      duration: Duration(milliseconds: 1500),
                      backgroundColor: Constans.buttonColor,
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Constans.buttonColor,
                ),
                padding: const EdgeInsets.all(5),
                child: const Center(
                  child: Text('Bắt đầu'),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFieldCustom(
              controller: controller.groupNameController.value,
              labelColor: Constans.buttonColor,
              label: 'Tên nhóm',
              hint: 'điền tên nhóm của bạn...',
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10, top: 5),
            child: Text(
              'Thêm thành viên nhóm',
              style: TextStyle(
                color: Colors.white,
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
              horizontal: 10,
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
            child: SizedBox(
              // color: Colors.red,
              child: ListView(
                children: [
                  Obx(() => controller.user.isNotEmpty
                      ? StreamBuilder(
                          stream: controller.firestore.collection('users').doc(controller.user['id']).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              return UserChatWidget(
                                onTap: () {
                                  controller.addMember();
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
