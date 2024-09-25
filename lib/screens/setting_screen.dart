import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/post_collection.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/settings_button.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);

    var likeList = user.likedPosts;
    var saveList = user.savedPosts;

    final postCollection = FirebaseFirestore.instance.collection('posts');

    Future<void> navigateToLikedPost(List likelist,
        CollectionReference<Map<String, dynamic>> postCollection) async {
      var likePostList = [];
      try {
        if (likelist.isNotEmpty) {
          final snap = await postCollection
              .where(FieldPath.documentId, whereIn: likelist)
              .get();

          likePostList = snap.docs;
        }
      } catch (e) {
        return;
      }

      if (!context.mounted) return;

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PostCollectionScreen(likePostList, 'Liked Post'),
      ));
    }

    Future<void> navigateTosavedPost(List saveList,
        CollectionReference<Map<String, dynamic>> postCollection) async {
      var savePostList = [];
      try {
        if (saveList.isNotEmpty) {
          final snap = await postCollection
              .where(FieldPath.documentId, whereIn: saveList)
              .get();

          savePostList = snap.docs;
        }
      } catch (e) {
        return;
      }

      if (!context.mounted) return;

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PostCollectionScreen(
          savePostList,
          'Saved Post',
        ),
      ));
    }

    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        foregroundColor: primaryColor,
        title: const Text('Settings and activity'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        children: [
          SettingsButton(
            text: 'Saved',
            iconData: Icons.bookmark_border,
            onTap: () => navigateTosavedPost(saveList, postCollection),
          ),
          SettingsButton(
            text: 'Liked',
            iconData: Icons.favorite_border,
            onTap: () => navigateToLikedPost(likeList, postCollection),
          ),
          SettingsButton(
            text: 'Log out',
            iconData: Icons.logout,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
            color: Colors.red,
          )
        ],
      ),
    );
  }
}
