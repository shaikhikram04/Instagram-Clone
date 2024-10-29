import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class TextFieldInput extends StatelessWidget {
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  final void Function()? changePasswordVisibility;
  final bool isPassVisible;
  final String keyValue;
  final void Function(String value) onSaved;
  final String? Function(String value) validator;

  const TextFieldInput({
    super.key,
    this.isPass = false,
    required this.hintText,
    required this.textInputType,
    this.changePasswordVisibility,
    this.isPassVisible = true,
    required this.keyValue,
    required this.onSaved,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(
        context,
        color: secondaryColor,
      ),
      borderRadius: BorderRadius.circular(10),
    );
    return TextFormField(
      key: ValueKey(hintText),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Empty value is not accepted';
        }

        return null;
      },
      onSaved: (value) {},
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
