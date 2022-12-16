import 'package:flutter/material.dart';

import '../config/constans.dart';

class UserChatWidget extends StatelessWidget {
  const UserChatWidget({
    Key? key,
    this.name = 'R',
    this.message,
    this.avatar,
    this.onTap,
    this.status,
  }) : super(key: key);

  final String? name;
  final String? message;
  final String? avatar;
  final String? status;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
      leading: Stack(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.grey[300]!,
              shape: BoxShape.circle,
              border: Border.all(
                color: Constans.buttonColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                name![0],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: status == 'Online' ? Colors.greenAccent : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Constans.backgroundColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        name ?? '',
        maxLines: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Text(
        message ?? '',
        maxLines: 1,
        style: TextStyle(
          color: Colors.grey[400]!,
          fontSize: 13,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
