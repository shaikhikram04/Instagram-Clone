import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_method.dart';

class WebScreenLayout extends StatelessWidget {
  const WebScreenLayout({super.key});
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
            const Text('This is Web'),
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
