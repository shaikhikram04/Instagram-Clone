import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/widgets/post_card.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key, required this.snap});
  final DocumentSnapshot snap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(snap['username']),
      ),
      body: SingleChildScrollView(
        child: PostCard(snap: snap),
      ),
    );
  }
}
