import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/chat_screen.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.username,
    required this.imageUrl,
    required this.uid,
    required this.lastMessage,
    required this.time,
    required this.conversationId,
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
        lastMessage = null;

  final bool isActiveChat;
  final String username;
  final String? bio;
  final String imageUrl;
  final String uid;
  final String? lastMessage;
  final String? time;
  final String? conversationId;

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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      isActiveChat
                          ? Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lastMessage!,
                                    style: const TextStyle(fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(time!),
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
