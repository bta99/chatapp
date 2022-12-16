import 'package:get/get.dart';

import '../modules/chatRoom/bindings/chat_room_binding.dart';
import '../modules/chatRoom/views/chat_room_view.dart';
import '../modules/createNewGroup/bindings/create_new_group_binding.dart';
import '../modules/createNewGroup/views/create_new_group_view.dart';
import '../modules/groupChat/bindings/group_chat_binding.dart';
import '../modules/groupChat/views/group_chat_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/roomGroupChat/bindings/room_group_chat_binding.dart';
import '../modules/roomGroupChat/views/room_group_chat_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_ROOM,
      page: () => const ChatRoomView(),
      binding: ChatRoomBinding(),
    ),
    GetPage(
      name: _Paths.GROUP_CHAT,
      page: () => const GroupChatView(),
      binding: GroupChatBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_NEW_GROUP,
      page: () => const CreateNewGroupView(),
      binding: CreateNewGroupBinding(),
    ),
    GetPage(
      name: _Paths.ROOM_GROUP_CHAT,
      page: () => const RoomGroupChatView(),
      binding: RoomGroupChatBinding(),
    ),
  ];
}
