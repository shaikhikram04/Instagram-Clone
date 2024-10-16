import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:instagram_clone/widgets/no_data_found.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  Future<String> getPostImageUrl(String postId) async {
    final snap =
        await FirebaseFirestore.instance.collection('posts').doc(postId).get();

    return snap.data()!['postUrl'];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const NoDataFound(title: 'Notification');
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: snapshot.data!.size,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (BuildContext context, int index) {
              final notificationData = docs[index].data();

              final collection =
                  notificationData['type'] == 'follow' ? 'users' : 'posts';
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection(collection)
                    .doc(notificationData['referenceId'])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final snap = snapshot.data!.data();
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: imageBgColor,
                      backgroundImage: NetworkImage(
                        collection == 'posts'
                            ? snap!['profImage']
                            : snap!['photoUrl'],
                      ),
                    ),
                    title: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: snap['username'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: "  ${notificationData['body']}",
                        ),
                      ]),
                    ),
                    subtitle: Text(
                      DateFormat.yMMMd().format(
                        notificationData['timestamp'].toDate(),
                      ),
                    ),
                    trailing: notificationData['type'] == 'follow'
                        ? const SizedBox(
                            width: 80,
                            child: FollowButton(
                                backgroundColor: blueColor,
                                borderColor: blueColor,
                                text: 'Follow',
                                textColor: primaryColor),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              snap['postUrl'],
                              fit: BoxFit.cover,
                              height: 50,
                              width: 50,
                            ),
                          ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
