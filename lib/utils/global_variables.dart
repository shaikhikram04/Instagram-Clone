import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/screens/add_post_sereen.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';

const webScreenSize = 600;

 List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostSereen(),
  const Center(child: Text('Notification')),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,),
];
