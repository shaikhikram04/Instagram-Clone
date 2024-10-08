import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_clone/screens/chat_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.username,
    required this.imageUrl,
    required this.uid,
    required this.lastMessage,
    required this.time,
    required this.conversationId,
    required this.lastMessageBy,
  })  : isActiveChat = true,
        bio = null;

  const ChatCard.newChat({
    super.key,
    required this.username,
    required this.bio,
    required this.imageUrl,
    required this.uid,
  })  : isActiveChat = false,
        time = null,
        conversationId = null,
        lastMessage = null,
        lastMessageBy = null;

  final bool isActiveChat;
  final String username;
  final String? bio;
  final String imageUrl;
  final String uid;
  final String? lastMessage;
  final String? time;
  final String? conversationId;
  final String? lastMessageBy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isActiveChat) {
          Navigator.of(context).pop();
        }
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => isActiveChat
              ? ChatScreen(
                  username: username,
                  photoUrl: imageUrl,
                  uid: uid,
                  conversationId: conversationId,
                )
              : ChatScreen.newChat(
                  username: username, photoUrl: imageUrl, uid: uid),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: imageBgColor,
                backgroundImage: NetworkImage(
                  imageUrl,
                ),
                radius: 33,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      isActiveChat
                          ? Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '$lastMessageBy : $lastMessage',
                                    style: GoogleFonts.openSans(fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  time!,
                                  style: GoogleFonts.exo2(),
                                ),
                              ],
                            )
                          : Text(
                              bio!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
