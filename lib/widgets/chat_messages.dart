import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/message_bubble.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key, required this.conversationId});
  final String conversationId;

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  Map<String, List> participantsData = {};

  @override
  void initState() {
    super.initState();
    _loadParticipantsData();
  }

  Future<void> _loadParticipantsData() async {
    final snap = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .get();

    List participants = snap.data()!['participants'];

    for (final data in participants) {
      participantsData.addAll({
        data['uid']: [data['username'], data['photoUrl']]
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('chats')
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: blueColor);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          const Center(
            child: Text('No message found!'),
          );
        }

        if (snapshot.hasError) {
          const Center(
            child: Text('Something went wrong...'),
          );
        }

        final loadedMessage = snapshot.data!.docs;

        return ListView.builder(
          itemCount: loadedMessage.length,
          reverse: true,
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          itemBuilder: (BuildContext context, int index) {
            final messageData = loadedMessage[index].data();

            final nextMessageData = index + 1 < loadedMessage.length
                ? loadedMessage[index + 1].data()
                : null;

            final currMessageUserid = messageData['from'];
            final nextMessageUserId =
                nextMessageData != null ? nextMessageData['from'] : null;

            final isnextUserIsSame = currMessageUserid == nextMessageUserId;

            if (isnextUserIsSame) {
              return MessageBubble.next(
                messageType: messageData['messageType'],
                message: messageData['message'],
                isMe: authenticatedUserId == currMessageUserid,
              );
            } else {
              final currUserData = participantsData[currMessageUserid]!;
              return MessageBubble(
                profileImageUrl: currUserData[1],
                username: currUserData[0],
                messageType: messageData['messageType'],
                message: messageData['message'],
                isMe: authenticatedUserId == currMessageUserid,
              );
            }
          },
        );
      },
    );
  }
}