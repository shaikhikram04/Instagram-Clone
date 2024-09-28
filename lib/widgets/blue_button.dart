import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class BlueButton extends StatelessWidget {
  const BlueButton({
    super.key,
    this.isLoading = false,
    required this.onTap,
    required this.label,
  });

  final bool isLoading;
  final String label;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: blueColor,
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: primaryColor,
              ))
            : Text(
                label,
                style: const TextStyle(
                    fontSize: 17,
                    color: primaryColor,
                    fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
