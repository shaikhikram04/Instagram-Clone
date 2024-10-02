import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/models/chat.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class TypeNewMessage extends ConsumerStatefulWidget {
  const TypeNewMessage({
    super.key,
    this.isNewChat = false,
    required this.username,
    required this.uid,
    required this.photoUrl,
    this.conversationId,
  });

  final bool isNewChat;
  final String? conversationId;
  final String username;
  final String uid;
  final String photoUrl;

  @override
  ConsumerState<TypeNewMessage> createState() => _TypeNewMessageState();
}

class _TypeNewMessageState extends ConsumerState<TypeNewMessage> {
  late TextEditingController messageController;
  late String textMessage;
  Uint8List? image;
  late bool isMessaging;
  late User user;
  late bool isNewChat;
  late String id;

  Widget emojiButton = IconButton(
    onPressed: () {},
    icon: const Icon(
      Icons.emoji_emotions,
      color: Colors.amber,
      size: 33,
    ),
  );

  @override
  void initState() {
    super.initState();

    messageController = TextEditingController();
    textMessage = '';
    isMessaging = false;
    user = ref.read(userProvider);
    isNewChat = widget.isNewChat;
    id = widget.conversationId ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  Future<void> sendMessage() async {
    textMessage = messageController.text.trim();
    //* will be change
    const messageType = MessageType.text;

    if (textMessage.isNotEmpty) {
      if (isNewChat) {
        id = await FirestoreMethod.establishConversation(
          user.uid,
          user.username,
          user.photoUrl,
          widget.uid,
          widget.username,
          widget.photoUrl,
        );
        isNewChat = false;
      }

      if (id == 'errror occurred') {
        if (!mounted) return;

        showSnackBar('Some error occurred! please try again.', context);
      } else {
        final res = await FirestoreMethod.pushMessage(
          id,
          user.uid,
          textMessage,
          messageType,
        );

        if (res != 'success') {
          if (!mounted) return;

          showSnackBar('Some error occurred! please try again.', context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: const BoxDecoration(
        color: Color.fromARGB(76, 21, 142, 242),
        borderRadius: BorderRadius.all(Radius.circular(33)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          isMessaging
              ? emojiButton
              : CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF088DE5),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt,
                      color: primaryColor,
                      size: 33,
                    ),
                  ),
                ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Message...',
              ),
              onChanged: (value) {
                if ((value.isNotEmpty && !isMessaging) ||
                    (value.isEmpty && isMessaging)) {
                  setState(() {
                    isMessaging = !isMessaging;
                  });
                }
              },
            ),
          ),
          if (!isMessaging)
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.insert_photo,
                color: primaryColor,
                size: 33,
              ),
            ),
          isMessaging
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      fixedSize: const Size(20, 10)),
                  onPressed: sendMessage,
                  child: const Icon(
                    Icons.send,
                    color: primaryColor,
                  ),
                )
              : emojiButton,
          const SizedBox(width: 7),
        ],
      ),
    );
  }
}
