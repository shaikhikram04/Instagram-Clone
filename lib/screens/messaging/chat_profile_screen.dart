import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/home/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class ChatProfileScreen extends StatefulWidget {
  const ChatProfileScreen({
    super.key,
    required this.conversationId,
    required this.uid,
    required this.username,
    required this.imageUrl,
  });

  final String conversationId;
  final String uid;
  final String username;
  final String imageUrl;

  @override
  State<ChatProfileScreen> createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends State<ChatProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: imageBgColor,
              backgroundImage: NetworkImage(
                widget.imageUrl,
              ),
              radius: 60,
            ),
            const SizedBox(height: 18),
            Text(
              widget.username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => ProfileScreen(uid: widget.uid),
                )),
                child: const Column(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 35,
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(
                    Icons.image,
                    size: 30,
                  ),
                ),
                Tab(
                    icon: Icon(
                  Icons.repeat,
                  size: 30,
                )),
              ],
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              dividerHeight: 0.7,
              indicatorColor: primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  Center(child: Text('Shared Images Grid')),
                  Center(child: Text('Shared posts grid')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
