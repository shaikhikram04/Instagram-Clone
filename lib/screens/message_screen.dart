import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/new_message.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/chat_card.dart';

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen(this.navigateToSearchScreen, {super.key});
  final void Function() navigateToSearchScreen;

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
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
      return '${difference.inMinutes}min ago';
    } else if (difference.inSeconds > 0) {
      return '${difference.inSeconds}s ago';
    }

    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'username',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 27),
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
            SearchAnchor(
                viewBackgroundColor: mobileBackgroundColor,
                viewHintText: 'Search',
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    hintText: 'Search',
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return List<ListTile>.generate(5, (int index) {
                    final String item = 'item $index';
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        setState(() {
                          controller.closeView(item);
                        });
                      },
                    );
                  });
                }),
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
                      .where(
                    'participants',
                    arrayContains: {
                      'uid': user.uid,
                      'username': user.username,
                      'photoUrl': user.photoUrl,
                    },
                  ).snapshots(),
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
                        Map<String, dynamic> participant =
                            conversation['participants'][1];

                        final pastTime =
                            timeAgo(conversation['timeStamp'].toDate());

                        return ChatCard(
                          isActiveChat: true,
                          username: participant['username'],
                          imageUrl: participant['photoUrl'],
                          uid: participant['uid'],
                          lastMessage: conversation['lastMessage'],
                          time: pastTime,
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
