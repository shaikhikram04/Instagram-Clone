import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/post_screen.dart';

class PostGrid extends StatelessWidget {
  const PostGrid({
    super.key,
    required this.postList,
    this.scrollcontroller,
  });

  final List<DocumentSnapshot> postList;
  final ScrollController? scrollcontroller;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      controller: scrollcontroller,
      itemCount: postList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 1.5,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PostScreen(
                snap: postList[index],
              ),
            ));
          },
          child: Image.network(
            postList[index]['postUrl'],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
