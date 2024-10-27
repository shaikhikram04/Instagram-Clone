import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/models/chat.dart';
import 'package:instagram_clone/models/local_chat.dart';
import 'package:instagram_clone/providers/message_provider.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/message_bubble.dart';

class ChatMessages extends ConsumerStatefulWidget {
  const ChatMessages({super.key, required this.conversationId});
  final String conversationId;

  @override
  ConsumerState<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends ConsumerState<ChatMessages> {
  final Map participantsData = {};
  // late StreamSubscription<QuerySnapshot> _subcription;
  // final List<DocumentSnapshot<Map<String, dynamic>>> _chatsData = [];
  final List<DocumentSnapshot<Map<String, dynamic>>?> _postsSnap = [];
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });

    Future.microtask(
      () async {
        ref.read(localChatProvider.notifier).clearLocalChat();
        final chatsData = await _getChatsData();
        ref.read(localChatProvider.notifier).setLocalChat(chatsData);
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  Future<List<LocalChat>> _getChatsData() async {
    final chatsData = <LocalChat>[];
    try {
      await _loadParticipantsData();

      final snapshot = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('chats')
          .orderBy('timeStamp', descending: false)
          .get();

      for (final doc in snapshot.docs) {
        String type = doc['messageType'];
        String chatId = doc['chatId'];
        String from = doc['from'];
        String? message = doc['message'];
        Timestamp timeStamp = doc.data()['timeStamp'];
        String? imageUrl = doc['imageUrl'];
        String? postId = doc['postId'];

        final localChat = type == 'text'
            ? LocalChat.text(
                chatId: chatId,
                from: from,
                message: message,
                timeStamp: timeStamp,
                messageStatus: MessageStatus.sent,
              )
            : type == 'image'
                ? LocalChat.image(
                    chatId: chatId,
                    from: from,
                    timeStamp: timeStamp,
                    imageUrl: imageUrl,
                    messageStatus: MessageStatus.sent,
                  )
                : LocalChat.post(
                    chatId: chatId,
                    from: from,
                    timeStamp: timeStamp,
                    postId: postId,
                    message: message,
                    messageStatus: MessageStatus.sent,
                  );

        chatsData.insert(0, localChat);

        if (type == 'post') {
          final postSnap = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();
          _postsSnap.insert(0, postSnap);
        } else {
          _postsSnap.insert(0, null);
        }
      }
    } catch (e) {
      return [];
    }

    return chatsData;
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
    // _subcription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUserId = FirebaseAuth.instance.currentUser!.uid;

    final localMessages = ref.watch(localChatProvider);
    while (localMessages.length != _postsSnap.length) {
      _postsSnap.insert(0, null);
    }

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: blueColor),
          )
        : localMessages.isEmpty
            ? const Center(
                child: Text('No message found!'),
              )
            : ListView.builder(
                itemCount: localMessages.length,
                reverse: true,
                padding: const EdgeInsets.only(bottom: 40),
                itemBuilder: (BuildContext context, int index) {
                  final messageData = localMessages[index];

                  final nextMessageData = index + 1 < localMessages.length
                      ? localMessages[index + 1]
                      : null;

                  final currMessageUserid = messageData.from;
                  final nextMessageUserId = nextMessageData?.from;

                  final isnextUserIsSame =
                      currMessageUserid == nextMessageUserId;

                  final isNextPost = nextMessageData != null
                      ? nextMessageData.type == MessageType.post
                      : false;

                  DocumentSnapshot? postSnap = _postsSnap[index];

                  if (isnextUserIsSame) {
                    return MessageBubble.next(
                      messageType: messageData.type.name,
                      message: messageData.message,
                      isMe: authenticatedUserId == currMessageUserid,
                      imageUrl: messageData.imageUrl,
                      postSnap: postSnap,
                      isTextAfterPost: isNextPost,
                      messageStatus: messageData.messageStatus,
                    );
                  } else {
                    final currUserData = participantsData[currMessageUserid]!;
                    return MessageBubble(
                      profileImageUrl: currUserData[1],
                      username: currUserData[0],
                      messageType: messageData.type.name,
                      message: messageData.message,
                      isMe: authenticatedUserId == currMessageUserid,
                      imageUrl: messageData.imageUrl,
                      postSnap: postSnap,
                      messageStatus: messageData.messageStatus,
                    );
                  }
                },
              );
  }
}
