import 'dart:async';

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
  late StreamSubscription<QuerySnapshot> _subcription;
  final List<DocumentSnapshot<Map<String, dynamic>>> _chatsData = [];
  final List<DocumentSnapshot<Map<String, dynamic>>?> _postsSnap = [];
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupFirestoreListener();
  }

  void _setupFirestoreListener() {
    setState(() {
      _isLoading = true;
    });

    try {
      _loadParticipantsData();

      _subcription = FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('chats')
          .orderBy('timeStamp', descending: false)
          .snapshots()
          .listen(
        (snapshot) async {
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              _chatsData.insert(0, change.doc);
              if (change.doc.data()!['messageType'] == 'post') {
                final postSnap = await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(change.doc.data()!['postId'])
                    .get();
                _postsSnap.insert(0, postSnap);
              } else {
                _postsSnap.insert(0, null);
              }
            } else if (change.type == DocumentChangeType.modified) {
              int index = _chatsData.indexWhere(
                (doc) => doc.id == change.doc.id,
              );
              if (index != -1) {
                _chatsData[index] = change.doc;
              }
            } else if (change.type == DocumentChangeType.removed) {
              _chatsData.removeWhere((doc) => doc.id == change.doc.id);
            }
          }

          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
  }

  Future<void> _loadParticipantsData() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .get();

      final Map temp = snap.data()!['participants'];

      participantsData.addAll(temp);
    } catch (e) {
      return;
    }
  }

  @override
  void dispose() {
    _subcription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUserId = FirebaseAuth.instance.currentUser!.uid;

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: blueColor),
          )
        : _chatsData.isEmpty
            ? const Center(
                child: Text('No message found!'),
              )
            : ListView.builder(
                itemCount: _chatsData.length,
                reverse: true,
                padding: const EdgeInsets.only(bottom: 40),
                itemBuilder: (BuildContext context, int index) {
                  final messageData = _chatsData[index].data()!;

                  final nextMessageData = index + 1 < _chatsData.length
                      ? _chatsData[index + 1].data()
                      : null;

                  final currMessageUserid = messageData['from'];
                  final nextMessageUserId =
                      nextMessageData != null ? nextMessageData['from'] : null;

                  final isnextUserIsSame =
                      currMessageUserid == nextMessageUserId;

                  final isNextPost = nextMessageData != null
                      ? nextMessageData['messageType'] == 'post'
                      : false;

                  DocumentSnapshot? postSnap = _postsSnap[index];

                  if (isnextUserIsSame) {
                    return MessageBubble.next(
                      messageType: messageData['messageType'],
                      message: messageData['message'],
                      isMe: authenticatedUserId == currMessageUserid,
                      imageUrl: messageData['imageUrl'],
                      postSnap: postSnap,
                      isTextAfterPost: isNextPost,
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
  }
}
