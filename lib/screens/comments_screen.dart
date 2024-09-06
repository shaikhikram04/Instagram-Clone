import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/comment_card.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final controller = TextEditingController();
  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _comment(User user) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await FirestoreMethod().commentToPost(
        widget.postId,
        controller.text,
        user.uid,
        user.username,
        user.photoUrl,
      );

      setState(() {
        _isLoading = false;
        controller.clear();
      });
    } catch (e) {
      if (!mounted) return;
      showSnackBar('Something goes wrong try again...', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Comments'),
      ),
      body: const CommentCard(),
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
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user.username}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _comment(user),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.blueAccent,
                        )
                      : const Text(
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
