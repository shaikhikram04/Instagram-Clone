import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/blue_button.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  Set<String> _selectedUsers = {};

  final _collectionRef = FirebaseFirestore.instance.collection('users');
  late TextEditingController _messageController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _focusNode.dispose();
  }

  void sendPost() {}

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    List<String> followingList = user.following.cast<String>();

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 18),
                          child: SearchAnchor(
                              builder: (context, controller) => SearchBar(
                                    hintText: 'Search',
                                    backgroundColor: WidgetStatePropertyAll(
                                        Colors.grey[830]),
                                    leading: const Icon(Icons.search),
                                    shape: const WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)))),
                                  ),
                              suggestionsBuilder: (context, controller) {
                                return [];
                              }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController, // Attach scrollController
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: followingList.length,
                      itemBuilder: (context, index) {
                        bool isSelected =
                            _selectedUsers.contains(followingList[index]);
                        return FutureBuilder(
                          future:
                              _collectionRef.doc(followingList[index]).get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData || snapshot.hasError) {
                              return const Center(
                                child: Text('Getting Error'),
                              );
                            }

                            final String username =
                                snapshot.data!.data()!['username'];
                            final String imageUrl =
                                snapshot.data!.data()!['photoUrl'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedUsers.remove(followingList[index]);
                                  } else {
                                    _selectedUsers.add(followingList[index]);
                                  }
                                });
                              },
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 10,
                                    left: 20,
                                    right: 20,
                                    child: CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Colors.grey[800],
                                      backgroundImage: NetworkImage(
                                        imageUrl,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      left: 95,
                                      top: 70,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey[900],
                                        radius: 15,
                                        child: const Padding(
                                          padding: EdgeInsets.all(0.5),
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            color: blueColor,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    top: 110,
                                    left: 20,
                                    right: 20,
                                    child: Text(
                                      username,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Divider(
                    height: 2,
                    thickness: 1,
                    color: Colors.grey[700],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: TextField(
                            focusNode: _focusNode,
                            style: const TextStyle(fontSize: 18.5),
                            decoration: const InputDecoration(
                              hintText: 'Write a message...',
                              border: InputBorder.none,
                            ),
                            onTap: () {
                              setState(() {});
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: BlueButton(
                            onTap: () {},
                            label: 'Send',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
