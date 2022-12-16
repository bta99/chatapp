import 'package:flutter/material.dart';

class TextFieldCustom extends StatelessWidget {
  const TextFieldCustom({
    Key? key,
    this.label,
    this.hint,
    this.keyboardType,
    this.isPassword = false,
    this.controller,
    this.onChanged,
    this.labelColor,
  }) : super(key: key);

  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool isPassword;
  final TextEditingController? controller;
  final ValueChanged? onChanged;
  final Color? labelColor;
  @override
  Widget build(BuildContext context) {
    bool showPass = isPassword;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? '',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          height: 40,
          child: StatefulBuilder(
            builder: (context, setState) {
              return TextField(
                onChanged: onChanged,
                controller: controller,
                style: const TextStyle(
                  fontSize: 12,
                ),
                obscureText: showPass,
                textInputAction: TextInputAction.next,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  suffixIcon: isPassword
                      ? InkWell(
                          onTap: () {
                            setState(() => showPass = !showPass);
                          },
                          child: const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: hint ?? '',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  border: const OutlineInputBorder(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
