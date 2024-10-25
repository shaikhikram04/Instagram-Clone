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
  late Map<String, dynamic> _userData;
  late List<DocumentSnapshot> _userPostsSnap;
  late bool _isPostsLoading;
  late int _postLen;
  late bool _isFollowing;
  late bool _isLoading;
  late int _following;
  late int _followers;
  late User _user;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _user = ref.read(userProvider);
    _userData = {};
    _userPostsSnap = [];
    _isPostsLoading = false;
    _postLen = 0;
    _isFollowing = false;
    _isLoading = false;
    _followers = 0;
    _following = 0;
    _scrollController = ScrollController();
    getData();
    loadPosts();
  }

  Future<void> loadPosts() async {
    setState(() {
      _isPostsLoading = true;
    });

    try {
      final postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      _userPostsSnap = postSnap.docs;
    } catch (e) {
      return;
    }

    setState(() {
      _isPostsLoading = false;
    });
  }

  void getData() async {
    setState(() {
      _isLoading = true;
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

      _postLen = postSnap.docs.length;
      _userData = snap.data()!;
      _isFollowing = _userData['followers'].contains(_user.uid);

      _followers = _userData['followers'].length;
      _following = _userData['following'].length;
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      showSnackBar(e.toString(), context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget getPostData(String userId, ScrollController scrollController) {
    if (_isPostsLoading) {
      return const Center(
          child: CircularProgressIndicator(
        color: blueColor,
      ));
    }

    if (_userPostsSnap.isEmpty) {
      if (userId == widget.uid) {
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

    return PostGrid(postList: _userPostsSnap);
  }

  @override
  Widget build(BuildContext context) {
    _user = ref.watch(userProvider);

    Widget button = _user.uid == widget.uid
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
        : _isFollowing
            ? FollowButton(
                backgroundColor: Colors.white,
                borderColor: Colors.grey,
                text: 'Unfollow',
                textColor: Colors.black,
                function: () async {
                  setState(() {
                    _isFollowing = false;
                    _followers--;
                  });
                  await FirestoreMethod.followUser(
                    _userData['uid'],
                    ref,
                  );
                },
              )
            : FollowButton(
                backgroundColor: blueColor,
                borderColor: Colors.blue,
                text: 'Follow',
                textColor: Colors.white,
                function: () async {
                  setState(() {
                    _isFollowing = true;
                    _followers++;
                  });
                  await FirestoreMethod.followUser(
                    _userData['uid'],
                    ref,
                  );
                },
              );

    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? Container()
            : Text(
                _userData['username'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          if (_user.uid == _userData['uid'])
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: blueColor,
            ))
          : ListView(
              controller: _scrollController,
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
                            backgroundImage:
                                NetworkImage(_userData['photoUrl']),
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
                                    buildStatColumn(_postLen, 'Posts'),
                                    buildStatColumn(_followers, 'Followers'),
                                    buildStatColumn(_following, 'Following'),
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
                          _userData['username'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          _userData['bio'],
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
                getPostData(_user.uid, _scrollController)
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
