import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/screens/home/comments_screen.dart';
import 'package:instagram_clone/screens/home/profile_screen.dart';
import 'package:instagram_clone/screens/share_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';

class PostCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> snap;
  const PostCard({super.key, required this.snap});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;
  var isFollowing = false;

  @override
  void initState() {
    super.initState();
    checkFollowing();
    getComments();
  }

  Future<void> checkFollowing() async {
    if (!context.mounted) return;

    try {
      final currUserID = FirebaseAuth.instance.currentUser!.uid;
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currUserID)
          .get();

      if (!userSnap.exists || userSnap.data() == null) {
        //! Handle case where user document doesn't exist or has no data
        return;
      }

      if (!mounted) return; // Check again after async call
      setState(() {
        isFollowing =
            userSnap.data()!['following'].contains(widget.snap['uid']);
      });
    } catch (e) {
      return;
    }
  }

  void getComments() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();

      if (mounted) {
        setState(() {
          commentLen = snap.size;
        });
      }
    } catch (e) {
      if (!mounted) return;

      showSnackBar(e.toString(), context);
    }
  }

  void showShareBar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ShareScreen(postId: widget.snap['postId']),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    checkFollowing();
    getComments();

    void navigateToCommentScreen(bool isWriteComment) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CommentsScreen(
          postId: widget.snap['postId'].toString(),
          isWrite: isWriteComment,
        ),
      ));
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                .copyWith(right: 0),
            child: Row(
              children: [
                //* Profile Picture
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(uid: widget.snap['uid']),
                    ));
                  },
                  child: CircleAvatar(
                    backgroundColor: imageBgColor,
                    radius: 20,
                    backgroundImage: NetworkImage(
                      widget.snap['profImage'],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                //* follow button
                if (!isFollowing && user.uid != widget.snap['uid'])
                  ElevatedButton(
                    onPressed: () async {
                      await FirestoreMethod()
                          .followUser(user.uid, widget.snap['uid'], ref);
                      setState(() {
                        isFollowing = !isFollowing;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: primaryColor,
                      backgroundColor: const Color.fromARGB(255, 45, 45, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(width: 10),

                //* delete option
                if (user.uid == widget.snap['uid'])
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () =>
                            FirestoreMethod().deletePost(widget.snap['postId']),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          //* Image section
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethod.likePost(
                  widget.snap['postId'], user.uid, widget.snap['likes'], ref);
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.40,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['postUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  opacity: isLikeAnimating ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //* Like comment section
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    await FirestoreMethod.likePost(widget.snap['postId'],
                        user.uid, widget.snap['likes'], ref);
                  },
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                        ),
                ),
              ),
              IconButton(
                onPressed: () => navigateToCommentScreen(true),
                icon: const Icon(
                  Icons.mode_comment_outlined,
                  color: primaryColor,
                ),
              ),
              IconButton(
                onPressed: showShareBar,
                icon: const Icon(
                  Icons.send,
                  color: primaryColor,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: LikeAnimation(
                    isAnimating:
                        user.savedPosts.contains(widget.snap['postId']),
                    smallLike: true,
                    child: IconButton(
                      onPressed: () {
                        FirestoreMethod.savePost(user.uid,
                            widget.snap['postId'], user.savedPosts, ref);
                      },
                      icon: Icon(
                        user.savedPosts.contains(widget.snap['postId'])
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          //* description & number of comment
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    '${widget.snap['likes'].length} likes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${widget.snap['description']}',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => navigateToCommentScreen(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'view all $commentLen comments',
                      style: const TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(
                      fontSize: 16,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
