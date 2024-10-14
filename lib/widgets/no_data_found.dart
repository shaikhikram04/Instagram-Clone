import 'package:flutter/material.dart';

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
        children: [
          const SizedBox(height: 12),
          Image.asset(
            'assets/images/Insta_NTF.png',
            height: 250,
          ),
          const SizedBox(height: 20),
          Text(
            'No $title yet!',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
        ],
      ),
    );
  }
}
