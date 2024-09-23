import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/settings_button.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            onTap: () {},
          ),
          SettingsButton(
            text: 'Liked',
            iconData: Icons.favorite_border,
            onTap: () {},
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
