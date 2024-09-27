import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class TypeNewMessage extends StatefulWidget {
  const TypeNewMessage({super.key});

  @override
  State<TypeNewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<TypeNewMessage> {
  final messageController = TextEditingController();
  bool isMessaging = false;

  Widget emojiButton = IconButton(
    onPressed: () {},
    icon: const Icon(
      Icons.emoji_emotions,
      color: Colors.amber,
      size: 33,
    ),
  );

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
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
                  onPressed: () {},
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
