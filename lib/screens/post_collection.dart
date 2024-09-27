import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/post_grid.dart';

class PostCollectionScreen extends ConsumerWidget {
  const PostCollectionScreen(this.postList, this.title, {super.key});
  final String title;
  final List postList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: postList.isNotEmpty
          ? PostGrid(postList: postList)
          : Center(
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
                        fontWeight: FontWeight.bold, fontSize: 21),
                  ),
                ],
              ),
            ),
    );
  }
}
