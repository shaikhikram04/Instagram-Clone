import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_clone/screens/image_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.profileImageUrl,
    required this.username,
    required this.messageType,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.messageType,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        username = null,
        profileImageUrl = null;

  final String? profileImageUrl;
  final String? username;
  final String messageType;
  final String message;
  final bool isMe;
  final bool isFirstInSequence;

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
              backgroundColor: Colors.grey[900],
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
                      color: isMe ? Colors.deepPurple[700] : Colors.grey[850],
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
                            message,
                            style: GoogleFonts.openSans(
                              height: 1.5,
                              fontSize: 18,
                              color: primaryColor,
                            ),
                            softWrap: true,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      Imagescreen(imageUrl: message),
                                ));
                              },
                              child: Image.network(
                                message,
                                height: 270,
                                width: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
