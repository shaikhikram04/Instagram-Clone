import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/auth_method.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class MobileScreenLayout extends StatelessWidget {
  const MobileScreenLayout({super.key});

  void signOutUser() {
    AuthMethod().signOutUser();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(user.username),
            ElevatedButton(
              onPressed: signOutUser,
              child: const Text('Sign Out'),
            )
          ],
        ),
      ),
    );
  }
}
