import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/chat_profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/chat_messages.dart';
import 'package:instagram_clone/widgets/type_new_message.dart';

class ChatScreen extends StatefulWidget {
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
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          onTap: () => widget.conversationId != null
              ? Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatProfileScreen(
                    uid: widget.uid,
                    imageUrl: widget.photoUrl,
                    username: widget.username,
                    conversationId: widget.conversationId!,
                  ),
                ))
              : null,
          enabled: widget.conversationId != null,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.photoUrl),
          ),
          title: Text(
            widget.username,
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
            child: widget.isNewChat
                ? const SizedBox()
                : ChatMessages(conversationId: widget.conversationId!),
          ),
          TypeNewMessage(
            isNewChat: widget.isNewChat,
            username: widget.username,
            uid: widget.uid,
            photoUrl: widget.photoUrl,
            conversationId: widget.isNewChat ? null : widget.conversationId!,
          ),
        ],
      ),
    );
  }
}
