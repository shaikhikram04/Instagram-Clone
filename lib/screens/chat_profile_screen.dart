import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class ChatProfileScreen extends StatefulWidget {
  const ChatProfileScreen({super.key});

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
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
      ),
      body: Center(
        child: Column(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1727324735318-c25d437052f7?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHw2fHx8ZW58MHx8fHx8',
              ),
              radius: 60,
            ),
            const SizedBox(height: 18),
            const Text(
              'username',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: GestureDetector(
                onTap: () {},
                child: const Column(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 35,
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.w500),
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
