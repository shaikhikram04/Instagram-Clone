import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/screens/home/add_post_screen.dart';
import 'package:instagram_clone/screens/home/notification_screen.dart';
import 'package:instagram_clone/screens/home/profile_screen.dart';
import 'package:instagram_clone/screens/home/search_screen.dart';
import 'package:instagram_clone/screens/messaging/message_screen.dart';
import 'package:instagram_clone/screens/setting_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/feeds_content.dart';
import 'package:instagram_clone/widgets/settings_button.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  int _selectedIndex = 0;

  void navigateToSearchScreen() {
    if (!context.mounted) return;

    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // final width = MediaQuery.of(context).size.width;

    Widget currentContent = getCurrentContent();

    return Scaffold(
      body: Row(
        children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      SvgPicture.asset(
                        'assets/images/ic_instagram.svg',
                        // ignore: deprecated_member_use
                        color: primaryColor,
                        height: 35,
                      ),
                      const SizedBox(height: 40),
                      getOptionButtons(0),
                      getOptionButtons(1),
                      getOptionButtons(2),
                      getOptionButtons(3),
                      getOptionButtons(4),
                      getOptionButtons(5),
                      const Spacer(),
                      getOptionButtons(6),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(
            thickness: 0.4,
          ),
          Flexible(
            child: Center(
              child: SizedBox(
                width: 600,
                child: currentContent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getCurrentContent() {
    switch (_selectedIndex) {
      case 0:
        return const FeedsContent();
      case 1:
        return const SearchScreen();
      case 2:
        return const MessageScreen();
      case 3:
        return const NotificationScreen();
      case 4:
        return const AddPostScreen();
      case 5:
        return ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid);
      case 6:
        return const SettingScreen();
      default:
        return const SizedBox();
    }
  }

  Widget getOptionButtons(
    int index,
  ) {
    final bool isSelected = index == _selectedIndex;
    String title;
    IconData iconData;
    switch (index) {
      case 0:
        title = 'Home';
        iconData = isSelected ? Icons.home : Icons.home_outlined;
        break;
      case 1:
        title = 'Search';
        iconData = isSelected ? Icons.search : Icons.search_outlined;
        break;
      case 2:
        title = 'Messages';
        iconData = FontAwesomeIcons.facebookMessenger;
        break;
      case 3:
        title = 'Notifications';
        iconData = isSelected ? Icons.favorite : Icons.favorite_outline;
        break;
      case 4:
        title = 'Create';
        iconData = isSelected ? Icons.add_box : Icons.add_box_outlined;
        break;
      case 5:
        title = 'Profile';
        iconData = isSelected ? Icons.person : Icons.person_outline;
        break;
      case 6:
        title = 'More';
        iconData = Icons.menu;
        break;

      default:
        title = 'Home';
        iconData = isSelected ? Icons.home : Icons.home_outlined;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        width: 220,
        height: 50,
        child: SettingsButton(
          text: title,
          iconData: iconData,
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          isSelected: isSelected,
        ),
      ),
    );
  }
}
