import 'package:chatapp/app/modules/login/controllers/login_controller.dart';
import 'package:chatapp/config/constans.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../Widgets/button_custom.dart';
import '../../../../Widgets/textfield_custom.dart';

class RegisterView extends GetView<LoginController> {
  const RegisterView({Key? key}) : super(key: key);
  Widget spacer({double? h, double? w}) => SizedBox(
        height: h ?? 10,
        width: w ?? 0,
      );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                color: Constans.buttonColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Đăng ký tài khoản',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    spacer(),
                    TextFieldCustom(
                      controller: controller.nameController.value,
                      label: 'Họ tên',
                      hint: 'điền họ tên',
                    ),
                    spacer(),
                    TextFieldCustom(
                      controller: controller.emailController.value,
                      label: 'Tên đăng nhập ( example@gmail.com ) 😶',
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
                        controller.register();
                      },
                      title: 'Đăng ký',
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 5,
              top: 15,
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300]!,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
