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
              const Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'To :',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.lightBlue,
                      style: TextStyle(fontSize: 19, color: primaryColor),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
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
                  ? FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .where('uid', whereIn: user.following)
                          .get(),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.size,
                            itemBuilder: (BuildContext context, int index) {
                              return ChatCard.newChat(
                                username: snapshot.data!.docs[index]
                                    ['username'],
                                bio: snapshot.data!.docs[index]['bio'],
                                imageUrl: snapshot.data!.docs[index]
                                    ['photoUrl'],
                                uid: snapshot.data!.docs[index]['uid'],
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        }

                        return const Center(
                            child: CircularProgressIndicator(
                          color: blueColor,
                        ));
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
