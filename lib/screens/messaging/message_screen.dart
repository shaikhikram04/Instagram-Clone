import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/messaging/new_message.dart';
import 'package:instagram_clone/widgets/chat_card.dart';

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({
    super.key,
    this.navigateToSearchScreen,
  });
  final void Function()? navigateToSearchScreen;

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  late TextEditingController _searchController;
  late List<DocumentSnapshot> _chattingUser;
  late List<DocumentSnapshot> _filterUser;
  late StreamSubscription<QuerySnapshot> _subscription;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(
      () {
        filterringUser();
      },
    );

    _isLoading = false;
    _chattingUser = [];
    _filterUser = [];

    _setupFirestoreListener();
  }

  void _setupFirestoreListener() {
    final user = ref.read(userProvider);

    setState(() {
      _isLoading = true;
    });

    try {
      _subscription = FirebaseFirestore.instance
          .collection('conversations')
          .where('participantsId', arrayContains: user.uid)
          .orderBy('timeStamp', descending: false)
          .snapshots()
          .listen(
        (snapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              _chattingUser.insert(0, change.doc);
              _filterUser.insert(0, change.doc);
            } else if (change.type == DocumentChangeType.modified) {
              int index =
                  _chattingUser.indexWhere((doc) => doc.id == change.doc.id);
              if (index != -1) {
                _chattingUser.removeAt(index);
                _chattingUser.insert(0, change.doc);
              }

              index = _filterUser.indexWhere((doc) => doc.id == change.doc.id);
              if (index != -1) {
                _filterUser.removeAt(index);
                _filterUser.insert(0, change.doc);
              }
            } else if (change.type == DocumentChangeType.removed) {
              _chattingUser.removeWhere((doc) => doc.id == change.doc.id);
              _filterUser.removeWhere((doc) => doc.id == change.doc.id);
            }
          }
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      return;
    }
  }

  void filterringUser() {
    String query = _searchController.text.toLowerCase();
    final currUser = ref.read(userProvider);

    setState(() {
      _filterUser = _chattingUser.where(
        (user) {
          String username = '';

          final Map participants = user['participants'];
          for (final ptp in participants.entries) {
            if (ptp.key != currUser.uid) {
              username = ptp.value[0].toLowerCase();
              break;
            }
          }

          return username.contains(query);
        },
      ).toList();
    });
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
    }
    // else if (difference.inSeconds > 0) {
    //   return '${difference.inSeconds}s ago';
    // }

    return 'just now';
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _subscription.cancel();
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
                if (_searchController.text.length == 1 ||
                    _searchController.text.isEmpty) {
                  setState(() {});
                }
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
            const Row(
              children: [
                Text(
                  'Messages',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                // TextButton(
                //   onPressed: () {},
                //   child: const Text(
                //     'Request',
                //     style: TextStyle(color: blueColor, fontSize: 18),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 3),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _filterUser.isNotEmpty
                      ? ListView.builder(
                          itemCount: _filterUser.length,
                          itemBuilder: (BuildContext context, int index) {
                            final conversation = _filterUser[index];
                            String participantUid = '';
                            String participantUsername = '';
                            String participantImageUrl = '';

                            final Map participants =
                                conversation['participants'];

                            for (final ptp in participants.entries) {
                              if (ptp.key != user.uid) {
                                participantUid = ptp.key;
                                participantUsername = ptp.value[0];
                                participantImageUrl = ptp.value[1];
                                break;
                              }
                            }

                            final pastTime =
                                timeAgo(conversation['timeStamp'].toDate());

                            final lastMessageSendBy =
                                conversation['sendBy'] == user.username
                                    ? 'You'
                                    : conversation['sendBy'];

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
                        )
                      : Center(
                          child: _chattingUser.length == _filterUser.length
                              ? noChatEstablish
                              : noChatFound,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget noChatEstablish = Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'No chat started yet!',
        style: TextStyle(
            fontSize: 21,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 10),
      Text(
        'Click on top-right corner button to start chat with users.',
        style: GoogleFonts.openSans(fontSize: 15),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget noChatFound = const Text(
    'No Chat Found!',
    style: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
    ),
  );
}
