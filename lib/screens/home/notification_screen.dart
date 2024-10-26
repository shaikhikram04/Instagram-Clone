import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/screens/home/profile_screen.dart';
import 'package:instagram_clone/screens/post_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:instagram_clone/widgets/no_data_found.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final List<DocumentSnapshot> _notificationList = [];
  final List<DocumentSnapshot?> _notificationRefSnap = [];
  late StreamSubscription<QuerySnapshot> _subscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _setupFirestoreListener();
  }

  Future<void> _setupFirestoreListener() async {
    final user = ref.read(userProvider);

    setState(() {
      _isLoading = true;
    });

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _notificationList.add(change.doc);

          if (change.doc['type'] == 'follow') {
            _notificationRefSnap.add(null);
          } else {
            try {
              final snap = await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(change.doc.data()!['referenceId'])
                  .get();
              _notificationRefSnap.add(snap);
            } catch (e) {
              // Handle fetch failure, possibly by logging
              _notificationRefSnap.add(null);
            }
          }
        } else if (change.type == DocumentChangeType.modified) {
          int index =
              _notificationList.indexWhere((doc) => doc.id == change.doc.id);
          if (index != -1) {
            _notificationList[index] = change.doc;
          }
        } else if (change.type == DocumentChangeType.removed) {
          _notificationList.removeWhere((doc) => doc.id == change.doc.id);
        }
      }

      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: getContent(user.following),
    );
  }

  Widget showNotficatinTile(
    Map<String, dynamic> notificationData,
    String collection,
    int index,
    bool isFollowing,
    WidgetRef ref,
  ) {
    final snap = _notificationRefSnap[index];

    return ListTile(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            if (collection == 'users') {
              return ProfileScreen(uid: notificationData['referenceId']);
            }
            return PostScreen(snap: snap!);
          },
        ));
      },
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: imageBgColor,
        backgroundImage: NetworkImage(
          notificationData['profileImageUrl'],
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: notificationData['username'],
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: "  ${notificationData['body']}",
            ),
          ],
        ),
      ),
      subtitle: Text(
        DateFormat.yMMMd().format(
          notificationData['timestamp'].toDate(),
        ),
      ),
      trailing: notificationData['type'] == 'follow'
          ? SizedBox(
              width: 80,
              child: FollowButton(
                backgroundColor: isFollowing ? imageBgColor : blueColor,
                borderColor: isFollowing ? imageBgColor : blueColor,
                text: isFollowing ? 'Following' : 'Follow',
                textColor: primaryColor,
                function: () async {
                  await FirestoreMethod.followUser(
                    notificationData['referenceId'],
                    ref,
                  );
                },
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                (snap!.data() as Map<String, dynamic>)['postUrl'],
                fit: BoxFit.cover,
                height: 50,
                width: 50,
              ),
            ),
    );
  }

  Widget getContent(List userFollowing) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_notificationList.isEmpty) {
      return const NoDataFound(title: 'Notification');
    }

    return ListView.builder(
      itemCount: _notificationList.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> notificationData =
            _notificationList[index].data() as Map<String, dynamic>;

        final collection =
            notificationData['type'] == 'follow' ? 'users' : 'posts';

        bool isFollowing = false;
        if (collection == 'users') {
          isFollowing = userFollowing.contains(notificationData['referenceId']);
        }
        return showNotficatinTile(
          notificationData,
          collection,
          index,
          isFollowing,
          ref,
        );
      },
    );
  }
}
