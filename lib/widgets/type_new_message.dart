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
  late TextEditingController _messageController;
  late String textMessage;
  Uint8List? image;
  bool isMessaging = false;
  late User user;
  late bool isNewChat;
  late String id;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController();
    _focusNode = FocusNode();
    textMessage = '';
    user = ref.read(userProvider);
    isNewChat = widget.isNewChat;
    id = widget.conversationId ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _focusNode.dispose();
  }

  Future<void> sendMessage() async {
    textMessage = _messageController.text;
    //* will be change
    const messageType = MessageType.text;

    if (textMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    if (isNewChat) {
      id = await FirestoreMethod.establishConversation(
        user.uid,
        user.username,
        user.photoUrl,
        widget.uid,
        widget.username,
        widget.photoUrl,
      );
      setState(() {
        isNewChat = false;
      });
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

        showSnackBar(res, context);
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
      child: Stack(
        children: [
          Expanded(
            child: Center(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                style: const TextStyle(color: primaryColor, fontSize: 19),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Message...',
                    contentPadding: EdgeInsets.only(
                      left: 63,
                      right: 90,
                    )),
                onChanged: (value) {
                  if ((value.isNotEmpty && !isMessaging) ||
                      (value.isEmpty && isMessaging)) {
                    setState(() {
                      isMessaging = value.isNotEmpty;
                    });
                  }
                },
              ),
            ),
          ),
          Positioned(
            left: isMessaging ? 5 : null,
            right: isMessaging ? null : 5,
            top: 5,
            bottom: 5,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.emoji_emotions,
                color: Colors.amber,
                size: 35,
              ),
            ),
          ),
          if (isMessaging)
            Positioned(
              top: 11,
              bottom: 11,
              right: 11,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor, fixedSize: const Size(60, 40)),
                onPressed: sendMessage,
                child: const Icon(
                  Icons.send,
                  color: primaryColor,
                ),
              ),
            ),
          if (!isMessaging)
            Positioned(
              top: 5,
              bottom: 5,
              left: 10,
              child: CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFF088DE5),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.camera_alt,
                    color: primaryColor,
                    size: 31,
                  ),
                ),
              ),
            ),
          if (!isMessaging)
            Positioned(
              right: 55,
              top: 5,
              bottom: 5,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.insert_photo,
                  color: primaryColor,
                  size: 35,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
