import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/chat_profile_screen.dart';
import 'package:instagram_clone/widgets/type_new_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    this.isNewChat = false,
    required this.username,
    required this.photoUrl, required this.uid,
  });

  final bool isNewChat;
  final String uid;
  final String username;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ChatProfileScreen(),
          )),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              photoUrl,
            ),
          ),
          title: Text(
            username,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: Container()),
          TypeNewMessage(
            isNewChat: isNewChat,
            username: username,
            uid: uid,
            photoUrl: photoUrl,
          ),
        ],
      ),
    );
  }
}
