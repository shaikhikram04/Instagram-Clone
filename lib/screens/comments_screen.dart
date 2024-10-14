import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/comment_card.dart';
import 'package:instagram_clone/widgets/no_data_found.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  final String postUserId;
  final bool isWrite;
  const CommentsScreen({
    super.key,
    required this.postId,
    required this.postUserId,
    this.isWrite = false,
  });

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.isWrite) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          _focusNode.requestFocus();
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _focusNode.dispose();
  }

  void _comment(User user) async {
    String commentText = controller.text;

    if (commentText.trim().isEmpty) return;

    try {
      await FirestoreMethod.commentToPost(
        widget.postId,
        widget.postUserId,
        commentText,
        user.uid,
        user.username,
        user.photoUrl,
      );

      setState(() {
        controller.clear();
      });
    } catch (e) {
      if (!mounted) return;
      showSnackBar('Something goes wrong, try again...', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const NoDataFound(title: 'Comments');
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) => CommentCard(
              snap: snapshot.data!.docs[index].data(),
              postId: widget.postId,
              userId: user.uid,
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          //* toolbar height of appBar
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              //* profile image
              CircleAvatar(
                backgroundColor: imageBgColor,
                backgroundImage: NetworkImage(user.photoUrl),
                radius: 18,
              ),
              //* comment text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user.username}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              //* Post button
              InkWell(
                onTap: () => _comment(user),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
