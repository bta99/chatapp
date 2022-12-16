import 'package:get/get.dart';

import '../controllers/room_group_chat_controller.dart';

class RoomGroupChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomGroupChatController>(
      () => RoomGroupChatController(),
    );
  }
}
