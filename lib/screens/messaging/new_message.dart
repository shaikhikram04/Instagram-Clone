import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/chat_card.dart';
import 'package:instagram_clone/widgets/follow_button.dart';

class NewMessage extends ConsumerStatefulWidget {
  const NewMessage(this.navigateToSearchScreen, {super.key});

  final void Function() navigateToSearchScreen;

  @override
  ConsumerState<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends ConsumerState<NewMessage> {
  late TextEditingController _searchController;
  late List<DocumentSnapshot> _followingUsers;
  late List<DocumentSnapshot> _filterUser;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _isLoading = false;
    _followingUsers = [];
    fetchUsers();
    _searchController.addListener(
      () {
        filterUser();
      },
    );
  }

  void fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    final user = ref.read(userProvider);
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: user.following)
        .get();

    setState(() {
      _followingUsers = snapshot.docs;
      _filterUser = _followingUsers;
      _isLoading = false;
    });
  }

  void filterUser() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filterUser = _followingUsers.where(
        (user) {
          String username = user['username'].toLowerCase();
          return username.contains(query);
        },
      ).toList();
    });
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
        title: const Text(
          'New message',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.following.isNotEmpty)
              Row(
                children: [
                  const SizedBox(width: 5),
                  const Text(
                    'To :',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      cursorColor: Colors.lightBlue,
                      style: const TextStyle(fontSize: 19, color: primaryColor),
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            const Text(
              'Suggested',
              style: TextStyle(
                color: primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: user.following.isNotEmpty
                  ? _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: _filterUser.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot snap = _filterUser[index];
                            return ChatCard.newChat(
                              username: snap['username'],
                              bio: snap['bio'],
                              imageUrl: snap['photoUrl'],
                              uid: snap['uid'],
                            );
                          },
                        )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "You're not following anyone yet!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            'Start following to send messages.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          FollowButton(
                            backgroundColor: blueColor,
                            borderColor: blueColor,
                            text: 'Find People to follow',
                            textColor: primaryColor,
                            function: () {
                              widget.navigateToSearchScreen();
                              Navigator.of(context).popUntil(
                                (route) =>
                                    (Navigator.of(context).canPop() == false),
                              );
                            },
                          )
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
