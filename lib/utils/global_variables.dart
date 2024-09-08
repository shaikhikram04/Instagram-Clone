import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/screens/add_post_sereen.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';

const webScreenSize = 600;

const homeScreenItems = [
  FeedScreen(),
  SearchScreen(),
  AddPostSereen(),
  Center(child: Text('Notification')),
  Center(child: Text('Profile')),
];
