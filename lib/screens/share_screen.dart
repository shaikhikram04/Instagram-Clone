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
  var isSendingPost = false;
  late TextEditingController _messageController;
  late TextEditingController _searchController;
  late List<DocumentSnapshot> _usersToShare;
  late List<DocumentSnapshot> _filterdUser;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _searchController = TextEditingController();
    
    _searchController.addListener(
      () => filteringUsers,
    );

    _usersToShare = [];
    _filterdUser = [];
    _isLoading = false;

    fetchUsers();
  }

  void fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    final user = ref.read(userProvider);

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: user.following)
        .get();

    setState(() {
      _usersToShare = snap.docs;
      _filterdUser = _usersToShare;
      _isLoading = false;
    });
  }

  void filteringUsers() async {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filterdUser = _usersToShare.where(
        (user) {
          final String username = user['username'].toLowerCase();
          return username.contains(query);
        },
      ).toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    Future<void> sendPost() async {
      final List<List> participantList = [];
      final message = _messageController.text.trim();

      for (final participant in _selectedUsers) {
        List temp = [user.uid, participant[0]];
        temp.sort();
        participantList.add(temp);
      }

      setState(() {
        isSendingPost = true;
      });

      try {
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
            (selectedUserData) =>
                participantsInDoc.contains(selectedUserData[0]),
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
          var res = await FirestoreMethod.pushMessage(
            conversationId: conversationId,
            uid: user.uid,
            username: user.username,
            messageType: MessageType.post,
            postId: widget.postId,
          );

          if (message.isNotEmpty) {
            res = await FirestoreMethod.pushMessage(
              conversationId: conversationId,
              uid: user.uid,
              username:  user.username,
              messageType: MessageType.text,
              message: message,
            );
          }

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
      } catch (e) {
        return;
      }

      setState(() {
        isSendingPost = false;
      });

      Navigator.pop(context);
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.58,
          minChildSize: 0.4,
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
                            horizontal: 12,
                            vertical: 18,
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                                color: primaryColor, fontSize: 17),
                            onChanged: (value) {
                              if (value.length == 1 || value.isEmpty) {
                                setState(() {});
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Search',
                              helperStyle: const TextStyle(
                                  fontWeight: FontWeight.normal),
                              filled: true,
                              fillColor: const Color.fromARGB(255, 58, 58, 58),
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                        });
                                      },
                                      icon: const Icon(Icons.clear),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : GridView.builder(
                            controller:
                                scrollController, // Attach scrollController
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: width * 0.001,
                              mainAxisSpacing: height * 0.03,
                            ),
                            itemCount: _filterdUser.length,
                            itemBuilder: (context, index) {
                              final userData = _filterdUser[index];
                              final uid = userData['uid'];
                              bool isSelected = _selectedUsers.any(
                                (element) => element[0] == uid,
                              );
                              final String username = userData['username'];
                              final String imageUrl = userData['photoUrl'];
                              return getGridChild(
                                uid,
                                username,
                                imageUrl,
                                isSelected,
                                width,
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
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(fontSize: 18.5),
                            decoration: InputDecoration(
                              hintText: 'Write a message...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[200],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: BlueButton(
                            onTap: sendPost,
                            label: 'Send',
                            isLoading: isSendingPost,
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

  Widget getGridChild(String uid, String username, String imageUrl,
      bool isSelected, double width) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedUsers.removeWhere(
              (element) => element[0] == uid,
            );
          } else {
            _selectedUsers.add([uid, username, imageUrl]);
          }
        });
      },
      child: Column(
        children: [
          Expanded(
            flex: 9,
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: CircleAvatar(
                    backgroundColor: imageBgColor,
                    backgroundImage: NetworkImage(
                      imageUrl,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    left: 60,
                    right: 1,
                    bottom: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      radius: 14,
                      child: Padding(
                        padding: const EdgeInsets.all(0.5),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: blueColor,
                          size: width * 0.07,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            flex: 2,
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  username,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: primaryColor, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
