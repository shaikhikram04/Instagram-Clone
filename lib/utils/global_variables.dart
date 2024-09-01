import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/screens/add_post_sereen.dart';
import 'package:instagram_clone/screens/feed_screen.dart';

const webScreenSize = 600;

const homeScreenItems = [
  FeedScreen(),
  Center(child: Text('Search')),
  AddPostSereen(),
  Center(child: Text('Notification')),
  Center(child: Text('Profile')),
];
