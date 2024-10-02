import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/chat_screen.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.isActiveChat,
    required this.username,
    required this.bio,
    required this.imageUrl,
    this.chatId,
    required this.uid,
  });

  final bool isActiveChat;
  final String? chatId;
  final String username;
  final String bio;
  final String imageUrl;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isActiveChat) {
          Navigator.of(context).pop();
        }
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChatScreen(
            username: username,
            photoUrl: imageUrl,
            isNewChat: !isActiveChat,
            uid: uid,
          ),
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
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      isActiveChat
                          ? const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Hii! ',
                                    style: TextStyle(fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text('   25/9/24'),
                              ],
                            )
                          : Text(
                              bio,
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
