import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/page_provider.dart';
import 'package:instagram_clone/screens/add_post_sereen.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class MobileScreenLayout extends ConsumerStatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  ConsumerState<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends ConsumerState<MobileScreenLayout> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    ref.read(pageProvider.notifier).setPage(page);
  }

  @override
  Widget build(BuildContext context) {
    int page = ref.watch(pageProvider);

    return Scaffold(
      body: PageView(
        onPageChanged: onPageChanged,
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const FeedScreen(),
          const SearchScreen(),
          const AddPostSereen(),
          const Center(child: Text('Notification')),
          ProfileScreen(
            uid: FirebaseAuth.instance.currentUser!.uid,
          ),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        activeColor: primaryColor,
        inactiveColor: secondaryColor,
        currentIndex: page,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            backgroundColor: primaryColor,
          ),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
