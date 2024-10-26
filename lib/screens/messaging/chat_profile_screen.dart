import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/home/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/no_data_found.dart';
import 'package:instagram_clone/widgets/post_grid.dart';

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
  late List<String> _sharedImages;
  late List<DocumentSnapshot> _sharedPosts;
  bool _isLoading = false;

  get itemBuilder => null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _sharedImages = [];
    _sharedPosts = [];
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('chats');

      //* Loading Images
      QuerySnapshot<Map<String, dynamic>>? chatsImagesSnap = await collectionRef
          .where('messageType', isEqualTo: 'image')
          .orderBy('timeStamp', descending: true)
          .get();

      final chatsImages = chatsImagesSnap.docs;
      for (final chat in chatsImages) {
        _sharedImages.add(chat.data()['imageUrl']);
      }

      //* Loading Posts
      final chatPostsSnap = await collectionRef
          .where('messageType', isEqualTo: 'post')
          .orderBy('timeStamp', descending: true)
          .get();
      final chatPosts = chatPostsSnap.docs;
      final postIds = [];
      for (final chat in chatPosts) {
        postIds.add(chat.data()['postId']);
      }

      final postsSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('postId', whereIn: postIds)
          .get();
      _sharedPosts = postsSnap.docs;
    } catch (e) {
      return;
    }
    setState(() {
      _isLoading = false;
    });
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
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _sharedImages.isEmpty
                            ? const NoDataFound(title: 'Images shared')
                            : GridView.builder(
                                itemCount: _sharedImages.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 1.5,
                                ),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    child: Image.network(
                                      _sharedImages[index],
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                        _sharedPosts.isEmpty
                            ? const NoDataFound(title: 'Posts share')
                            : PostGrid(postList: _sharedPosts)
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
