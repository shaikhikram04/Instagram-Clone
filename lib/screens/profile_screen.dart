import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userData = {};
  var postLen = 0;
  var isFollowing = false;
  String currentUserId = '';
  var isLoading = false;

  @override
  void initState() {
    super.initState();
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
      if (!mounted) return;
      currentUserId = FirebaseAuth.instance.currentUser!.uid;
      isFollowing = userData['followers'].contains(currentUserId);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(userData['username']),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData['photoUrl']),
                            radius: 45,
                          ),
                          Expanded(
                            child: Column(
                              children: [
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    currentUserId == widget.uid
                                        ? FollowButton(
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            borderColor: Colors.grey,
                                            text: 'Edit Profile',
                                            textColor: primaryColor,
                                            function: () {},
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                backgroundColor: Colors.white,
                                                borderColor: Colors.grey,
                                                text: 'Unfollow',
                                                textColor: Colors.black,
                                                function: () async {
                                                  await FirestoreMethod()
                                                      .followUser(currentUserId,
                                                          userData['uid']);
                                                  setState(() {
                                                    getData();
                                                  });
                                                },
                                              )
                                            : FollowButton(
                                                backgroundColor: blueColor,
                                                borderColor: Colors.blue,
                                                text: 'Follow',
                                                textColor: Colors.white,
                                                function: () async {
                                                  await FirestoreMethod()
                                                      .followUser(currentUserId,
                                                          userData['uid']);
                                                  setState(() {
                                                    getData();
                                                  });
                                                },
                                              ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15, left: 10),
                        child: Text(
                          userData['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1, left: 10),
                        child: Text(
                          userData['bio'],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
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

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.size,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        return Image.network(
                          snapshot.data!.docs[index].data()['postUrl'],
                          fit: BoxFit.cover,
                        );
                      },
                    );
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
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }
}
