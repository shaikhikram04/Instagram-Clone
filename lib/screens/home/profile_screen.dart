import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/screens/edit_profile_screen.dart';
import 'package:instagram_clone/screens/setting_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:instagram_clone/widgets/no_data_found.dart';
import 'package:instagram_clone/widgets/post_grid.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const ProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic> userData = {};
  var postLen = 0;
  var isFollowing = false;
  var isLoading = false;
  late User user;

  @override
  void initState() {
    super.initState();
    user = ref.read(userProvider);
    getData();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      final postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = snap.data()!;
      isFollowing = userData['followers'].contains(user.uid);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      showSnackBar(e.toString(), context);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = ref.watch(userProvider);

    Widget button = user.uid == widget.uid
        ? FollowButton(
            backgroundColor: mobileBackgroundColor,
            borderColor: Colors.grey,
            text: 'Edit Profile',
            textColor: primaryColor,
            function: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ));
            },
          )
        : isFollowing
            ? FollowButton(
                backgroundColor: Colors.white,
                borderColor: Colors.grey,
                text: 'Unfollow',
                textColor: Colors.black,
                function: () async {
                  await FirestoreMethod.followUser(
                    userData['uid'],
                    ref,
                  );
                  setState(() {
                    isFollowing = !isFollowing;
                  });
                },
              )
            : FollowButton(
                backgroundColor: blueColor,
                borderColor: Colors.blue,
                text: 'Follow',
                textColor: Colors.white,
                function: () async {
                  await FirestoreMethod.followUser(
                    userData['uid'],
                    ref,
                  );
                  setState(() {
                    isFollowing = !isFollowing;
                  });
                },
              );

    return Scaffold(
      appBar: AppBar(
        title: isLoading
            ? Container()
            : Text(
                userData['username'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          if (user.uid == userData['uid'])
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const SettingScreen(),
                ));
              },
              icon: const Icon(
                Icons.menu,
                size: 27,
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: blueColor,
            ))
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          //* profile picture
                          CircleAvatar(
                            backgroundColor: imageBgColor,
                            backgroundImage: NetworkImage(userData['photoUrl']),
                            radius: 45,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              children: [
                                //* posts, followers, following count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(postLen, 'Posts'),
                                    buildStatColumn(
                                        userData['followers'].length,
                                        'Followers'),
                                    buildStatColumn(
                                        userData['following'].length,
                                        'Following'),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                button,
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          userData['username'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userData['bio'],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15, bottom: 5),
                  height: 25,
                  width: double.infinity,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.grid_on,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Posts',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: primaryColor,
                ),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.data!.size == 0) {
                      if (user.uid == widget.uid) {
                        return Container(
                          padding: const EdgeInsets.only(top: 50),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Capture the moment with a friend',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Create your first post',
                                style: TextStyle(
                                  color: blueColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return const NoDataFound(title: 'post');
                      }
                    }

                    return PostGrid(postList: snapshot.data!.docs);
                  },
                ),
              ],
            ),
    );
  }

  Column buildStatColumn(int number, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }
}
