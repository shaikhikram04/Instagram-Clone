import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/resources/auth_method.dart';
import 'package:instagram_clone/utils/colors.dart';

class WebScreenLayout extends StatelessWidget {
  const WebScreenLayout({super.key});
  Future<void> signOutUser() async {
    await AuthMethod().signOutUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: SvgPicture.asset(
          'assets/images/ic_instagram.svg',
          // ignore: deprecated_member_use
          color: primaryColor,
          height: 35,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              FontAwesomeIcons.facebookMessenger,
              color: primaryColor,
              size: 22,
            ),
          )
        ],
      ),
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
