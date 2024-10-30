import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/screens/messaging/message_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/feeds_content.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key, required this.navigateToSearchScreen});

  final void Function() navigateToSearchScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/images/ic_instagram.svg',
          // ignore: deprecated_member_use
          color: primaryColor,
          height: 35,
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) =>
                  MessageScreen(navigateToSearchScreen: navigateToSearchScreen),
            )),
            icon: const Icon(
              FontAwesomeIcons.facebookMessenger,
              color: primaryColor,
              size: 22,
            ),
          )
        ],
      ),
      body: const FeedsContent(),
    );
  }
}
