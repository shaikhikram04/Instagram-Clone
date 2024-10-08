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
  final Map participantsData = {};
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadParticipantsData();
  }

  Future<void> _loadParticipantsData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final snap = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .get();

      final Map temp = snap.data()!['participants'];

      participantsData.addAll(temp);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      return;
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
          padding: const EdgeInsets.only(bottom: 40),
          itemBuilder: (BuildContext context, int index) {
            final messageData = loadedMessage[index].data();

            final nextMessageData = index + 1 < loadedMessage.length
                ? loadedMessage[index + 1].data()
                : null;

            final currMessageUserid = messageData['from'];
            final nextMessageUserId =
                nextMessageData != null ? nextMessageData['from'] : null;

            final isnextUserIsSame = currMessageUserid == nextMessageUserId;

            return FutureBuilder(
              future: messageData['messageType'] == 'post'
                  ? FirebaseFirestore.instance
                      .collection('posts')
                      .doc(messageData['postId'])
                      .get()
                  : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                Map<String, dynamic>? postSnap;
                if (snapshot.hasData) {
                  postSnap = snapshot.data!.data();
                }

                if (isnextUserIsSame) {
                  return MessageBubble.next(
                    messageType: messageData['messageType'],
                    message: messageData['message'],
                    isMe: authenticatedUserId == currMessageUserid,
                    imageUrl: messageData['imageUrl'],
                    postSnap: postSnap,
                  );
                } else {
                  final currUserData = participantsData[currMessageUserid]!;
                  return MessageBubble(
                    profileImageUrl: currUserData[1],
                    username: currUserData[0],
                    messageType: messageData['messageType'],
                    message: messageData['message'],
                    isMe: authenticatedUserId == currMessageUserid,
                    imageUrl: messageData['imageUrl'],
                    postSnap: postSnap,
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
