import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/chat_card.dart';

class NewMessage extends ConsumerStatefulWidget {
  const NewMessage({super.key});

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
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data.size,
                            itemBuilder: (BuildContext context, int index) {
                              return const ChatCard(
                                isActiveChat: false,
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
                  : const Center(
                      child: Text('Please Follow someone to communicate'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
