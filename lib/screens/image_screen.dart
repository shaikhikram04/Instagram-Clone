import 'package:flutter/material.dart';

class Imagescreen extends StatelessWidget {
  const Imagescreen({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1.0,
          maxScale: 5.0,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
