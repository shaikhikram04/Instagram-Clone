import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_clone/screens/image_screen.dart';
import 'package:instagram_clone/screens/post_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.profileImageUrl,
    required this.username,
    required this.messageType,
    this.message,
    required this.isMe,
    this.imageUrl,
    this.postSnap,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.messageType,
    this.message,
    required this.isMe,
    this.imageUrl,
    this.postSnap,
  })  : isFirstInSequence = false,
        username = null,
        profileImageUrl = null;

  final String? profileImageUrl;
  final String? username;
  final String messageType;
  final String? message;
  final bool isMe;
  final bool isFirstInSequence;
  final String? imageUrl;
  final Map<String, dynamic>? postSnap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (profileImageUrl != null)
          Positioned(
            top: 15,
            right: isMe ? 0 : null,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: imageBgColor,
              backgroundImage: NetworkImage(
                profileImageUrl!,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (isFirstInSequence) const SizedBox(height: 18),
                  // if (username != null)
                  //   Padding(
                  //     padding: const EdgeInsets.symmetric(horizontal: 13),
                  //     child: Text(
                  //       username!,
                  //       style: const TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  Container(
                    decoration: BoxDecoration(
                      color: messageType == 'text'
                          ? isMe
                              ? Colors.deepPurple[700]
                              : Colors.grey[850]
                          : null,
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(20),
                        topRight: isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(20),
                        bottomLeft: const Radius.circular(20),
                        bottomRight: const Radius.circular(20),
                      ),
                    ),
                    constraints: const BoxConstraints(maxWidth: 250),
                    padding: EdgeInsets.symmetric(
                      vertical: messageType == 'text' ? 12 : 2,
                      horizontal: messageType == 'text' ? 14 : 2,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 1.5,
                      horizontal: 12,
                    ),
                    child: messageType == 'text'
                        ? Text(
                            message!,
                            style: GoogleFonts.openSans(
                              height: 1.5,
                              fontSize: 18,
                              color: primaryColor,
                            ),
                            softWrap: true,
                          )
                        : messageType == 'image'
                            ? getImageBubble(context)
                            : getPostBubble(context),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget getImageBubble(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Imagescreen(imageUrl: imageUrl!),
          ));
        },
        child: Image.network(
          imageUrl!,
          height: 270,
          width: 250,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget getPostBubble(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PostScreen(snap: postSnap!),
      )),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMe
                ? [
                    Colors.deepPurple,
                    const Color.fromARGB(255, 59, 25, 118),
                    const Color.fromARGB(255, 40, 14, 85),
                    const Color.fromARGB(255, 26, 7, 59),
                  ]
                : [
                    const Color.fromARGB(255, 89, 93, 95),
                    const Color.fromARGB(255, 82, 86, 87),
                    const Color.fromARGB(255, 59, 62, 62),
                    const Color.fromRGBO(48, 48, 48, 1),
                  ],
            begin: isMe ? Alignment.bottomRight : Alignment.topRight,
            end: isMe ? Alignment.topLeft : Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: imageBgColor,
                backgroundImage: NetworkImage(postSnap!['profImage']),
                radius: 21,
              ),
              title: Text(
                postSnap!['username'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Image.network(
              postSnap!['postUrl'],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: postSnap!['username'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '  ${postSnap!['description']}')
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
