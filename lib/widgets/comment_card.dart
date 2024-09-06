import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> snap;
  final String postId;
  final String userId;
  const CommentCard(
      {super.key,
      required this.snap,
      required this.postId,
      required this.userId});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* profile picture
          CircleAvatar(
            backgroundImage: NetworkImage(
              widget.snap['profPicture'],
            ),
            radius: 18,
          ),
          //* data
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //* username + commentText
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: '   ${widget.snap['text']}'),
                      ],
                    ),
                  ),
                  //* date
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(widget.snap['date'].toDate()),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //* like button
          Container(
            margin: const EdgeInsets.only(left: 20, top: 5),
            child: Column(
              children: [
                LikeAnimation(
                  isAnimating: widget.snap['likes'].contains(widget.userId),
                  smallLike: true,
                  child: InkWell(
                    onTap: () async {
                      await FirestoreMethod().likeComment(
                        widget.postId,
                        widget.snap['id'],
                        widget.userId,
                        widget.snap['likes'],
                      );
                    },
                    child: widget.snap['likes'].contains(widget.userId)
                        ? const Icon(
                            Icons.favorite,
                            size: 17,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.favorite_border,
                            size: 17,
                          ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(widget.snap['likes'].length == 0
                    ? ''
                    : widget.snap['likes'].length.toString())
              ],
            ),
          )
        ],
      ),
    );
  }
}
