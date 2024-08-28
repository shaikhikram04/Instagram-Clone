import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_method.dart';

class MobileScreenLayout extends StatelessWidget {
  const MobileScreenLayout({super.key});

  void signOutUser() {
    AuthMethod().signOutUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This is Mobile'),
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
