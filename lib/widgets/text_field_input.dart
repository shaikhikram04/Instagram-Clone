import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  final void Function()? changePasswordVisibility;
  final bool isPassVisible;

  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.textInputType,
    this.changePasswordVisibility,
    this.isPassVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );
    return TextField(
      controller: textEditingController,
      style: const TextStyle(color: primaryColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[200],
          fontWeight: FontWeight.normal,
        ),
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
        suffixIcon: isPass
            ? IconButton(
                onPressed: changePasswordVisibility,
                icon: Icon(
                  isPassVisible ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
      ),
      keyboardType: textInputType,
      obscureText: !isPassVisible,
    );
  }
}
