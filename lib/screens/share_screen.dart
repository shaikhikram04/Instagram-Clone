import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/models/chat.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/blue_button.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final Set<List> _selectedUsers = {};

  final _collectionRef = FirebaseFirestore.instance.collection('users');
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    List<String> followingList = user.following.cast<String>();

    Future<void> sendPost() async {
      final List<List> participantList = [];
      final message = _messageController.text.trim();

      for (final participant in _selectedUsers) {
        participantList.add([user.uid, participant[0]]);
      }

      //* Start the Firestore query
      CollectionReference conversationsRef =
          FirebaseFirestore.instance.collection('conversations');

      //* Create a base query and check for all participants using multiple 'where' clauses
      Query query = conversationsRef;

      query = query.where('participantsId', whereIn: participantList);

      //* Fetch the documents that match the query
      QuerySnapshot querySnapshot = await query.get();

      List<DocumentSnapshot> docs = querySnapshot.docs;

      List<String> conversationIds = [];

      //* removing fetched user from _selectedUser
      for (var doc in docs) {
        List participantsInDoc = doc['participantsId'];
        conversationIds.add(doc['id']);

        _selectedUsers.removeWhere(
          (selectedUserData) => participantsInDoc.contains(selectedUserData[0]),
        );
      }

      //* Now _selectedUser has only those user data who hasn't conversation

      //* Creating a conversation for each _selectedUser
      for (final userData in _selectedUsers) {
        final id = await FirestoreMethod.establishConversation(
          user.uid,
          user.username,
          user.photoUrl,
          userData[0],
          userData[1],
          userData[2],
        );

        conversationIds.add(id);
      }

      var isSuccessfullySend = true;
      //* push postMessage on firestore
      for (final conversationId in conversationIds) {
        final res = await FirestoreMethod.pushMessage(
          conversationId: conversationId,
          uid: user.uid,
          messageType: MessageType.post,
          postId: widget.postId,
          message: message,
        );

        if (res != 'success') isSuccessfullySend = false;
      }

      var responseMessage = '';
      if (isSuccessfullySend) {
        responseMessage = 'post send successfully';
      } else {
        responseMessage = 'post not send successfully to all user';
      }

      if (!context.mounted) return;
      showSnackBar(responseMessage, context);
    }

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
                        String uid = followingList[index];
                        bool isSelected = _selectedUsers.any(
                          (element) => element[0] == uid,
                        );
                        return FutureBuilder(
                          future: _collectionRef.doc(uid).get(),
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
                                    _selectedUsers.removeWhere(
                                      (element) => element[0] == uid,
                                    );
                                  } else {
                                    _selectedUsers
                                        .add([uid, username, imageUrl]);
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
                            controller: _messageController,
                            style: const TextStyle(fontSize: 18.5),
                            decoration: const InputDecoration(
                              hintText: 'Write a message...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: BlueButton(
                            onTap: sendPost,
                            label: 'Send',
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom + 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
