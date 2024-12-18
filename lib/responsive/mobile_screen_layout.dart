import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/home/add_post_screen.dart';
import 'package:instagram_clone/screens/home/feed_screen.dart';
import 'package:instagram_clone/screens/home/notification_screen.dart';
import 'package:instagram_clone/screens/home/profile_screen.dart';
import 'package:instagram_clone/screens/home/search_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key, this.initialPage = 0});

  final int initialPage;

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  late int _page;
  late PageController _pageController;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  bool isNewNotification = false;
  var lastNotificationId = '';

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;
    _pageController = PageController(initialPage: _page);
    checkForNewNotification();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Future<void> navigationTapped(int page) async {
    if (page == 3) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'lastSeenNotificationId': lastNotificationId});
      isNewNotification = false;
    }
    _pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigateToSearchScreen() {
    if (!context.mounted) return;

    setState(() {
      _page = 1;
      _pageController.jumpToPage(1);
    });
  }

  Future<void> checkForNewNotification() async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final snapList = await userDoc
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final userSnap = await userDoc.get();

      final String lastSeenNotificationId =
          userSnap.data()!['lastSeenNotificationId'];

      if (snapList.docs.isNotEmpty) {
        lastNotificationId = snapList.docs[0].id;
      }
      isNewNotification = lastNotificationId != lastSeenNotificationId;
    } catch (e) {
      return;
    }
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: onPageChanged,
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          FeedScreen(navigateToSearchScreen: navigateToSearchScreen),
          const SearchScreen(),
          const AddPostScreen(),
          const NotificationScreen(),
          ProfileScreen(
            uid: userId,
          ),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        activeColor: primaryColor,
        inactiveColor: secondaryColor,
        currentIndex: _page,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            backgroundColor: primaryColor,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            backgroundColor: primaryColor,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.favorite),
                if (isNewNotification)
                  const Positioned(
                    bottom: 3,
                    right: 0,
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.red,
                    ),
                  )
              ],
            ),
            backgroundColor: primaryColor,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            backgroundColor: primaryColor,
          ),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
