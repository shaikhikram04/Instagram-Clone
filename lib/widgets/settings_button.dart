import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Color color;
  final void Function() onTap;
  const SettingsButton({
    super.key,
    required this.text,
    required this.iconData,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      icon: Icon(
        iconData,
        color: color,
        size: 28,
      ),
      label: Text(
        text,
        style: TextStyle(color: color, fontSize: 20),
      ),
    );
  }
}
