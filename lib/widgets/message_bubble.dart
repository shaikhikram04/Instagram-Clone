import 'package:flutter/material.dart';
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
            top: 0,
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
                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: Text(
                        username!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: isMe ? Colors.deepPurple[600] : Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        topRight: isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    constraints: const BoxConstraints(maxWidth: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        height: 1.3,
                        color: primaryColor,
                      ),
                      softWrap: true,
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
