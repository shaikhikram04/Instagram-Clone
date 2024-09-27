import 'package:flutter/material.dart';
import 'package:instagram_clone/widgets/post_card.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key, required this.snap});
  final Map<String, dynamic> snap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(snap['username']),
      ),
      body: SafeArea(child: PostCard(snap: snap)),
    );
  }
}
