import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/chat_profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/chat_messages.dart';
import 'package:instagram_clone/widgets/type_new_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.username,
    required this.photoUrl,
    required this.uid,
    required this.conversationId,
  }) : isNewChat = false;

  const ChatScreen.newChat({
    super.key,
    required this.username,
    required this.photoUrl,
    required this.uid,
  })  : isNewChat = true,
        conversationId = null;

  final bool isNewChat;
  final String uid;
  final String username;
  final String photoUrl;
  final String? conversationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          onTap: () => conversationId != null
              ? Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatProfileScreen(
                    uid: uid,
                    imageUrl: photoUrl,
                    username: username,
                    conversationId: conversationId!,
                  ),
                ))
              : null,
          enabled: conversationId != null,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(photoUrl),
          ),
          title: Text(
            username,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: primaryColor,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: isNewChat
                ? const SizedBox()
                : ChatMessages(conversationId: conversationId!),
          ),
          TypeNewMessage(
            isNewChat: isNewChat,
            username: username,
            uid: uid,
            photoUrl: photoUrl,
            conversationId: isNewChat ? null : conversationId!,
          ),
        ],
      ),
    );
  }
}
