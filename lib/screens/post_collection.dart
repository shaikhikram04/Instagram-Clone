import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/widgets/no_data_found.dart';
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
          : NoDataFound(title: title)
    );
  }
}
