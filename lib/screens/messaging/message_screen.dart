import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/messaging/new_message.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/chat_card.dart';

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen(this.navigateToSearchScreen, {super.key});
  final void Function() navigateToSearchScreen;

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  String timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays >= 356) {
      final int year = (difference.inDays / 365).floor();
      return '${year}y ago';
    } else if (difference.inDays >= 30) {
      final int month = (difference.inDays / 30).floor();
      return '${month}month ago';
    } else if (difference.inDays >= 7) {
      final int week = (difference.inDays / 7).floor();
      return '${week}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inSeconds > 0) {
      return '${difference.inSeconds}s ago';
    }

    return 'just now';
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 27),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NewMessage(widget.navigateToSearchScreen),
              ));
            },
            icon: const Icon(
              Icons.edit_square,
              size: 28,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                        icon: const Icon(Icons.clear))
                    : null,
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.grey[200],
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.grey[940],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Request',
                    style: TextStyle(color: blueColor, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('conversations')
                      .where('participantsId', arrayContains: user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: blueColor,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No Chats Available'));
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }

                    final conversationList = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: conversationList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final conversation = conversationList[index].data();
                        String participantUid = '';
                        String participantUsername = '';
                        String participantImageUrl = '';

                        final Map participants = conversation['participants'];

                        for (final ptp in participants.entries) {
                          if (ptp.key != user.uid) {
                            participantUid = ptp.key;
                            participantUsername = ptp.value[0];
                            participantImageUrl = ptp.value[1];
                          }
                        }

                        final pastTime =
                            timeAgo(conversation['timeStamp'].toDate());

                        final lastMessageSendBy =
                            conversation['sendBy'] == user.uid
                                ? 'You'
                                : participantUsername;
                        return ChatCard(
                          username: participantUsername,
                          imageUrl: participantImageUrl,
                          uid: participantUid,
                          lastMessage: conversation['lastMessage'],
                          time: pastTime,
                          conversationId: conversation['id'],
                          lastMessageBy: lastMessageSendBy,
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
