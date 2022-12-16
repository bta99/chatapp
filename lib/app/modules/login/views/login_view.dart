import 'package:chatapp/app/modules/login/views/register_view.dart';
import 'package:chatapp/config/constans.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Widgets/button_custom.dart';
import '../../../../Widgets/textfield_custom.dart';
import '../../../routes/app_pages.dart';
import '../controllers/login_controller.dart';
// import 'package:flutter/foundation.dart' as foundation;

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  Widget spacer({double? h, double? w}) => SizedBox(
        height: h ?? 10,
        width: w ?? 0,
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Constans.buttonColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Đăng Nhập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                spacer(),
                TextFieldCustom(
                  controller: controller.emailController.value,
                  label: 'Tên đăng nhập 😶',
                  hint: 'điền tên đăng nhập',
                ),
                spacer(),
                TextFieldCustom(
                  controller: controller.passwordController.value,
                  isPassword: true,
                  label: 'Mật khẩu 🔑',
                  hint: 'điền mật khẩu',
                ),
                spacer(h: 20),
                ButtonCustom(
                  onTap: () {
                    controller.login();
                  },
                  title: 'Đăng nhập',
                ),
                spacer(),
                InkWell(
                  onTap: () {
                    controller.nameController.value.clear();
                    controller.emailController.value.clear();
                    controller.passwordController.value.clear();
                    Get.to(const RegisterView());
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: const Text(
                      'Đăng ký tài khoản 🤗',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
