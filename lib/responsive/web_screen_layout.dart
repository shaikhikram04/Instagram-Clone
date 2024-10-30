import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/resources/auth_method.dart';
import 'package:instagram_clone/utils/colors.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  int _selectedIndex = 0;
  final NavigationRailLabelType _labelType = NavigationRailLabelType.all;

  Future<void> signOutUser() async {
    AuthMethod.signOutUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 25,
              top: 30,
              bottom: 30,
              right: 50,
            ),
            child: NavigationRail(
              leading: SvgPicture.asset(
                'assets/images/ic_instagram.svg',
                // ignore: deprecated_member_use
                color: primaryColor,
                height: 35,
              ),
              groupAlignment: -0.8,
              onDestinationSelected: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
              labelType: _labelType,
              backgroundColor: mobileBackgroundColor,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.facebookMessenger),
                  label: Text('Messages'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Notifications'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Messages'),
                ),
              ],
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu),
                // label: Text('More'),
              ),
              selectedIndex: _selectedIndex,
            ),
          ),
          const VerticalDivider(
            thickness: 0.4,
          )
        ],
      ),
    );
  }
}
