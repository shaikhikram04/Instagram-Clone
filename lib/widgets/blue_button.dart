import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class BlueButton extends StatelessWidget {
  const BlueButton({super.key, required this.isLoading, required this.onTap});

  final bool isLoading;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          color: blueColor,
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: primaryColor,
              ))
            : const Text('Signup'),
      ),
    );
  }
}
