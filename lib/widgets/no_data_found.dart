import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Image.asset(
            'assets/images/Insta_NTF.png',
            height: 225,
          ),
          const SizedBox(height: 20),
          Text(
            'No $title yet!',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
